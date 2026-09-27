with AUnit.Assertions;   use AUnit.Assertions;
with AUnit.Test_Cases;   use AUnit.Test_Cases;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Uml2Code_Comments;

package body Test_Comments is

   procedure Test_Empty_String (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      Result : constant Jintp.List := Uml2Code_Comments.Comment_Lines ("", 78);
   begin
      Assert (Result.Length = 0, "empty string produces empty list");
   end Test_Empty_String;

   procedure Test_Single_Line (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      Result : constant Jintp.List := Uml2Code_Comments.Comment_Lines ("Hello", 78);
   begin
      Assert (Result.Length = 1, "single line produces one element");
      Assert (To_String (Result.First_Element) = "Hello",
              "content preserved");
   end Test_Single_Line;

   procedure Test_Word_Wrapping (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      Long_Text : constant String := "This is a very long line that should wrap at word boundaries";
      Result : constant Jintp.List := Uml2Code_Comments.Comment_Lines (Long_Text, 20);
   begin
      Assert (Result.Length > 1, "long text wraps into multiple lines");
      -- Verify no word is split
      for I in 1 .. Result.Length loop
         declare
            Line : constant String := To_String (Result.Element (I));
         begin
            Assert (Line'Length <= 20, "line respects wrap width");
         end;
      end loop;
   end Test_Word_Wrapping;

   procedure Test_Preserve_Newlines (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      Text : constant String := "Line 1" & ASCII.LF & "Line 2" & ASCII.LF & "Line 3";
      Result : constant Jintp.List := Uml2Code_Comments.Comment_Lines (Text, 78);
   begin
      Assert (Result.Length = 3, "newlines preserved");
      Assert (To_String (Result.Element (1)) = "Line 1", "first line");
      Assert (To_String (Result.Element (2)) = "Line 2", "second line");
      Assert (To_String (Result.Element (3)) = "Line 3", "third line");
   end Test_Preserve_Newlines;

   procedure Test_Default_Width (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      Long_Text : constant String := (1 .. 100 => 'x');
      Result : constant Jintp.List := Uml2Code_Comments.Comment_Lines (Long_Text);
   begin
      Assert (Result.Length > 1, "default width 78 wraps long text");
   end Test_Default_Width;

   procedure Register_Tests (T : in out Case_Type) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Empty_String'Access, "Empty string");
      Register_Routine (T, Test_Single_Line'Access, "Single line");
      Register_Routine (T, Test_Word_Wrapping'Access, "Word wrapping");
      Register_Routine (T, Test_Preserve_Newlines'Access, "Preserve newlines");
      Register_Routine (T, Test_Default_Width'Access, "Default width");
   end Register_Tests;

   function Name (T : Case_Type) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Comments");
   end Name;

end Test_Comments;
