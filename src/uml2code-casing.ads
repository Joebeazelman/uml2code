package UML2Code.Casing is

   --  Each function tokenizes the input (splitting on '_', '-', ' ',
   --  and camelCase/PascalCase boundaries) and rejoins the tokens
   --  according to the target convention. Acronyms normalize, so
   --  "HTTPServer" yields "Http_Server" in Ada casing.

   function To_Snake_Case     (Id : String) return String;  --  foo_bar
   function To_Screaming_Case (Id : String) return String;  --  FOO_BAR
   function To_Kebab_Case     (Id : String) return String;  --  foo-bar
   function To_Train_Case     (Id : String) return String;  --  Foo-Bar
   function To_Pascal_Case    (Id : String) return String;  --  FooBar
   function To_Camel_Case     (Id : String) return String;  --  fooBar
   function To_Ada_Case       (Id : String) return String;  --  Foo_Bar

end UML2Code.Casing;
