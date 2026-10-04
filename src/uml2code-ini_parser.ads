with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package UML2Code.INI_Parser is

   type Line_Kind is (Section_Header, Key_Value_Pair, Comment_Or_Blank, Malformed);

   type Parsed_Line (Kind : Line_Kind := Comment_Or_Blank) is record
      case Kind is
         when Section_Header =>
            Section_Name : Unbounded_String;
         when Key_Value_Pair =>
            Key   : Unbounded_String;
            Value : Unbounded_String;
         when Comment_Or_Blank | Malformed =>
            null;
      end case;
   end record;

   function Parse_Line (Raw_Line : String) return Parsed_Line;

end UML2Code.INI_Parser;
