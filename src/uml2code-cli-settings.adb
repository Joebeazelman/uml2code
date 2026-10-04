with Ada.Exceptions;

package body UML2Code.CLI.Settings is

   function Load (Path : String) return Settings_Result is
      Default_Val : UML2Code.Settings;
   begin
      -- TODO: Read CLI settings file or return defaults
      return Settings_Results.Ok (Default_Val);
   exception
      when E : others =>
         return
           Settings_Results.Err
             (Make_Error
                (No_Location,
                 "Failed to load settings from "
                 & Path
                 & ": "
                 & Ada.Exceptions.Exception_Message (E)));
   end Load;

end UML2Code.CLI.Settings;
