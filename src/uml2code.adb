with UML2Code.Controller;

package body UML2Code is

   function Generate
     (M : Model;
      S : Settings := Empty_Settings)
     return Generate_Results.Result
   is
      Emit_Res : constant UML2Code.Controller.Pipeline_Results.Result :=
        UML2Code.Controller.Emit (M, S);
   begin
      if not Emit_Res.Success then
         return Generate_Results.Err (Emit_Res.Error);
      end if;
      return Generate_Results.Ok (Emit_Res.Output);
   end Generate;

end UML2Code;
