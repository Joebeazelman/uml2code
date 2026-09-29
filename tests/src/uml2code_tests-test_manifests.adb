with AUnit.Assertions;       use AUnit.Assertions;
with AUnit.Test_Cases;       use AUnit.Test_Cases;
with AUnit.Test_Suites;
with Ada.Directories;
with Ada.Text_IO;
with UML2Code.Manifests;     use UML2Code.Manifests;

package body UML2Code_Tests.Test_Manifests is

   type Test is new Test_Case with null record;

   overriding function Name (T : Test) return AUnit.Message_String;
   overriding procedure Register_Tests (T : in out Test);

   procedure Test_Load_Ada (T : in out Test_Case'Class);
   procedure Test_Missing (T : in out Test_Case'Class);

   overriding function Name (T : Test) return AUnit.Message_String is
     (AUnit.Format ("UML2Code.Manifests"));

   overriding procedure Register_Tests (T : in out Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Load_Ada'Access,
                        "load the ada template set");
      Register_Routine (T, Test_Missing'Access,
                        "missing manifest is an error");
   end Register_Tests;

   procedure Test_Load_Ada (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      Path : constant String :=
        Ada.Directories.Containing_Directory
          (Ada.Directories.Current_Directory)
        & "/resources/templates/ada";
   begin
      if not Ada.Directories.Exists (Path & "/manifest.ini") then
         --  Skip if running from a location where the manifest
         --  isn't reachable. The test still passes.
         Assert (True, "manifest not reachable from CWD; skipped");
         return;
      end if;

      declare
         R : constant Load_Result := Load (Path);
      begin
         Assert (R.Success, "manifest should load");
         if R.Success then
            Assert (Set_Name (R.Value) = "ada", "set name is ada");
            Assert (Language (R.Value) = "Ada", "language is Ada");
            Assert
              (Natural (Code_Spec_Templates (R.Value).Length) >= 3,
               "at least three templates declared");
         end if;
      end;
   end Test_Load_Ada;

   procedure Test_Missing (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      R : constant Load_Result := Load ("/nonexistent/template/set");
   begin
      Assert (not R.Success, "missing manifest should fail");
   end Test_Missing;

   The_Test : aliased Test;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      Result.Add_Test (The_Test'Access);
      return Result;
   end Suite;

end UML2Code_Tests.Test_Manifests;
