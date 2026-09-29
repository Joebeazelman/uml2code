with Ada.Command_Line;
with Ada.Directories;
with Ada.Environment_Variables;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with GNAT.OS_Lib;

package body UML2Code.Paths is

   use Ada.Directories;

   Separator : constant Character := GNAT.OS_Lib.Directory_Separator;

   function Find_Executable_Dir return String is
      Name : constant String := Ada.Command_Line.Command_Name;
   begin
      if Index (Name, (1 => Separator)) > 0 then
         declare
            Full : constant String := Containing_Directory (Name);
         begin
            if Full'Length = 0 then
               return Current_Directory;
            end if;
            return Full;
         end;
      end if;

      declare
         Path  : constant String :=
           Ada.Environment_Variables.Value ("PATH", "");
         Start : Positive := Path'First;
      begin
         if Path'Length = 0 then
            return Current_Directory;
         end if;
         for I in Path'Range loop
            if Path (I) = ':' or else I = Path'Last then
               declare
                  Stop      : constant Natural :=
                    (if Path (I) = ':' then I - 1 else I);
                  Dir       : constant String :=
                    (if Stop >= Start then Path (Start .. Stop) else "");
                  Candidate : constant String :=
                    (if Dir'Length > 0
                     then Dir & (1 => Separator) & Name
                     else Name);
               begin
                  if Candidate'Length > 0 and then Exists (Candidate) then
                     return Containing_Directory (Candidate);
                  end if;
               end;
               Start := I + 1;
            end if;
         end loop;
      end;

      return Current_Directory;
   end Find_Executable_Dir;

   function Has_Manifest (Dir : String) return Boolean is
   begin
      if not Exists (Dir) then
         return False;
      end if;
      if Kind (Dir) /= Directory then
         return False;
      end if;
      declare
         Srch : Search_Type;
         Ent  : Directory_Entry_Type;
      begin
         Start_Search (Srch, Dir, "",
                       (Directory => True, others => False));
         while More_Entries (Srch) loop
            Get_Next_Entry (Srch, Ent);
            declare
               Sub : constant String :=
                 Full_Name (Ent) & (1 => Separator) & "manifest.ini";
            begin
               if Exists (Sub) then
                  End_Search (Srch);
                  return True;
               end if;
            end;
         end loop;
         End_Search (Srch);
      end;
      return False;
   end Has_Manifest;

   function Find_Templates_Root return Search_Result is
      Exe_Dir : constant String := Find_Executable_Dir;
      Cwd     : constant String := Current_Directory;

      Candidates : constant array (Positive range <>) of Unbounded_String :=
        (1 => To_Unbounded_String
                (Ada.Environment_Variables.Value ("UML2CODE_TEMPLATES", "")),
         2 => To_Unbounded_String
                (Exe_Dir & (1 => Separator) & ".." & (1 => Separator)
                 & "share" & (1 => Separator) & "uml2code" & (1 => Separator)
                 & "templates"),
         3 => To_Unbounded_String
                (Exe_Dir & (1 => Separator) & ".." & (1 => Separator)
                 & "resources" & (1 => Separator) & "templates"),
         4 => To_Unbounded_String
                (Exe_Dir & (1 => Separator) & "resources" & (1 => Separator)
                 & "templates"),
         5 => To_Unbounded_String
                (Cwd & (1 => Separator) & "resources" & (1 => Separator)
                 & "templates"),
         6 => To_Unbounded_String
                (Cwd & (1 => Separator) & "templates"));

      Tried : Unbounded_String;
   begin
      for C of Candidates loop
         declare
            S : constant String := To_String (C);
         begin
            if S'Length > 0 then
               if Has_Manifest (S) then
                  return (Success => True,
                          Root    => To_Unbounded_String (S));
               end if;
               Append (Tried, S & ASCII.LF);
            end if;
         end;
      end loop;

      return (Success => False,
              Error   => Make_Error
                (No_Location,
                 "templates root not found. Tried:" & ASCII.LF
                 & To_String (Tried)
                 & "Set UML2CODE_TEMPLATES to override."));
   end Find_Templates_Root;

end UML2Code.Paths;
