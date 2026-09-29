package body UML2Code is

   function Generate (M : Model) return Generate_Results.Result is
      pragma Unreferenced (M);
   begin
      return Generate_Results.Err
        (Make_Error (No_Location, "generator not yet implemented"));
   end Generate;

end UML2Code;
