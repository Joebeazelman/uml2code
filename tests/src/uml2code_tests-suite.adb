with AUnit.Test_Suites;
with UML2Code_Tests.Test_Casing;
with UML2Code_Tests.Test_Manifests;
with UML2Code_Tests.Test_Paths;

package body UML2Code_Tests.Suite is

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      Result.Add_Test (Test_Casing.Suite);
      Result.Add_Test (Test_Manifests.Suite);
      Result.Add_Test (Test_Paths.Suite);
      return Result;
   end Suite;

end UML2Code_Tests.Suite;
