with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with UML_Model.Models;      use UML_Model.Models;
with UML_Model.Source;      use UML_Model.Source;

package UML2Code is

   type Generated_Output is record
      Code_Spec : Unbounded_String;
      Code_Body : Unbounded_String;
      Test_Spec : Unbounded_String;
      Test_Body : Unbounded_String;
   end record;

   type Settings is record
      Author    : Unbounded_String;
      Company   : Unbounded_String;
      Copyright : Unbounded_String;
   end record;

   Empty_Settings : constant Settings :=
     (Author    => Null_Unbounded_String,
      Company   => Null_Unbounded_String,
      Copyright => Null_Unbounded_String);

   package Generate_Results is new Results (Output_Type => Generated_Output);

   function Generate
     (M        : Model;
      S        : Settings := Empty_Settings;
      Set_Name : String   := "")
     return Generate_Results.Result;

end UML2Code;
