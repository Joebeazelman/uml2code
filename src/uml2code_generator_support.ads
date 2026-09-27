with Ada.Containers.Indefinite_Ordered_Sets;
with Jintp;

package Uml2Code_Generator_Support is

   package String_Sets is
     new Ada.Containers.Indefinite_Ordered_Sets (String);

   --  Render Subdir/Template and return the resulting string.
   function Render_Dict
     (Subdir   : String;
      Template : String;
      D        : Jintp.Dictionary;
      Env      : in out Jintp.Environment) return String;

   --  Render Subdir/Template and write the result to Output.
   procedure Render_To_Dict
     (Subdir   : String;
      Template : String;
      Output   : String;
      D        : Jintp.Dictionary;
      Env      : in out Jintp.Environment);

   --  As Render_To_Dict, but leaves an existing Output untouched.
   procedure Render_If_Missing_Dict
     (Subdir   : String;
      Template : String;
      Output   : String;
      D        : Jintp.Dictionary;
      Env      : in out Jintp.Environment);

   --  Safety net: refuse to write generated output into the tool's
   --  own source or test trees. Raises Constraint_Error.
   procedure Refuse_Crate_Internal_Output (Out_Dir : String);

end Uml2Code_Generator_Support;
