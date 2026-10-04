package UML2Code.Controller is

   package Emit_Results is new Results (Output_Type => Unbounded_String);
   package Pipeline_Results is new Results (Output_Type => Generated_Output);

   function Emit
     (M : Model; S : UML2Code.Settings; Set_Name : String := "")
      return Pipeline_Results.Result;

end UML2Code.Controller;
