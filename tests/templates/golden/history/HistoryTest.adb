package body HistoryTest is


   function Current_State (Self : Machine) return State is
   begin
      return Self.Current;
   end Current_State;

   procedure Reset (Self : in out Machine) is
   begin
      Self.Current := Idle;
      Outer_Machine.Reset (Self.Outer_Child);
   end Reset;

   type Transition_Result is record
      Has_Transition : Boolean;
      Target         : State;
      Is_Terminal    : Boolean;
   end record;

   type Transition_Table is array (State, Event) of Transition_Result;

   Table : constant Transition_Table :=
       [Idle => [Back => (Has_Transition => False, Target => Idle, Is_Terminal => False), Enter_Deep => (Has_Transition => False, Target => Idle, Is_Terminal => False), Enter_Fresh => (Has_Transition => True, Target => Outer, Is_Terminal => False), Enter_Shallow => (Has_Transition => False, Target => Idle, Is_Terminal => False)],
      Outer => [Back => (Has_Transition => True, Target => Idle, Is_Terminal => False), Enter_Deep => (Has_Transition => False, Target => Idle, Is_Terminal => False), Enter_Fresh => (Has_Transition => False, Target => Idle, Is_Terminal => False), Enter_Shallow => (Has_Transition => False, Target => Idle, Is_Terminal => False)]];

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


         --  Reset child machine on entry to composite state
         declare
            function Is_Entering
              (Current, Target, Candidate : State) return Boolean
            is
            begin
               return Target = Candidate and then Current /= Candidate;
            end Is_Entering;
         begin
            if Is_Entering
              (Self.Current,
               Current_Transition.Target,
               Outer)
            then
            declare
               Via_History : constant Boolean := False;  --  TODO: implement history
            begin
               if not Via_History then
                  Outer_Machine.Reset (Self.Outer_Child);
               end if;
            end;
         end if;
         end;


         Self.Current := Current_Transition.Target;

         --  Entry actions
         case Self.Current is
            when others => null;

         end case;
      end if;
   end Step;


   function Outer_State (Self : Machine) return Outer_Machine.State is
   begin
      return Outer_Machine.Current_State (Self.Outer_Child);
   end Outer_State;

   procedure Step_Outer (Self : in out Machine; Evt : Outer_Machine.Event) is
   begin
      Outer_Machine.Step (Self.Outer_Child, Evt);
   end Step_Outer;


end HistoryTest;
