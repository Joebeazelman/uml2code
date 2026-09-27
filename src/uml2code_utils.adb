with Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Uml2Code_Template_Path;


package body Uml2Code_Utils is

   function Render_Template
     (Subdir   : String;
      Template : String;
      T        : Jintp.Dictionary) return String
   is
      Path : constant String :=
        Uml2Code_Template_Path.Locate (Subdir, Template);
      Env : Jintp.Environment;
   begin
      return Jintp.Render (Path, T, Env);
   end Render_Template;

   function Escape_Json (S : String) return String is
      Result : Unbounded_String;
   begin
      for C of S loop
         case C is
            when '"'      => Append (Result, "\""");
            when '\'      => Append (Result, "\\");
            when ASCII.LF => Append (Result, "\n");
            when ASCII.CR => Append (Result, "\r");
            when ASCII.HT => Append (Result, "\t");
            when others   =>
               if Character'Pos (C) < 32 then
                  Append (Result, "\u" &
                    Ada.Strings.Fixed.Trim (Character'Pos (C)'Image,
                      Ada.Strings.Both));
               else
                  Append (Result, C);
               end if;
         end case;
      end loop;
      return To_String (Result);
   end Escape_Json;

   function Basename_Without_Extension (Path : String) return String is
   begin
      if Path'Length = 0 then
         return "";
      end if;
      declare
         Name : constant String := Ada.Directories.Simple_Name (Path);
      begin
         for I in reverse Name'Range loop
            if Name (I) = '.' and then I > Name'First then
               return Name (Name'First .. I - 1);
            end if;
         end loop;
         return Name;
      end;
   end Basename_Without_Extension;

   function Today return String is
      Raw : constant String :=
        Ada.Calendar.Formatting.Image (Ada.Calendar.Clock, False);
   begin
      return Raw (Raw'First .. Raw'First + 9);
   end Today;

end Uml2Code_Utils;
