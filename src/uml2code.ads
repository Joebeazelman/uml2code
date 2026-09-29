with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with UML_Model.Models;      use UML_Model.Models;
with UML_Model.Source;      use UML_Model.Source;

package UML2Code is

   package Generate_Results is new Results (Output_Type => Unbounded_String);

   function Generate (M : Model) return Generate_Results.Result;

end UML2Code;
