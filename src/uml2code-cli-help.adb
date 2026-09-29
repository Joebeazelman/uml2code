with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with UML2Code.CLI.Colors;      use UML2Code.CLI.Colors;
with UML2Code.CLI.Definitions; use UML2Code.CLI.Definitions;

package body UML2Code.CLI.Help is

   procedure Put_Line_Stderr (S : String) is
   begin
      Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error, S);
   end Put_Line_Stderr;

   --  Pad S on the right to Width characters.
   function Pad (S : String; Width : Natural) return String is
     (if S'Length >= Width then S
      else S & (1 .. Width - S'Length => ' '));

   procedure Print_App_Help is
      Cmds : constant Command_Vectors.Vector := Commands;
   begin
      Put_Line (Bold (App_Name & " " & App_Version)
                & " — " & App_Description);
      New_Line;
      Put_Line (Bold ("USAGE"));
      Put_Line ("    " & App_Name & " <COMMAND> [OPTIONS] [ARGUMENTS]");
      New_Line;
      Put_Line (Bold ("COMMANDS"));
      for C of Cmds loop
         Put_Line ("    " & Cyan (Pad (To_String (C.Name), 12))
                   & To_String (C.Description));
      end loop;
      New_Line;
      Put_Line ("Run `" & App_Name & " help <COMMAND>` for command-specific help.");
   end Print_App_Help;

   procedure Print_Global_Options is
      Globs : constant Option_Vectors.Vector := Global_Options;
   begin
      Put_Line (Bold ("GLOBAL OPTIONS"));
      for O of Globs loop
         declare
            Short_Str : constant String :=
              (if O.Short = ASCII.NUL then "    "
               else "  " & O.Short & ",");
            Long_Str  : constant String :=
              "--" & To_String (O.Long);
            Head      : constant String := Short_Str & " " & Long_Str;
         begin
            Put_Line ("    " & Magenta (Pad (Head, 26))
                      & To_String (O.Help));
         end;
      end loop;
   end Print_Global_Options;

   procedure Print_Command_Help (Command_Name : String) is
      Idx : constant Natural := Find_Command (Command_Name);
      Cmds : constant Command_Vectors.Vector := Commands;
   begin
      if Idx = 0 then
         Print_App_Help;
         return;
      end if;

      declare
         C : constant Command_Def := Cmds.Element (Idx);
         Usage : Unbounded_String :=
           To_Unbounded_String (App_Name & " " & Command_Name);
      begin
         for O of C.Options loop
            Append (Usage, " [--" & To_String (O.Long) & "]");
         end loop;
         for A of C.Arguments loop
            if A.Required then
               Append (Usage, " " & To_String (A.Name));
            else
               Append (Usage, " [" & To_String (A.Name) & "]");
            end if;
         end loop;

         Put_Line (Bold (App_Name & " " & Command_Name)
                   & " — " & To_String (C.Description));
         New_Line;
         Put_Line (Bold ("USAGE"));
         Put_Line ("    " & To_String (Usage));
         New_Line;

         if not C.Arguments.Is_Empty then
            Put_Line (Bold ("ARGUMENTS"));
            for A of C.Arguments loop
               Put_Line ("    " & Cyan (Pad (To_String (A.Name), 20))
                         & To_String (A.Help));
            end loop;
            New_Line;
         end if;

         if not C.Options.Is_Empty then
            Put_Line (Bold ("OPTIONS"));
            for O of C.Options loop
               declare
                  Short_Str : constant String :=
                    (if O.Short = ASCII.NUL then "    "
                     else "  " & O.Short & ",");
                  Long_Str  : constant String :=
                    (if O.Kind = Value then "--" & To_String (O.Long) & "=VALUE"
                     else "--" & To_String (O.Long));
                  Head      : constant String := Short_Str & " " & Long_Str;
               begin
                  Put_Line ("    " & Magenta (Pad (Head, 26))
                            & To_String (O.Help));
               end;
            end loop;
            New_Line;
         end if;

         Print_Global_Options;
      end;
   end Print_Command_Help;

   procedure Print_Error (Message : String) is
   begin
      Put_Line_Stderr (Red ("error:") & " " & Message);
   end Print_Error;

   procedure Print_Usage_Error (Command_Name : String; Message : String) is
      Idx : constant Natural := Find_Command (Command_Name);
      Cmds : constant Command_Vectors.Vector := Commands;
   begin
      Print_Error (Message);
      if Idx = 0 then
         return;
      end if;
      declare
         C : constant Command_Def := Cmds.Element (Idx);
         Usage : Unbounded_String :=
           To_Unbounded_String (App_Name & " " & Command_Name);
      begin
         for O of C.Options loop
            Append (Usage, " [--" & To_String (O.Long) & "]");
         end loop;
         for A of C.Arguments loop
            if A.Required then
               Append (Usage, " " & To_String (A.Name));
            else
               Append (Usage, " [" & To_String (A.Name) & "]");
            end if;
         end loop;
         Put_Line_Stderr ("usage: " & To_String (Usage));
      end;
   end Print_Usage_Error;

end UML2Code.CLI.Help;
