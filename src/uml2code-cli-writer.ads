with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package UML2Code.CLI.Writer is

   --  Split a generated buffer at "package X is" or "package body X
   --  is" boundaries and write each chunk to its own file under
   --  Dir, using GNAT naming (X -> x.ads or x.adb). Subpackage
   --  names use hyphens (Foo.Bar -> foo-bar.ads).

   procedure Write_Buffers
     (Dir       : String;
      Code_Spec : Unbounded_String;
      Code_Body : Unbounded_String;
      Test_Spec : Unbounded_String;
      Test_Body : Unbounded_String;
      Dry_Run   : Boolean);

end UML2Code.CLI.Writer;
