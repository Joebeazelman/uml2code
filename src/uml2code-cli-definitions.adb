package body UML2Code.CLI.Definitions is

   function U (S : String) return Unbounded_String is
     (To_Unbounded_String (S));

   function Opt
     (Short : Character;
      Long  : String;
      Kind  : Option_Kind;
      Help  : String) return Option_Def is
     ((Short => Short, Long => U (Long), Kind => Kind, Help => U (Help)));

   function Arg
     (Name     : String;
      Help     : String;
      Required : Boolean := True) return Argument_Def is
     ((Name => U (Name), Help => U (Help), Required => Required));

   function Global_Options return Option_Vectors.Vector is
      V : Option_Vectors.Vector;
   begin
      V.Append (Opt ('h', "help",    Flag,  "Show this message"));
      V.Append (Opt ('v', "verbose", Flag,  "Verbose output"));
      V.Append (Opt ('q', "quiet",   Flag,  "Suppress non-error output"));
      V.Append (Opt ('C', "color",   Value, "Color: auto (default), always, never"));
      return V;
   end Global_Options;

   function Commands return Command_Vectors.Vector is
      V : Command_Vectors.Vector;
      C : Command_Def;
   begin
      C.Name        := U ("generate");
      C.Description := U ("Generate target code from a PlantUML file");
      C.Options.Append (Opt ('t', "target",   Value, "Template set name"));
      C.Options.Append (Opt ('o', "output",   Value, "Output directory (default: ./src)"));
      C.Options.Append (Opt ('n', "dry-run",  Flag,  "Print to stdout instead of writing files"));
      C.Options.Append (Opt ('a', "author",   Value, "Author name override"));
      C.Options.Append (Opt ('c', "company",  Value, "Company name override"));
      C.Arguments.Append (Arg ("INPUT", "PlantUML source file"));
      V.Append (C);

      C.Name        := U ("list");
      C.Description := U ("List available template sets");
      C.Options.Clear;
      C.Options.Append (Opt ('l', "long", Flag, "Show full descriptor for each set"));
      C.Arguments.Clear;
      V.Append (C);

      C.Name        := U ("check");
      C.Description := U ("Parse a PlantUML file and report errors");
      C.Options.Clear;
      C.Arguments.Clear;
      C.Arguments.Append (Arg ("INPUT", "PlantUML source file"));
      V.Append (C);

      C.Name        := U ("dump");
      C.Description := U ("Print the model as a textual reference");
      C.Options.Clear;
      C.Options.Append (Opt ('o', "output", Value, "Output directory (default: stdout)"));
      C.Arguments.Clear;
      C.Arguments.Append (Arg ("INPUT", "PlantUML source file"));
      V.Append (C);

      C.Name        := U ("help");
      C.Description := U ("Show help for a command");
      C.Options.Clear;
      C.Arguments.Clear;
      C.Arguments.Append
        (Arg ("COMMAND", "Command name (optional)", Required => False));
      V.Append (C);

      return V;
   end Commands;

   function Find_Command (Name : String) return Natural is
      Table : constant Command_Vectors.Vector := Commands;
   begin
      for I in Table.First_Index .. Table.Last_Index loop
         if To_String (Table.Element (I).Name) = Name then
            return I;
         end if;
      end loop;
      return 0;
   end Find_Command;

end UML2Code.CLI.Definitions;
