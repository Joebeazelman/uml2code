with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with UML_Model.Models;      use UML_Model.Models;
with UML_Model.Source;      use UML_Model.Source;

package UML2Code is

   --  The output of a generation run.
   --
   --  Code_Spec / Code_Body: the target source and its body.
   --  Test_Spec / Test_Body: the generated test starter, split the
   --  same way. Any buffer may be empty when the template set
   --  declares no templates for that section.

   type Generated_Output is record
      Code_Spec : Unbounded_String;
      Code_Body : Unbounded_String;
      Test_Spec : Unbounded_String;
      Test_Body : Unbounded_String;
   end record;

   package Generate_Results is new Results (Output_Type => Generated_Output);

   function Generate (M : Model) return Generate_Results.Result;

end UML2Code;
