with Ada.Containers.Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package UML2Code.CLI.Definitions is

   App_Name        : constant String := "uml2code";
   App_Version     : constant String := "0.1.0-dev";
   App_Description : constant String :=
     "Generate source code from PlantUML diagrams";

   --  ---- Options ----

   type Option_Kind is (Flag, Value);

   type Option_Def is record
      Short : Character;               --  ASCII.NUL when no short form
      Long  : Unbounded_String;        --  without leading "--"
      Kind  : Option_Kind;
      Help  : Unbounded_String;
   end record;

   package Option_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Option_Def);
   use Option_Vectors;

   --  ---- Arguments ----

   type Argument_Def is record
      Name     : Unbounded_String;
      Help     : Unbounded_String;
      Required : Boolean;
   end record;

   package Argument_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Argument_Def);
   use Argument_Vectors;

   --  ---- Commands ----

   type Command_Def is record
      Name        : Unbounded_String;
      Description : Unbounded_String;
      Options     : Option_Vectors.Vector;
      Arguments   : Argument_Vectors.Vector;
   end record;

   package Command_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Command_Def);
   use Command_Vectors;

   --  ---- Queries ----

   function Commands return Command_Vectors.Vector;
   --  The complete command table. Built fresh on each call from
   --  static declarations, so the definition site reads as data.

   function Global_Options return Option_Vectors.Vector;
   --  Options accepted by every command: help, verbose, quiet, color.

   function Find_Command (Name : String) return Natural;
   --  Index into Commands for the named command, or 0 if unknown.

end UML2Code.CLI.Definitions;
