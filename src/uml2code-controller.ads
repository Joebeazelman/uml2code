with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with UML2Code;              use UML2Code;
with UML_Model.Models;      use UML_Model.Models;
with UML_Model.Source;      use UML_Model.Source;

package UML2Code.Controller is

   package Emit_Results is new Results (Output_Type => Unbounded_String);
   package Pipeline_Results is new Results (Output_Type => Generated_Output);

   function Emit
     (M : Model;
      S : UML2Code.Settings) return Pipeline_Results.Result;

end UML2Code.Controller;
