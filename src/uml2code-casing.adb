with Caser;

package body UML2Code.Casing is

   function To_Snake_Case (Id : String) return String is
     (Caser.To_Snake_Case (Id));

   function To_Screaming_Case (Id : String) return String is
     (Caser.To_Screaming_Snake_Case (Id));

   function To_Kebab_Case (Id : String) return String is
     (Caser.To_Kebab_Case (Id));

   function To_Train_Case (Id : String) return String is
     (Caser.To_Train_Case (Id));

   function To_Pascal_Case (Id : String) return String is
     (Caser.To_Pascal_Case (Id));

   function To_Camel_Case (Id : String) return String is
     (Caser.To_Camel_Case (Id));

   function To_Ada_Case (Id : String) return String is
     (Caser.To_Ada_Case (Id));

end UML2Code.Casing;
