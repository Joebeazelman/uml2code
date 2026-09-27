with AUnit.Test_Cases;

package Test_Identifiers is

   type Case_Type is new AUnit.Test_Cases.Test_Case with null record;

   procedure Register_Tests (T : in out Case_Type);
   function Name (T : Case_Type) return AUnit.Message_String;

end Test_Identifiers;
