with Ada.Directories;
with Ada.Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;

package body UML2Code.Manifests is

   use Ada.Text_IO;

   function Trim (S : String) return String is
     (Ada.Strings.Fixed.Trim (S, Ada.Strings.Both));

   procedure Parse_Line
     (Line_No  : Positive;
      Text     : String;
      Section  : in out Unbounded_String;
      M        : in out Manifest)
   is
      T : constant String := Trim (Text);
   begin
      if T'Length = 0 or else T (T'First) = '#' then
         return;
      end if;

      if T (T'First) = '[' and then T (T'Last) = ']' then
         Section := To_Unbounded_String (T (T'First + 1 .. T'Last - 1));
         return;
      end if;

      declare
         Eq : constant Natural := Index (T, "=");
      begin
         if Eq = 0 then
            raise Constraint_Error;
         end if;

         declare
            Key : constant String := Trim (T (T'First .. Eq - 1));
            Val : constant String := Trim (T (Eq + 1 .. T'Last));
         begin
            if Section = "set" then
               if Key = "name" then
                  M.Name := To_Unbounded_String (Val);
               elsif Key = "language" then
                  M.Lang := To_Unbounded_String (Val);
               elsif Key = "extension" then
                  M.Ext := To_Unbounded_String (Val);
               end if;
            elsif Section = "emit" then
               M.Entries.Append
                 ((Element_Kind => To_Unbounded_String (Key),
                   File_Name    => To_Unbounded_String (Val)));
            elsif Section = "context" then
               Append (M.Contexts, Key & "=" & Val & ASCII.LF);
            end if;
         end;
      end;
   end Parse_Line;

   function Load (Dir : String) return Load_Result is
      Path : constant String :=
        Dir & (1 => Ada.Directories.Directory_Separator) & "manifest.ini";
      File : File_Type;
      M    : Manifest;
      Sect : Unbounded_String;
      Ln   : Positive := 1;
   begin
      Open (File, In_File, Path);
      while not End_Of_File (File) loop
         begin
            Parse_Line (Ln, Get_Line (File), Sect, M);
         exception
            when Constraint_Error =>
               Close (File);
               return (Success => False,
                       Error   => Make_Error
                         (No_Location,
                          Path & ": malformed line "
                          & Positive'Image (Ln)));
         end;
         Ln := Ln + 1;
      end loop;
      Close (File);

      if Length (M.Name) = 0 then
         return (Success => False,
                 Error   => Make_Error
                   (No_Location, Path & ": missing [set] name"));
      end if;

      return (Success => True, Value => M);

   exception
      when Name_Error =>
         return (Success => False,
                 Error   => Make_Error
                   (No_Location, "manifest not found: " & Path));
   end Load;

   function Set_Name  (M : Manifest) return String is (To_String (M.Name));
   function Language  (M : Manifest) return String is (To_String (M.Lang));
   function Extension (M : Manifest) return String is (To_String (M.Ext));

   function Templates (M : Manifest) return Template_Entry_Vectors.Vector is
     (M.Entries);

   function Context_Variables
     (M : Manifest; Element_Kind : String) return String
   is
      Prefix : constant String := Element_Kind & "=";
      S      : constant String := To_String (M.Contexts);
      Pos    : Natural := 1;
   begin
      while Pos <= S'Length loop
         declare
            Eol  : constant Natural := Index (S (Pos .. S'Length), (1 => ASCII.LF));
            Stop : constant Natural :=
              (if Eol = 0 then S'Length else Pos + Eol - 2);
         begin
            if Stop >= Pos
              and then S (Pos .. Stop)'Length >= Prefix'Length
              and then S (Pos .. Pos + Prefix'Length - 1) = Prefix
            then
               return S (Pos + Prefix'Length .. Stop);
            end if;
            Pos := (if Eol = 0 then S'Length + 1 else Pos + Eol);
         end;
      end loop;
      return "";
   end Context_Variables;

   function List_Sets (Root : String) return String_Vectors.Vector is
      Result : String_Vectors.Vector;
      Srch   : Ada.Directories.Search_Type;
      Ent    : Ada.Directories.Directory_Entry_Type;
   begin
      Ada.Directories.Start_Search
        (Srch, Root, "", (Directory => True, others => False));
      while Ada.Directories.More_Entries (Srch) loop
         Ada.Directories.Get_Next_Entry (Srch, Ent);
         declare
            Name : constant String := Ada.Directories.Simple_Name (Ent);
            Sub  : constant String :=
              Ada.Directories.Full_Name (Ent)
              & (1 => Ada.Directories.Directory_Separator) & "manifest.ini";
         begin
            if Name /= "." and then Name /= ".."
              and then Ada.Directories.Exists (Sub)
            then
               Result.Append (To_Unbounded_String (Name));
            end if;
         end;
      end loop;
      Ada.Directories.End_Search (Srch);
      return Result;
   end List_Sets;

end UML2Code.Manifests;
