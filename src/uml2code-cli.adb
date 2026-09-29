with Ada.Command_Line;
with Ada.Environment_Variables;
with Ada.Text_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;        use Ada.Strings.Fixed;
with UML2Code;
with UML2Code.Paths;
with UML2Code.Manifests;
with UML2Code.CLI.Colors;      use UML2Code.CLI.Colors;
with UML2Code.CLI.Definitions; use UML2Code.CLI.Definitions;
with UML2Code.CLI.Help;
with UML2Code.CLI.Writer;
with PlantUML_Parser;

package body UML2Code.CLI is

   function Read_File (Path : String) return String is
      F   : Ada.Text_IO.File_Type;
      Buf : Unbounded_String;
   begin
      Ada.Text_IO.Open (F, Ada.Text_IO.In_File, Path);
      while not Ada.Text_IO.End_Of_File (F) loop
         Append (Buf, Ada.Text_IO.Get_Line (F));
         Append (Buf, ASCII.LF);
      end loop;
      Ada.Text_IO.Close (F);
      return To_String (Buf);
   end Read_File;

   function Starts_With (S, Prefix : String) return Boolean is
     (S'Length >= Prefix'Length
      and then S (S'First .. S'First + Prefix'Length - 1) = Prefix);

   function Value_Of (S : String; After : String) return String is
      --  Extract the value from "--opt=value": everything after the
      --  "=" in S, assuming S starts with After & "=".
     (S (S'First + After'Length + 1 .. S'Last));

   function Handle_List return Integer is
      R : constant UML2Code.Paths.Search_Result :=
        UML2Code.Paths.Find_Templates_Root;
   begin
      if not R.Success then
         Help.Print_Error ("no template sets found");
         return 1;
      end if;
      declare
         Sets : constant UML2Code.Manifests.String_Vectors.Vector :=
           UML2Code.Manifests.List_Sets (To_String (R.Root));
      begin
         for S of Sets loop
            Ada.Text_IO.Put_Line (To_String (S));
         end loop;
      end;
      return 0;
   end Handle_List;

   function Handle_Generate return Integer is
      Input      : Unbounded_String;
      Target_Set : Unbounded_String;
      Output_Dir : Unbounded_String := To_Unbounded_String ("src");
      Dry_Run    : Boolean := False;
      Count      : constant Natural := Ada.Command_Line.Argument_Count;
      I          : Positive := 2;   --  Skip "generate" itself
   begin
      while I <= Count loop
         declare
            Arg : constant String := Ada.Command_Line.Argument (I);
         begin
            if Arg = "-n" or else Arg = "--dry-run" then
               Dry_Run := True;
               I := I + 1;
            elsif Arg = "-t" or else Arg = "--target" then
               if I + 1 <= Count then
                  Target_Set :=
                    To_Unbounded_String (Ada.Command_Line.Argument (I + 1));
                  I := I + 2;
               else
                  Help.Print_Usage_Error ("generate", "-t requires a value");
                  return 1;
               end if;
            elsif Starts_With (Arg, "--target=") then
               Target_Set :=
                 To_Unbounded_String (Value_Of (Arg, "--target"));
               I := I + 1;
            elsif Arg = "-o" or else Arg = "--output" then
               if I + 1 <= Count then
                  Output_Dir :=
                    To_Unbounded_String (Ada.Command_Line.Argument (I + 1));
                  I := I + 2;
               else
                  Help.Print_Usage_Error ("generate", "-o requires a value");
                  return 1;
               end if;
            elsif Starts_With (Arg, "--output=") then
               Output_Dir :=
                 To_Unbounded_String (Value_Of (Arg, "--output"));
               I := I + 1;
            elsif Arg = "-h" or else Arg = "--help" then
               Help.Print_Command_Help ("generate");
               return 0;
            elsif Arg'Length > 0 and then Arg (Arg'First) = '-' then
               Help.Print_Usage_Error
                 ("generate", "unknown option: " & Arg);
               return 1;
            else
               --  First non-option is INPUT.
               if Length (Input) = 0 then
                  Input := To_Unbounded_String (Arg);
               end if;
               I := I + 1;
            end if;
         end;
      end loop;

      if Length (Input) = 0 then
         Help.Print_Usage_Error ("generate", "INPUT is required");
         return 1;
      end if;

      if Length (Target_Set) > 0 then
         Ada.Environment_Variables.Set
           ("UML2CODE_TEMPLATE_SET", To_String (Target_Set));
      end if;

      begin
         declare
            Contents  : constant String := Read_File (To_String (Input));
            Parse_Res : constant PlantUML_Parser.Parse_Results.Result :=
              PlantUML_Parser.Parse (Contents);
         begin
            if not Parse_Res.Success then
               Help.Print_Error (To_String (Parse_Res.Error));
               return 1;
            end if;

            declare
               Gen_Res : constant UML2Code.Generate_Results.Result :=
                 UML2Code.Generate (Parse_Res.Output);
            begin
               if not Gen_Res.Success then
                  Help.Print_Error (To_String (Gen_Res.Error));
                  return 1;
               end if;

               Writer.Write_Buffers
                 (Dir       => To_String (Output_Dir),
                  Code_Spec => Gen_Res.Output.Code_Spec,
                  Code_Body => Gen_Res.Output.Code_Body,
                  Test_Spec => Gen_Res.Output.Test_Spec,
                  Test_Body => Gen_Res.Output.Test_Body,
                  Dry_Run   => Dry_Run);
            end;
         end;
         return 0;
      exception
         when Ada.Text_IO.Name_Error =>
            Help.Print_Error ("cannot open " & To_String (Input));
            return 1;
      end;
   end Handle_Generate;

   function Run return Integer is
      Count : constant Natural := Ada.Command_Line.Argument_Count;
   begin
      if Count = 0 then
         Help.Print_App_Help;
         return 0;
      end if;

      declare
         First : constant String := Ada.Command_Line.Argument (1);
      begin
         if First = "-h" or else First = "--help" then
            Help.Print_App_Help;
            return 0;
         elsif First = "-V" or else First = "--version" then
            Ada.Text_IO.Put_Line (App_Name & " " & App_Version);
            return 0;
         elsif First = "help" then
            if Count >= 2 then
               Help.Print_Command_Help (Ada.Command_Line.Argument (2));
            else
               Help.Print_App_Help;
            end if;
            return 0;
         elsif First = "list" then
            return Handle_List;
         elsif First = "generate" then
            return Handle_Generate;
         elsif First = "check" then
            Help.Print_Error ("check: not yet implemented");
            return 1;
         elsif First = "dump" then
            Help.Print_Error ("dump: not yet implemented");
            return 1;
         else
            Help.Print_Error ("unknown command: " & First);
            Ada.Text_IO.Put_Line
              ("Run `" & App_Name & " help` for usage.");
            return 2;
         end if;
      end;
   end Run;

end UML2Code.CLI;
