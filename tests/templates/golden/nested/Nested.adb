package body Nested is

   procedure Bump is null;

   procedure Cleanup_Idle is null;

   procedure Log_Idle is null;


   function Current_State (Self : Machine) return State is
   begin
      return Self.Current;
   end Current_State;

   procedure Reset (Self : in out Machine) is
   begin
      Self.Current := Idle;
      Running_Machine.Reset (Self.Running_Child);
   end Reset;

   type Transition_Result is record
      Has_Transition : Boolean;
      Target         : State;
      Is_Terminal    : Boolean;
   end record;

   type Transition_Table is array (State, Event) of Transition_Result;

   Table : constant Transition_Table :=
       [Idle => [Continue => (Has_Transition => False, Target => Idle, Is_Terminal => False), Finish => (Has_Transition => False, Target => Idle, Is_Terminal => False), Start => (Has_Transition => True, Target => Running, Is_Terminal => False), Stop => (Has_Transition => False, Target => Idle, Is_Terminal => False), Tick => (Has_Transition => False, Target => Idle, Is_Terminal => False)],
      Running => [Continue => (Has_Transition => False, Target => Idle, Is_Terminal => False), Finish => (Has_Transition => True, Target => Idle, Is_Terminal => True), Start => (Has_Transition => False, Target => Idle, Is_Terminal => False), Stop => (Has_Transition => True, Target => Idle, Is_Terminal => False), Tick => (Has_Transition => False, Target => Idle, Is_Terminal => False)]];

   procedure Step (Self : in out Machine; Evt : Event) is
      Current_Transition : constant Transition_Result :=
        Table (Self.Current, Evt);
   begin
      --  Exit actions
      case Self.Current is
            when Idle =>
   
            Cleanup_Idle;
            when others => null;
   
      end case;

      --  Internal transitions (checked before state change)
      case Self.Current is
            when Idle =>
   
            if Evt = Tick then
               Bump;
               return;
            end if;
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
               Running)
            then
            declare
               Via_History : constant Boolean := False;  --  TODO: implement history
            begin
               if not Via_History then
                  Running_Machine.Reset (Self.Running_Child);
               end if;
            end;
         end if;
         end;


         Self.Current := Current_Transition.Target;

         --  Entry actions
         case Self.Current is
            when Idle =>

               Log_Idle;
            when others => null;

         end case;
      end if;
   end Step;


   function Running_State (Self : Machine) return Running_Machine.State is
   begin
      return Running_Machine.Current_State (Self.Running_Child);
   end Running_State;

   procedure Step_Running (Self : in out Machine; Evt : Running_Machine.Event) is
   begin
      Running_Machine.Step (Self.Running_Child, Evt);
   end Step_Running;


end Nested;
