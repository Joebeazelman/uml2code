package body Running_Machine is

   procedure Halt is null;

   procedure Poll is null;


   function Current_State (Self : Machine) return State is
   begin
      return Self.Current;
   end Current_State;

   procedure Reset (Self : in out Machine) is
   begin
      Self.Current := Spinning;

   end Reset;

   type Transition_Result is record
      Has_Transition : Boolean;
      Target         : State;
      Is_Terminal    : Boolean;
   end record;

   type Transition_Table is array (State, Event) of Transition_Result;

   Table : constant Transition_Table :=
       [Spinning => [Pause => (Has_Transition => False, Target => Spinning, Is_Terminal => False), Resume => (Has_Transition => False, Target => Spinning, Is_Terminal => False), Yield => (Has_Transition => True, Target => Waiting, Is_Terminal => False)],
      Waiting => [Pause => (Has_Transition => False, Target => Spinning, Is_Terminal => False), Resume => (Has_Transition => True, Target => Spinning, Is_Terminal => False), Yield => (Has_Transition => False, Target => Spinning, Is_Terminal => False)]];

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
            when Spinning =>
   
            if Evt = Pause then
               Halt;
               return;
            end if;
            when others => null;
   
      end case;

   --  Do activities run while their state remains active.
   case Self.Current is
            when Spinning =>
   
      Poll;
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


end Running_Machine;
