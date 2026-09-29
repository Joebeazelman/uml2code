with Ada.Directories;
with Ada.Environment_Variables;
with Ada.Text_IO;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;

package body UML2Code.CLI.Settings is

   function Trim (S : String) return String is
     (Ada.Strings.Fixed.Trim (S, Ada.Strings.Both));

   procedure Parse_Line (T : String; S : in out Settings) is
      Trimmed : constant String := Trim (T);
   begin
      if Trimmed'Length = 0 or else Trimmed (Trimmed'First) = '#' then
         return;
      end if;
      if Trimmed (Trimmed'First) = '[' then
         return;
      end if;

      declare
         Eq : constant Natural := Index (Trimmed, "=");
      begin
         if Eq = 0 then
            return;
         end if;
         declare
            Key : constant String := Trim (Trimmed (Trimmed'First .. Eq - 1));
            Val : constant String := Trim (Trimmed (Eq + 1 .. Trimmed'Last));
         begin
            if Key = "author" then
               S.Author := To_Unbounded_String (Val);
            elsif Key = "company" then
               S.Company := To_Unbounded_String (Val);
            elsif Key = "copyright" then
               S.Copyright := To_Unbounded_String (Val);
            end if;
         end;
      end;
   end Parse_Line;

   function Load return Settings is
      Result : Settings := Empty_Settings;
      Path   : constant String :=
        (if Ada.Environment_Variables.Exists ("UML2CODE_SETTINGS")
         then Ada.Environment_Variables.Value ("UML2CODE_SETTINGS")
         else ".uml2code.ini");
      File   : Ada.Text_IO.File_Type;
   begin
      if not Ada.Directories.Exists (Path) then
         return Result;
      end if;

      Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Path);
      while not Ada.Text_IO.End_Of_File (File) loop
         Parse_Line (Ada.Text_IO.Get_Line (File), Result);
      end loop;
      Ada.Text_IO.Close (File);
      return Result;
   exception
      when others =>
         return Result;
   end Load;

end UML2Code.CLI.Settings;
