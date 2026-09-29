with Ada.Directories;
with Ada.Text_IO;
with Ada.Strings.Fixed;  use Ada.Strings.Fixed;
with Ada.Characters.Handling;

package body UML2Code.CLI.Writer is

   --  A top-level package declaration starts at column 1, begins
   --  with "package ", and ends with " is". Nested declarations and
   --  renames are indented and fail both tests.
   function Is_Package_Line (Line : String; Body_Form : out Boolean)
     return Boolean
   is
   begin
      Body_Form := False;
      if Line'Length < 12 then
         return False;
      end if;
      if Line (Line'First) /= 'p' then
         return False;
      end if;
      if Line (Line'First .. Line'First + 7) /= "package " then
         return False;
      end if;
      if Line (Line'Last - 1 .. Line'Last) /= "is" then
         return False;
      end if;
      if Line'Length > 13
        and then Line (Line'First + 8 .. Line'First + 11) = "body"
      then
         Body_Form := True;
      end if;
      return True;
   end Is_Package_Line;

   function Package_Name_Of (Line : String; Body_Form : Boolean)
     return String
   is
      Start : Positive;
   begin
      if Body_Form then
         Start := Line'First + 13;
      else
         Start := Line'First + 8;
      end if;
      while Start <= Line'Last and then Line (Start) = ' ' loop
         Start := Start + 1;
      end loop;
      declare
         Stop : Positive := Start;
      begin
         while Stop <= Line'Last
           and then (Ada.Characters.Handling.Is_Alphanumeric (Line (Stop))
                     or else Line (Stop) = '_'
                     or else Line (Stop) = '.')
         loop
            Stop := Stop + 1;
         end loop;
         return Line (Start .. Stop - 1);
      end;
   end Package_Name_Of;

   function File_Name_For (Package_Name : String;
                           Is_Body      : Boolean) return String is
      Result : Unbounded_String;
      Ext    : constant String := (if Is_Body then ".adb" else ".ads");
   begin
      for C of Package_Name loop
         if C = '.' then
            Append (Result, '-');
         else
            Append (Result, Ada.Characters.Handling.To_Lower (C));
         end if;
      end loop;
      Append (Result, Ext);
      return To_String (Result);
   end File_Name_For;

   procedure Write_Chunk (Dir      : String;
                          Contents : String;
                          Is_Body  : Boolean;
                          Dry_Run  : Boolean)
   is
      Pkg_Name : Unbounded_String := Null_Unbounded_String;
      Idx      : Positive := Contents'First;
   begin
      while Idx <= Contents'Last loop
         declare
            Eol_Abs : constant Natural :=
              Index (Contents (Idx .. Contents'Last), (1 => ASCII.LF));
            Stop : constant Natural :=
              (if Eol_Abs = 0 then Contents'Last else Eol_Abs - 1);
            Line : constant String :=
              (if Stop >= Idx then Contents (Idx .. Stop) else "");
            Body_Form : Boolean;
         begin
            if Is_Package_Line (Line, Body_Form)
              and then Body_Form = Is_Body
            then
               Pkg_Name := To_Unbounded_String
                 (Package_Name_Of (Line, Body_Form));
               exit;
            end if;
            exit when Eol_Abs = 0;
            Idx := Eol_Abs + 1;
         end;
      end loop;

      if Length (Pkg_Name) = 0 then
         return;
      end if;

      declare
         File_Name : constant String :=
           File_Name_For (To_String (Pkg_Name), Is_Body);
         Path      : constant String := Dir & "/" & File_Name;
      begin
         if Dry_Run then
            Ada.Text_IO.Put_Line ("--- " & Path & " ---");
            Ada.Text_IO.Put (Contents);
            if Contents'Length > 0
              and then Contents (Contents'Last) /= ASCII.LF
            then
               Ada.Text_IO.New_Line;
            end if;
            Ada.Text_IO.New_Line;
         else
            if not Ada.Directories.Exists (Dir) then
               Ada.Directories.Create_Path (Dir);
            end if;
            declare
               F : Ada.Text_IO.File_Type;
            begin
               Ada.Text_IO.Create (F, Ada.Text_IO.Out_File, Path);
               Ada.Text_IO.Put (F, Contents);
               if Contents'Length > 0
                 and then Contents (Contents'Last) /= ASCII.LF
               then
                  Ada.Text_IO.New_Line (F);
               end if;
               Ada.Text_IO.Close (F);
            end;
            Ada.Text_IO.Put_Line ("wrote: " & Path);
         end if;
      end;
   end Write_Chunk;

   --  Walk backwards from Pkg_Line over any contiguous run of
   --  with/use lines immediately above it. Returns the position of
   --  the first such line, or Pkg_Line itself if there is none.
   function With_Block_Start (S : String; Pkg_Line : Positive)
     return Positive
   is
      P : Positive := Pkg_Line;
   begin
      while P > S'First loop
         declare
            Prev_End   : constant Natural := P - 2;
            Prev_Start : Natural := Prev_End;
         begin
            if Prev_End < S'First then
               return P;
            end if;
            while Prev_Start > S'First
              and then S (Prev_Start - 1) /= ASCII.LF
            loop
               Prev_Start := Prev_Start - 1;
            end loop;
            declare
               PL : constant String := S (Prev_Start .. Prev_End);
               T  : constant String := Trim (PL, Ada.Strings.Both);
            begin
               if (T'Length > 5
                   and then T (T'First .. T'First + 4) = "with ")
                 or else
                 (T'Length > 4
                  and then T (T'First .. T'First + 3) = "use ")
               then
                  P := Prev_Start;
               else
                  return P;
               end if;
            end;
         end;
      end loop;
      return P;
   end With_Block_Start;

   procedure Split_And_Write (Dir       : String;
                              Contents  : Unbounded_String;
                              Is_Body   : Boolean;
                              Dry_Run   : Boolean)
   is
      S : constant String := To_String (Contents);

      type Pos_Array is array (Positive range <>) of Positive;

      function Find_Package_Lines return Pos_Array is
         Buf   : Pos_Array (1 .. 1000);
         Count : Natural := 0;
         Idx   : Positive := S'First;
      begin
         if S'Length = 0 then
            return Buf (1 .. 0);
         end if;
         while Idx <= S'Last loop
            declare
               Eol_Abs : constant Natural :=
                 Index (S (Idx .. S'Last), (1 => ASCII.LF));
               Stop : constant Natural :=
                 (if Eol_Abs = 0 then S'Last else Eol_Abs - 1);
               Line : constant String :=
                 (if Stop >= Idx then S (Idx .. Stop) else "");
               Body_Form : Boolean;
            begin
               if Is_Package_Line (Line, Body_Form)
                 and then Body_Form = Is_Body
               then
                  Count := Count + 1;
                  Buf (Count) := Idx;
               end if;
               exit when Eol_Abs = 0;
               Idx := Eol_Abs + 1;
            end;
         end loop;
         return Buf (1 .. Count);
      end Find_Package_Lines;

      Starts : constant Pos_Array := Find_Package_Lines;
   begin
      if Starts'Length = 0 then
         return;
      end if;

      for I in Starts'Range loop
         declare
            Chunk_Start : constant Positive :=
              With_Block_Start (S, Starts (I));
            Chunk_End   : Positive;
         begin
            if I < Starts'Last then
               Chunk_End := With_Block_Start (S, Starts (I + 1)) - 1;
            else
               Chunk_End := S'Last;
            end if;
            Write_Chunk (Dir, S (Chunk_Start .. Chunk_End),
                         Is_Body, Dry_Run);
         end;
      end loop;
   end Split_And_Write;

   procedure Write_Buffers
     (Dir       : String;
      Code_Spec : Unbounded_String;
      Code_Body : Unbounded_String;
      Test_Spec : Unbounded_String;
      Test_Body : Unbounded_String;
      Dry_Run   : Boolean)
   is
   begin
      Split_And_Write (Dir, Code_Spec, Is_Body => False, Dry_Run => Dry_Run);
      Split_And_Write (Dir, Code_Body, Is_Body => True,  Dry_Run => Dry_Run);
      Split_And_Write (Dir, Test_Spec, Is_Body => False, Dry_Run => Dry_Run);
      Split_And_Write (Dir, Test_Body, Is_Body => True,  Dry_Run => Dry_Run);
   end Write_Buffers;

end UML2Code.CLI.Writer;
