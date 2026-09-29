with AUnit.Assertions;     use AUnit.Assertions;
with AUnit.Test_Cases;     use AUnit.Test_Cases;
with AUnit.Test_Suites;
with UML2Code.Casing;      use UML2Code.Casing;

package body UML2Code_Tests.Test_Casing is

   type Test is new Test_Case with null record;

   overriding function Name (T : Test) return AUnit.Message_String;
   overriding procedure Register_Tests (T : in out Test);

   procedure Test_Foo_Bar (T : in out Test_Case'Class);
   procedure Test_Lower_Snake (T : in out Test_Case'Class);
   procedure Test_HTTPServer (T : in out Test_Case'Class);

   overriding function Name (T : Test) return AUnit.Message_String is
     (AUnit.Format ("UML2Code.Casing"));

   overriding procedure Register_Tests (T : in out Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Foo_Bar'Access, "FooBar -> all forms");
      Register_Routine (T, Test_Lower_Snake'Access, "foo_bar -> all forms");
      Register_Routine (T, Test_HTTPServer'Access, "HTTPServer acronym");
   end Register_Tests;

   procedure Test_Foo_Bar (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      S : constant String := "FooBar";
   begin
      Assert (To_Snake_Case (S) = "foo_bar",       "snake");
      Assert (To_Screaming_Case (S) = "FOO_BAR",   "screaming");
      Assert (To_Kebab_Case (S) = "foo-bar",       "kebab");
      Assert (To_Train_Case (S) = "Foo-Bar",       "train");
      Assert (To_Pascal_Case (S) = "FooBar",       "pascal");
      Assert (To_Camel_Case (S) = "fooBar",        "camel");
      Assert (To_Ada_Case (S) = "Foo_Bar",         "ada");
   end Test_Foo_Bar;

   procedure Test_Lower_Snake (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      S : constant String := "foo_bar";
   begin
      Assert (To_Snake_Case (S) = "foo_bar",       "snake");
      Assert (To_Pascal_Case (S) = "FooBar",       "pascal");
      Assert (To_Camel_Case (S) = "fooBar",        "camel");
      Assert (To_Ada_Case (S) = "Foo_Bar",         "ada");
   end Test_Lower_Snake;

   procedure Test_HTTPServer (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      S : constant String := "HTTPServer";
   begin
      Assert (To_Snake_Case (S) = "http_server",   "snake acronym");
      Assert (To_Ada_Case (S) = "Http_Server",     "ada acronym");
      Assert (To_Pascal_Case (S) = "HttpServer",   "pascal acronym");
      Assert (To_Camel_Case (S) = "httpServer",    "camel acronym");
   end Test_HTTPServer;

   The_Test : aliased Test;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      Result.Add_Test (The_Test'Access);
      return Result;
   end Suite;

end UML2Code_Tests.Test_Casing;
