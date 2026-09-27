with Jintp;
with UML.Model;

package Uml2Code_Template_Bindings is

   function Id_Of (D : UML.Model.Diagram; Idx : UML.Model.Element_Index)
                   return String;

   function For_States
     (D : UML.Model.Diagram)
      return Jintp.Dictionary;

   function For_Classes
     (D : UML.Model.Diagram)
      return Jintp.Dictionary;

end Uml2Code_Template_Bindings;
