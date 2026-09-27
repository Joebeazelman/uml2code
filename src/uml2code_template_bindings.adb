with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;

with UML.Model;                use UML.Model;


package body Uml2Code_Template_Bindings is

   function Id_Of (D : UML.Model.Diagram; Idx : Element_Index)
                   return String is
   begin
      if Idx = 0 or else Positive (Idx) > Natural (D.Elements.Length) then
         return "";
      end if;
      return To_String (D.Elements (Positive (Idx)).Id);
   end Id_Of;

   --  ---------------------------------------------------------------
   --  States
   --  ---------------------------------------------------------------
   function For_States
     (D : UML.Model.Diagram) return Jintp.Dictionary
   is
      use Jintp;
      Dict : Dictionary;
      State_List : List;
      Trans_List : List;
   begin
      Insert (Dict, "diagram_name", To_String (D.Id));
      
      -- Build structured state list (excluding pseudo states)
      for S of D.Elements loop
         -- Skip pseudo states: they're implementation details, not user states
         if S.Kind not in UML.Model.Start_Pseudostate
                      | UML.Model.End_Pseudostate
                      | UML.Model.History_Shallow
                      | UML.Model.History_Deep
         then
            declare
               State_Dict : Dictionary;
            begin
               Insert (State_Dict, "id", To_String (S.Id));
               Insert (State_Dict, "kind", S.Kind'Image);
               Insert (State_Dict, "display", To_String (S.Display));
               Append (State_List, State_Dict);
            end;
         end if;
      end loop;
      Insert (Dict, "states", State_List);
      
      -- Build structured transition list
      for R of D.Relations loop
         if R.Kind in Transition | Internal_Transition_Kind | Completion then
            declare
               Trans_Dict : Dictionary;
            begin
               Insert (Trans_Dict, "from", Id_Of (D, R.From));
               Insert (Trans_Dict, "to", Id_Of (D, R.To));
               Insert (Trans_Dict, "kind", R.Kind'Image);
               Insert (Trans_Dict, "trigger", To_String (R.Trigger));
               Insert (Trans_Dict, "guard", To_String (R.Guard));
               Insert (Trans_Dict, "effect", To_String (R.Effect));
               Append (Trans_List, Trans_Dict);
            end;
         end if;
      end loop;
      Insert (Dict, "transitions", Trans_List);
      
      return Dict;
   end For_States;

   --  ---------------------------------------------------------------
   --  Classes
   --  ---------------------------------------------------------------
   function For_Classes
     (D : UML.Model.Diagram) return Jintp.Dictionary
   is
      use Jintp;
      Dict : Dictionary;
      Class_List : List;
      Rel_List : List;
   begin
      Insert (Dict, "diagram_name", To_String (D.Id));
      
      -- Build structured class list
      for K of D.Elements loop
         declare
            Class_Dict : Dictionary;
         begin
            Insert (Class_Dict, "id", To_String (K.Id));
            Insert (Class_Dict, "kind", K.Kind'Image);
            Insert (Class_Dict, "display", To_String (K.Display));
            Append (Class_List, Class_Dict);
         end;
      end loop;
      Insert (Dict, "classes", Class_List);
      
      -- Build structured relationship list
      for R of D.Relations loop
         declare
            Rel_Dict : Dictionary;
         begin
            Insert (Rel_Dict, "from", Id_Of (D, R.From));
            Insert (Rel_Dict, "to", Id_Of (D, R.To));
            Insert (Rel_Dict, "kind", R.Kind'Image);
            Insert (Rel_Dict, "label", To_String (R.Label));
            Insert (Rel_Dict, "mult_to", To_String (R.Mult_To));
            Append (Rel_List, Rel_Dict);
         end;
      end loop;
      Insert (Dict, "relations", Rel_List);
      
      return Dict;
   end For_Classes;

end Uml2Code_Template_Bindings;
