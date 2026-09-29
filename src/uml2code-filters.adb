with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with UML2Code.Casing;

package body UML2Code.Filters is

   --  Filters receive an argument array; the first element is the
   --  value being filtered, additional elements are extra arguments.
   --  Casing filters use only the first and ignore the rest.

   function First_Arg (Args : Jintp.Unbounded_String_Array) return String is
     (if Args'Length = 0 then ""
      else To_String (Args (Args'First)));

   function Snake_Filter
     (Args : Jintp.Unbounded_String_Array) return Unbounded_String is
     (To_Unbounded_String (UML2Code.Casing.To_Snake_Case (First_Arg (Args))));

   function Screaming_Filter
     (Args : Jintp.Unbounded_String_Array) return Unbounded_String is
     (To_Unbounded_String
        (UML2Code.Casing.To_Screaming_Case (First_Arg (Args))));

   function Kebab_Filter
     (Args : Jintp.Unbounded_String_Array) return Unbounded_String is
     (To_Unbounded_String (UML2Code.Casing.To_Kebab_Case (First_Arg (Args))));

   function Train_Filter
     (Args : Jintp.Unbounded_String_Array) return Unbounded_String is
     (To_Unbounded_String (UML2Code.Casing.To_Train_Case (First_Arg (Args))));

   function Pascal_Filter
     (Args : Jintp.Unbounded_String_Array) return Unbounded_String is
     (To_Unbounded_String (UML2Code.Casing.To_Pascal_Case (First_Arg (Args))));

   function Camel_Filter
     (Args : Jintp.Unbounded_String_Array) return Unbounded_String is
     (To_Unbounded_String (UML2Code.Casing.To_Camel_Case (First_Arg (Args))));

   function Ada_Filter
     (Args : Jintp.Unbounded_String_Array) return Unbounded_String is
     (To_Unbounded_String (UML2Code.Casing.To_Ada_Case (First_Arg (Args))));

   procedure Register_All (Settings : in out Jintp.Environment) is
   begin
      Jintp.Register_Filter (Settings, Snake_Filter'Access,    "snake");
      Jintp.Register_Filter (Settings, Screaming_Filter'Access, "screaming");
      Jintp.Register_Filter (Settings, Kebab_Filter'Access,    "kebab");
      Jintp.Register_Filter (Settings, Train_Filter'Access,    "train");
      Jintp.Register_Filter (Settings, Pascal_Filter'Access,   "pascal");
      Jintp.Register_Filter (Settings, Camel_Filter'Access,    "camel");
      Jintp.Register_Filter (Settings, Ada_Filter'Access,      "ada");
   end Register_All;

end UML2Code.Filters;
