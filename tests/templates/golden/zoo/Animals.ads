---------------------------------------------------------------------
--  Animals


-- Zoo sample diagram

-- Exercises package nesting, inheritance, and notes.

---------------------------------------------------------------------


with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;


with Ada.Containers.Vectors;


with Model;
use Model;


package Animals is
   pragma Elaborate_Body;



   type Color is (Red, Green, Blue);




   type Pet is limited interface;




   type Toy_Access is access all Toy'Class;

   package Toy_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Toy_Access);




   type Animal is abstract tagged record

      Attr_name : Unbounded_String;

   end record;




   procedure Speak (Self : in out Animal);




   procedure Move (Self : in out Animal) is abstract;





   -- A loyal companion.

   type Dog is new Animal and Pet with record

      Attr_Toy : Toy_Vectors.Vector;

      Attr_Color : Color;

   end record;




   procedure Fetch (Self : in out Dog);




   procedure Move (Self : in out Dog);



   function Name (Self : in Dog) return Unbounded_String;






end Animals;
