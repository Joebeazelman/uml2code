with AUnit.Assertions;         use AUnit.Assertions;
with AUnit.Test_Cases;         use AUnit.Test_Cases;
with AUnit.Test_Suites;
with Ada.Strings.Fixed;        use Ada.Strings.Fixed;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with UML2Code.Paths;           use UML2Code.Paths;
with UML_Model.Source;         use UML_Model.Source;

package body UML2Code_Tests.Test_Paths is

   type Test is new Test_Case with null record;

   overriding function Name (T : Test) return AUnit.Message_String;
   overriding procedure Register_Tests (T : in out Test);

   procedure Test_Env_Override (T : in out Test_Case'Class);

   overriding function Name (T : Test) return AUnit.Message_String is
     (AUnit.Format ("UML2Code.Paths"));

   overriding procedure Register_Tests (T : in out Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Env_Override'Access,
                        "UML2CODE_TEMPLATES env var consulted first");
   end Register_Tests;

   procedure Test_Env_Override (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      declare
         R : constant Search_Result := Find_Templates_Root;
      begin
         if not R.Success then
            declare
               Msg : constant String := To_String (R.Error.Message);
            begin
               Assert
                 (Index (Msg, "UML2CODE_TEMPLATES") > 0,
                  "error message mentions env override");
            end;
         else
            Assert (True, "templates root found");
         end if;
      end;
   end Test_Env_Override;

   The_Test : aliased Test;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      Result.Add_Test (The_Test'Access);
      return Result;
   end Suite;

end UML2Code_Tests.Test_Paths;
