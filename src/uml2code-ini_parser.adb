with Ada.Strings.Fixed; use Ada.Strings.Fixed;

package body UML2Code.INI_Parser is

   function Parse_Line (Raw_Line : String) return Parsed_Line is
      T : constant String := Trim (Raw_Line, Ada.Strings.Both);
   begin
      if T'Length = 0 or else T (T'First) = '#' or else T (T'First) = ';' then
         return (Kind => Comment_Or_Blank);
      end if;

      if T (T'First) = '[' and then T (T'Last) = ']' then
         return (Kind         => Section_Header,
                 Section_Name => To_Unbounded_String (T (T'First + 1 .. T'Last - 1)));
      end if;

      declare
         Eq : constant Natural := Index (T, "=");
      begin
         if Eq = 0 then
            return (Kind => Malformed);
         end if;

         return (Kind  => Key_Value_Pair,
                 Key   => To_Unbounded_String (Trim (T (T'First .. Eq - 1), Ada.Strings.Both)),
                 Value => To_Unbounded_String (Trim (T (Eq + 1 .. T'Last), Ada.Strings.Both)));
      end;
   end Parse_Line;

end UML2Code.INI_Parser;
