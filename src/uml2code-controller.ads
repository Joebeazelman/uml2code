with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with UML2Code;              use UML2Code;
with UML_Model.Models;      use UML_Model.Models;
with UML_Model.Source;      use UML_Model.Source;

package UML2Code.Controller is

   --  Walkers return a single string. The top-level Emit returns
   --  the paired record, combining the code and test buffers.

   package Emit_Results is new Results (Output_Type => Unbounded_String);
   package Pipeline_Results is new Results (Output_Type => Generated_Output);

   function Emit (M : Model) return Pipeline_Results.Result;

end UML2Code.Controller;
