package body Execute_Explicit_Command_Machine is


   function Current_State (Self : Machine) return State is
   begin
      return Self.Current;
   end Current_State;

   procedure Reset (Self : in out Machine) is
   begin
      Self.Current := Transmit_Explicit;

   end Reset;

   type Transition_Result is record
      Has_Transition : Boolean;
      Target         : State;
      Is_Terminal    : Boolean;
   end record;

   type Transition_Table is array (State, Event) of Transition_Result;

   Table : constant Transition_Table :=
       [Transmit_Explicit => [Data_Received => (Has_Transition => False, Target => Transmit_Explicit, Is_Terminal => False), Is_Listen_Or_Flush_Command => (Has_Transition => True, Target => Transmit_Explicit, Is_Terminal => True), Is_Talk_Command => (Has_Transition => True, Target => Await_Explicit, Is_Terminal => False), Timeout_Transaction_Failed => (Has_Transition => False, Target => Transmit_Explicit, Is_Terminal => False)],
      Await_Explicit => [Data_Received => (Has_Transition => True, Target => Delegate_Explicit, Is_Terminal => False), Is_Listen_Or_Flush_Command => (Has_Transition => False, Target => Transmit_Explicit, Is_Terminal => False), Is_Talk_Command => (Has_Transition => False, Target => Transmit_Explicit, Is_Terminal => False), Timeout_Transaction_Failed => (Has_Transition => True, Target => Transmit_Explicit, Is_Terminal => True)],
      Delegate_Explicit => [Data_Received => (Has_Transition => False, Target => Transmit_Explicit, Is_Terminal => False), Is_Listen_Or_Flush_Command => (Has_Transition => False, Target => Transmit_Explicit, Is_Terminal => False), Is_Talk_Command => (Has_Transition => False, Target => Transmit_Explicit, Is_Terminal => False), Timeout_Transaction_Failed => (Has_Transition => False, Target => Transmit_Explicit, Is_Terminal => False)]];

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
            when others => null;

         end case;
      end if;
   end Step;


end Execute_Explicit_Command_Machine;
