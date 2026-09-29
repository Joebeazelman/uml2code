with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with UML_Model.Source;      use UML_Model.Source;

package UML2Code.Paths is

   type Search_Result (Success : Boolean) is record
      case Success is
         when True  => Root  : Unbounded_String;
         when False => Error : Source_Error;
      end case;
   end record;

   function Find_Templates_Root return Search_Result;

   function Find_Executable_Dir return String;

end UML2Code.Paths;
