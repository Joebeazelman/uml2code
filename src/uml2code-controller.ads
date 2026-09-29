with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with UML_Model.Models;      use UML_Model.Models;
with UML_Model.Source;      use UML_Model.Source;

package UML2Code.Controller is

   package Emit_Results is new Results (Output => Unbounded_String);

   function Emit (M : Model) return Emit_Results.Result;

end UML2Code.Controller;
