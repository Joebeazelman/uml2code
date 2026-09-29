with Ada.Containers.Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with UML_Model.Source;      use UML_Model.Source;

package UML2Code.Manifests is

   type Manifest is tagged private;

   type Load_Result (Success : Boolean) is record
      case Success is
         when True  => Value : Manifest;
         when False => Error : Source_Error;
      end case;
   end record;

   function Load (Dir : String) return Load_Result;

   function Set_Name  (M : Manifest) return String;
   function Language  (M : Manifest) return String;
   function Extension (M : Manifest) return String;

   type Template_Entry is record
      Element_Kind : Unbounded_String;
      File_Name    : Unbounded_String;
   end record;

   package Template_Entry_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Template_Entry);
   use Template_Entry_Vectors;

   --  Code templates, from the [emit] section.
   function Templates (M : Manifest) return Template_Entry_Vectors.Vector;

   --  Test templates, from the [emit-tests] section. May be empty.
   function Test_Templates (M : Manifest)
     return Template_Entry_Vectors.Vector;

   function Context_Variables
     (M : Manifest; Element_Kind : String) return String;

   package String_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Unbounded_String);
   use String_Vectors;

   function List_Sets (Root : String) return String_Vectors.Vector;

private

   type Manifest is tagged record
      Name     : Unbounded_String;
      Lang     : Unbounded_String;
      Ext      : Unbounded_String;
      Entries  : Template_Entry_Vectors.Vector;
      Tests    : Template_Entry_Vectors.Vector;
      Contexts : Unbounded_String;
   end record;

end UML2Code.Manifests;
