with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with UML_Model.Models;      use UML_Model.Models;
with UML_Model.Source;      use UML_Model.Source;

package UML2Code is

   --  The output of a generation run. Code holds the target source;
   --  Tests holds any generated test starter, which may be empty
   --  when the template set declares no test templates.

   type Generated_Output is record
      Code  : Unbounded_String;
      Tests : Unbounded_String;
   end record;

   package Generate_Results is new Results (Output_Type => Generated_Output);

   function Generate (M : Model) return Generate_Results.Result;

end UML2Code;
