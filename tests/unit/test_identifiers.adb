with AUnit.Assertions;   use AUnit.Assertions;
with AUnit.Test_Cases;   use AUnit.Test_Cases;

with Uml2Code_Identifiers;

package body Test_Identifiers is

   --  Sanitize tests
   procedure Test_Sanitize_Simple (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Identifiers.Sanitize ("hello") = "hello",
              "simple alphanumeric");
   end Test_Sanitize_Simple;

   procedure Test_Sanitize_Special_Chars (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Identifiers.Sanitize ("hello-world") = "hello_world",
              "hyphen becomes underscore");
      Assert (Uml2Code_Identifiers.Sanitize ("foo@bar#baz") = "foo_bar_baz",
              "multiple special chars collapse");
   end Test_Sanitize_Special_Chars;

   procedure Test_Sanitize_Leading_Digit (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Identifiers.Sanitize ("123abc") = "S_123abc",
              "leading digit gets S_ prefix");
      Assert (Uml2Code_Identifiers.Sanitize ("123abc", "T_") = "T_123abc",
              "custom digit prefix");
   end Test_Sanitize_Leading_Digit;

   procedure Test_Sanitize_Empty (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Identifiers.Sanitize ("") = "Unnamed",
              "empty string becomes Unnamed");
      Assert (Uml2Code_Identifiers.Sanitize ("@#$") = "Unnamed",
              "only special chars becomes Unnamed");
   end Test_Sanitize_Empty;

   procedure Test_Sanitize_Trailing_Underscores (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Identifiers.Sanitize ("hello___") = "hello",
              "trailing underscores removed");
   end Test_Sanitize_Trailing_Underscores;

   --  Ada_Case tests
   procedure Test_Ada_Case_Simple (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Identifiers.Ada_Case ("hello_world") = "Hello_World",
              "underscore separated words");
   end Test_Ada_Case_Simple;

   procedure Test_Ada_Case_Mixed (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Identifiers.Ada_Case ("foo_BAR_baz") = "Foo_Bar_Baz",
              "mixed case normalized");
   end Test_Ada_Case_Mixed;

   --  Ident tests
   procedure Test_Ident_Complete (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Identifiers.Ident ("hello-world") = "Hello_World",
              "sanitize + ada_case");
      Assert (Uml2Code_Identifiers.Ident ("123abc") = "S_123Abc",
              "digit prefix + casing");
      Assert (Uml2Code_Identifiers.Ident ("foo@bar", "T_") = "Foo_Bar",
               "custom prefix + special chars");
   end Test_Ident_Complete;

   procedure Register_Tests (T : in out Case_Type) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Sanitize_Simple'Access, "Sanitize simple");
      Register_Routine (T, Test_Sanitize_Special_Chars'Access, "Sanitize special chars");
      Register_Routine (T, Test_Sanitize_Leading_Digit'Access, "Sanitize leading digit");
      Register_Routine (T, Test_Sanitize_Empty'Access, "Sanitize empty");
      Register_Routine (T, Test_Sanitize_Trailing_Underscores'Access, "Sanitize trailing underscores");
      Register_Routine (T, Test_Ada_Case_Simple'Access, "Ada_Case simple");
      Register_Routine (T, Test_Ada_Case_Mixed'Access, "Ada_Case mixed");
      Register_Routine (T, Test_Ident_Complete'Access, "Ident complete");
   end Register_Tests;

   function Name (T : Case_Type) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Identifiers");
   end Name;

end Test_Identifiers;
