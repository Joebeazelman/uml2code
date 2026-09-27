with AUnit.Assertions;   use AUnit.Assertions;
with AUnit.Test_Cases;   use AUnit.Test_Cases;

with Uml2Code_Utils;

package body Test_Utils is

   procedure Test_Escape_Json_Quotes (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Utils.Escape_Json ("hello") = "hello",
              "no escaping needed");
      Assert (Uml2Code_Utils.Escape_Json ("say ""hi""") = "say \""hi\""",
              "quotes escaped");
   end Test_Escape_Json_Quotes;

   procedure Test_Escape_Json_Backslash (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Utils.Escape_Json ("path\to\file") = "path\\to\\file",
              "backslashes escaped");
   end Test_Escape_Json_Backslash;

   procedure Test_Escape_Json_Newlines (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Utils.Escape_Json ("line1" & ASCII.LF & "line2") = "line1\nline2",
              "LF escaped");
      Assert (Uml2Code_Utils.Escape_Json ("line1" & ASCII.CR & "line2") = "line1\rline2",
              "CR escaped");
   end Test_Escape_Json_Newlines;

   procedure Test_Basename_Without_Extension (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Assert (Uml2Code_Utils.Basename_Without_Extension ("foo/bar.puml") = "bar",
              "path with extension");
      Assert (Uml2Code_Utils.Basename_Without_Extension ("bar.puml") = "bar",
              "filename with extension");
      Assert (Uml2Code_Utils.Basename_Without_Extension ("bar") = "bar",
              "no extension");
      Assert (Uml2Code_Utils.Basename_Without_Extension (".profile") = ".profile",
              "hidden file");
      Assert (Uml2Code_Utils.Basename_Without_Extension ("") = "",
              "empty string");
   end Test_Basename_Without_Extension;

   procedure Test_Today (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      Date_Str : constant String := Uml2Code_Utils.Today;
   begin
      Assert (Date_Str'Length = 10, "YYYY-MM-DD format");
      Assert (Date_Str (5) = '-' and then Date_Str (8) = '-',
              "correct separators");
   end Test_Today;

   procedure Register_Tests (T : in out Case_Type) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Escape_Json_Quotes'Access, "Escape_Json quotes");
      Register_Routine (T, Test_Escape_Json_Backslash'Access, "Escape_Json backslash");
      Register_Routine (T, Test_Escape_Json_Newlines'Access, "Escape_Json newlines");
      Register_Routine (T, Test_Basename_Without_Extension'Access, "Basename_Without_Extension");
      Register_Routine (T, Test_Today'Access, "Today");
   end Register_Tests;

   function Name (T : Case_Type) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Utils");
   end Name;

end Test_Utils;
