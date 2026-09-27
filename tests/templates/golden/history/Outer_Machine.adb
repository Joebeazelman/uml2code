package body Outer_Machine is


   function Current_State (Self : Machine) return State is
   begin
      return Self.Current;
   end Current_State;

   procedure Reset (Self : in out Machine) is
   begin
      Self.Current := Middle;
      Middle_Machine.Reset (Self.Middle_Child);
   end Reset;

   type Transition_Result is record
      Has_Transition : Boolean;
      Target         : State;
      Is_Terminal    : Boolean;
   end record;

   type Transition_Table is array (State, Event) of Transition_Result;

   Table : constant Transition_Table :=
       [Middle => [Tick => (Has_Transition => False, Target => Middle, Is_Terminal => False)]];

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


   function Middle_State (Self : Machine) return Middle_Machine.State is
   begin
      return Middle_Machine.Current_State (Self.Middle_Child);
   end Middle_State;

   procedure Step_Middle (Self : in out Machine; Evt : Middle_Machine.Event) is
   begin
      Middle_Machine.Step (Self.Middle_Child, Evt);
   end Step_Middle;


end Outer_Machine;
