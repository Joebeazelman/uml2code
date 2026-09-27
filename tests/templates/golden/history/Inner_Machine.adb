package body Inner_Machine is

   procedure Entered_A is null;

   procedure Entered_B is null;


   function Current_State (Self : Machine) return State is
   begin
      return Self.Current;
   end Current_State;

   procedure Reset (Self : in out Machine) is
   begin
      Self.Current := A;

   end Reset;

   type Transition_Result is record
      Has_Transition : Boolean;
      Target         : State;
      Is_Terminal    : Boolean;
   end record;

   type Transition_Table is array (State, Event) of Transition_Result;

   Table : constant Transition_Table :=
       [A => [Advance => (Has_Transition => True, Target => B, Is_Terminal => False)],
      B => [Advance => (Has_Transition => False, Target => A, Is_Terminal => False)]];

   procedure Step (Self : in out Machine; Evt : Event) is
      Current_Transition : constant Transition_Result :=
        Table (Self.Current, Evt);
   begin
      --  Exit actions
      case Self.Current is
            when others => null;
   
      end case;

      --  Internal transitions (checked before state change)
      case Self.Current is
            when others => null;
   
      end case;

   --  Do activities run while their state remains active.
   case Self.Current is
            when others => null;
   
   end case;

      --  State transition
   if Current_Transition.Has_Transition then
         --  Check if transitioning to terminal state
      if Current_Transition.Is_Terminal then
            State_Machine.Mark_Terminated (Self);
            return;
         end if;




         Self.Current := Current_Transition.Target;

         --  Entry actions
         case Self.Current is
            when A =>

               Entered_A;
            when B =>

               Entered_B;

         end case;
      end if;
   end Step;


end Inner_Machine;
