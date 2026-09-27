with AUnit.Assertions;   use AUnit.Assertions;
with AUnit.Test_Cases;   use AUnit.Test_Cases;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;     use Ada.Strings.Fixed;
with Ada.Text_IO;           use Ada.Text_IO;
with Jintp;

with Uml2Code_Comments;

package body Test_Comments is

   Template_Path : constant String := "/tmp/uml2code_comment_lines.tmplt";

   function Render_Lines (Text : String; Width : Positive := 78) return String is
      D : Jintp.Dictionary;
      F : File_Type;
   begin
      Create (F, Out_File, Template_Path);
      Put (F, "{% for line in lines %}{{ line.text }}");
      New_Line (F);
      Put (F, "{% endfor %}");
      Close (F);
      Jintp.Insert (D, "lines", Uml2Code_Comments.Comment_Lines (Text, Width));
      return Jintp.Render (Template_Path, D);
   end Render_Lines;

   function Line_Count (Text : String) return Natural is
      Count : Natural := 0;
   begin
      for Character of Text loop
         if Character = ASCII.LF then
            Count := Count + 1;
         end if;
      end loop;
      return Count;
   end Line_Count;

   function Max_Line_Length (Text : String) return Natural is
      Current : Natural := 0;
      Maximum : Natural := 0;
   begin
      for Character of Text loop
         if Character = ASCII.LF then
            Maximum := Natural'Max (Maximum, Current);
            Current := 0;
         else
            Current := Current + 1;
         end if;
      end loop;
      return Natural'Max (Maximum, Current);
   end Max_Line_Length;

   procedure Test_Empty_String (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      Result : constant String := Render_Lines ("", 78);
   begin
      Assert (Result'Length = 0, "empty string produces empty list");
   end Test_Empty_String;

   procedure Test_Single_Line (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      Result : constant String := Render_Lines ("Hello", 78);
   begin
      Assert (Line_Count (Result) = 1, "single line produces one element");
      Assert (Index (Result, "-- Hello") > 0,
              "content preserved");
   end Test_Single_Line;

   procedure Test_Word_Wrapping (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      Long_Text : constant String := "This is a very long line that should wrap at word boundaries";
      Result : constant String := Render_Lines (Long_Text, 20);
   begin
      Assert (Line_Count (Result) > 1, "long text wraps into multiple lines");
      Assert (Max_Line_Length (Result) <= 20,
              "line respects wrap width");
   end Test_Word_Wrapping;

   procedure Test_Preserve_Newlines (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      Text : constant String := "Line 1" & ASCII.LF & "Line 2" & ASCII.LF & "Line 3";
      Result : constant String := Render_Lines (Text, 78);
   begin
      Assert (Line_Count (Result) = 3, "newlines preserved");
      Assert (Index (Result, "-- Line 1") > 0, "first line");
      Assert (Index (Result, "-- Line 2") > 0, "second line");
      Assert (Index (Result, "-- Line 3") > 0, "third line");
   end Test_Preserve_Newlines;

   procedure Test_Default_Width (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
         Long_Text : constant String :=
            "This text contains enough separate words to wrap at the default width "
            & "without splitting any individual word";
      Result : constant String := Render_Lines (Long_Text);
   begin
      Assert (Line_Count (Result) > 1, "default width 78 wraps long text");
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
