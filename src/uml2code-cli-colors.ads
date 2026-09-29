package UML2Code.CLI.Colors is

   --  ANSI color codes as short strings. Each wraps the value and
   --  resets after. When colors are disabled, all functions return
   --  the input unchanged.

   type Mode is (Auto, Always, Never);

   procedure Set_Mode (M : Mode);
   function Current_Mode return Mode;

   function Bold    (S : String) return String;  --  header emphasis
   function Dim     (S : String) return String;  --  secondary text
   function Green   (S : String) return String;  --  success, ok
   function Red     (S : String) return String;  --  error
   function Yellow  (S : String) return String;  --  warning
   function Cyan    (S : String) return String;  --  commands, arguments
   function Magenta (S : String) return String;  --  options

end UML2Code.CLI.Colors;
