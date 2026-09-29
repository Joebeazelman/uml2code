with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package UML2Code.CLI.Settings is

   --  User-facing settings available to templates under the
   --  "settings" dictionary key. Loaded from .uml2code.ini (or
   --  $UML2CODE_SETTINGS) with command-line overrides applied on
   --  top.

   type Settings is record
      Author    : Unbounded_String;
      Company   : Unbounded_String;
      Copyright : Unbounded_String;
   end record;

   Empty_Settings : constant Settings :=
     (Author    => Null_Unbounded_String,
      Company   => Null_Unbounded_String,
      Copyright => Null_Unbounded_String);

   function Load return Settings;
   --  Reads the settings file if present, returns defaults
   --  otherwise. Missing file is not an error.

end UML2Code.CLI.Settings;
