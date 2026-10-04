with UML_Model.Source;

package UML2Code.CLI.Settings is

   package Settings_Results is new Results (UML2Code.Settings);
   subtype Settings_Result is Settings_Results.Result;

   ---------------------------------------------------------------------------
   -- Settings Loader
   ---------------------------------------------------------------------------
   function Load (Path : String) return Settings_Result;

end UML2Code.CLI.Settings;
