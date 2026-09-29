package body UML2Code.Controller is

   function Emit (M : Model) return Emit_Results.Result is
      pragma Unreferenced (M);
   begin
      return Emit_Results.Err
        (Make_Error (No_Location, "controller not yet implemented"));
   end Emit;

end UML2Code.Controller;
