with Ada.Environment_Variables;

package body UML2Code.CLI.Colors is

   Current : Mode := Auto;

   ESC : constant Character := ASCII.ESC;

   function Enabled return Boolean is
   begin
      case Current is
         when Always => return True;
         when Never  => return False;
         when Auto   =>
            if Ada.Environment_Variables.Exists ("NO_COLOR") then
               return False;
            end if;
            return True;
      end case;
   end Enabled;

   function Wrap (Code : String; S : String) return String is
   begin
      if not Enabled then
         return S;
      end if;
      return ESC & "[" & Code & "m" & S & ESC & "[0m";
   end Wrap;

   procedure Set_Mode (M : Mode) is
   begin
      Current := M;
   end Set_Mode;

   function Current_Mode return Mode is (Current);

   function Bold    (S : String) return String is (Wrap ("1", S));
   function Dim     (S : String) return String is (Wrap ("2", S));
   function Green   (S : String) return String is (Wrap ("32", S));
   function Red     (S : String) return String is (Wrap ("31", S));
   function Yellow  (S : String) return String is (Wrap ("33", S));
   function Cyan    (S : String) return String is (Wrap ("36", S));
   function Magenta (S : String) return String is (Wrap ("35", S));

end UML2Code.CLI.Colors;
