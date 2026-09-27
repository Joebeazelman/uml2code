with AUnit.Assertions;   use AUnit.Assertions;
with AUnit.Test_Cases;   use AUnit.Test_Cases;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with UML.Model;
with UML.Model.Queries;

package body Test_Queries is

   use type UML.Model.Element_Index;

   function Make_Empty_Diagram return UML.Model.Diagram is
   begin
      return UML.Model.Diagram'(
         Elements   => UML.Model.Element_Vectors.Empty_Vector,
         Relations  => UML.Model.Relation_Vectors.Empty_Vector,
         Metadata   => UML.Model.Metadata_Vectors.Empty_Vector,
         Notes      => UML.Model.Note_Vectors.Empty_Vector
      );
   end Make_Empty_Diagram;

   function Make_Simple_Diagram return UML.Model.Diagram is
      D : UML.Model.Diagram := Make_Empty_Diagram;
      E1, E2 : UML.Model.Element;
   begin
      E1.Id := To_Unbounded_String ("State1");
      E1.Kind := UML.Model.State;
      E1.Parent := 0;
      D.Elements.Append (E1);

      E2.Id := To_Unbounded_String ("State2");
      E2.Kind := UML.Model.State;
      E2.Parent := 0;
      D.Elements.Append (E2);

      return D;
   end Make_Simple_Diagram;

   procedure Test_Find_By_Id_Found (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      D : constant UML.Model.Diagram := Make_Simple_Diagram;
   begin
      Assert (UML.Model.Queries.Find_By_Id (D, "State1") = 1,
              "finds first element");
      Assert (UML.Model.Queries.Find_By_Id (D, "State2") = 2,
              "finds second element");
   end Test_Find_By_Id_Found;

   procedure Test_Find_By_Id_Not_Found (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      D : constant UML.Model.Diagram := Make_Simple_Diagram;
   begin
      Assert (UML.Model.Queries.Find_By_Id (D, "NonExistent") = 0,
              "returns 0 for missing element");
   end Test_Find_By_Id_Not_Found;

   procedure Test_Id_Of (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      D : constant UML.Model.Diagram := Make_Simple_Diagram;
   begin
      Assert (UML.Model.Queries.Id_Of (D, 1) = "State1",
              "returns correct id");
      Assert (UML.Model.Queries.Id_Of (D, 0) = "",
              "returns empty for index 0");
      Assert (UML.Model.Queries.Id_Of (D, 99) = "",
              "returns empty for out of bounds");
   end Test_Id_Of;

   procedure Test_Title_Of_Empty (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      D : constant UML.Model.Diagram := Make_Empty_Diagram;
   begin
      Assert (UML.Model.Queries.Title_Of (D) = "",
              "empty diagram has no title");
   end Test_Title_Of_Empty;

   procedure Test_Title_Of_With_Title (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      D : UML.Model.Diagram := Make_Empty_Diagram;
      M : UML.Model.Metadata_Entry;
   begin
      M.Kind := UML.Model.Title;
      M.Text := To_Unbounded_String ("My Diagram");
      D.Metadata.Append (M);

      Assert (UML.Model.Queries.Title_Of (D) = "My Diagram",
              "returns title text");
   end Test_Title_Of_With_Title;

   procedure Test_Region_Cache (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      D : constant UML.Model.Diagram := Make_Simple_Diagram;
      Cache : constant UML.Model.Queries.Region_Cache :=
        UML.Model.Queries.Build_Cache (D);
   begin
      Assert (UML.Model.Queries.Region_Of (Cache, 1) = 0,
              "top-level element has region 0");
      Assert (UML.Model.Queries.Region_Of (Cache, 2) = 0,
              "top-level element has region 0");
   end Test_Region_Cache;

   procedure Register_Tests (T : in out Case_Type) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Find_By_Id_Found'Access, "Find_By_Id found");
      Register_Routine (T, Test_Find_By_Id_Not_Found'Access, "Find_By_Id not found");
      Register_Routine (T, Test_Id_Of'Access, "Id_Of");
      Register_Routine (T, Test_Title_Of_Empty'Access, "Title_Of empty");
      Register_Routine (T, Test_Title_Of_With_Title'Access, "Title_Of with title");
      Register_Routine (T, Test_Region_Cache'Access, "Region_Cache");
   end Register_Tests;

   function Name (T : Case_Type) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Queries");
   end Name;

end Test_Queries;
