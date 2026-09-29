package UML2Code.CLI.Help is

   procedure Print_App_Help;
   --  Top-level help: application header, usage, command list.

   procedure Print_Command_Help (Command_Name : String);
   --  Per-command help: usage, arguments, options, globals.
   --  If the command is unknown, prints app help.

   procedure Print_Error (Message : String);
   --  One-line error to stderr, colored red.

   procedure Print_Usage_Error (Command_Name : String; Message : String);
   --  Error followed by the usage line for the named command.

end UML2Code.CLI.Help;
