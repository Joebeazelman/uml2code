package body Machine is


   function Current_State (Self : Machine) return State is
   begin
      return Self.Current;
   end Current_State;

   procedure Reset (Self : in out Machine) is
   begin
      Self.Current := Adb_Reset;
      ADB_Reset_Machine.Reset (Self.ADB_Reset_Child);      Address_Resolution_Machine.Reset (Self.Address_Resolution_Child);      Execute_Explicit_Command_Machine.Reset (Self.Execute_Explicit_Command_Child);      Autopolling_Machine.Reset (Self.Autopolling_Child);      SRQ_Resolution_Machine.Reset (Self.SRQ_Resolution_Child);
   end Reset;

   type Transition_Result is record
      Has_Transition : Boolean;
      Target         : State;
      Is_Terminal    : Boolean;
   end record;

   type Transition_Table is array (State, Event) of Transition_Result;

   Table : constant Transition_Table :=
       [Adb_Reset => [Bus_Enumerated => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Command_Queued => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Poll_Interval_Reached_And_Queue_Empty => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Reset_Complete => (Has_Transition => True, Target => Address_Resolution, Is_Terminal => False), Srq_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Cleared => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Not_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Transaction_Complete => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False)],
      Address_Resolution => [Bus_Enumerated => (Has_Transition => True, Target => Bus_Idle, Is_Terminal => False), Command_Queued => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Poll_Interval_Reached_And_Queue_Empty => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Reset_Complete => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Cleared => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Not_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Transaction_Complete => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False)],
      Bus_Idle => [Bus_Enumerated => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Command_Queued => (Has_Transition => True, Target => Execute_Explicit_Command, Is_Terminal => False), Poll_Interval_Reached_And_Queue_Empty => (Has_Transition => True, Target => Autopolling, Is_Terminal => False), Reset_Complete => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Cleared => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Not_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Transaction_Complete => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False)],
      Execute_Explicit_Command => [Bus_Enumerated => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Command_Queued => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Poll_Interval_Reached_And_Queue_Empty => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Reset_Complete => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Cleared => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Not_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Transaction_Complete => (Has_Transition => True, Target => Evaluate_Srq, Is_Terminal => False)],
      Autopolling => [Bus_Enumerated => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Command_Queued => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Poll_Interval_Reached_And_Queue_Empty => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Reset_Complete => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Cleared => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Not_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Transaction_Complete => (Has_Transition => True, Target => Evaluate_Srq, Is_Terminal => False)],
      Evaluate_Srq => [Bus_Enumerated => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Command_Queued => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Poll_Interval_Reached_And_Queue_Empty => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Reset_Complete => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Asserted => (Has_Transition => True, Target => Srq_Resolution, Is_Terminal => False), Srq_Cleared => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Not_Asserted => (Has_Transition => True, Target => Bus_Idle, Is_Terminal => False), Transaction_Complete => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False)],
      Srq_Resolution => [Bus_Enumerated => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Command_Queued => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Poll_Interval_Reached_And_Queue_Empty => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Reset_Complete => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Srq_Cleared => (Has_Transition => True, Target => Bus_Idle, Is_Terminal => False), Srq_Not_Asserted => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False), Transaction_Complete => (Has_Transition => False, Target => Adb_Reset, Is_Terminal => False)]];

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
               Adb_Reset)
            then
            declare
               Via_History : constant Boolean := False;  --  TODO: implement history
            begin
               if not Via_History then
                  ADB_Reset_Machine.Reset (Self.ADB_Reset_Child);
               end if;
            end;
         end if;
         end;
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
               Address_Resolution)
            then
            declare
               Via_History : constant Boolean := False;  --  TODO: implement history
            begin
               if not Via_History then
                  Address_Resolution_Machine.Reset (Self.Address_Resolution_Child);
               end if;
            end;
         end if;
         end;
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
               Execute_Explicit_Command)
            then
            declare
               Via_History : constant Boolean := False;  --  TODO: implement history
            begin
               if not Via_History then
                  Execute_Explicit_Command_Machine.Reset (Self.Execute_Explicit_Command_Child);
               end if;
            end;
         end if;
         end;
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
               Autopolling)
            then
            declare
               Via_History : constant Boolean := False;  --  TODO: implement history
            begin
               if not Via_History then
                  Autopolling_Machine.Reset (Self.Autopolling_Child);
               end if;
            end;
         end if;
         end;
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
               Srq_Resolution)
            then
            declare
               Via_History : constant Boolean := False;  --  TODO: implement history
            begin
               if not Via_History then
                  SRQ_Resolution_Machine.Reset (Self.SRQ_Resolution_Child);
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


   function Adb_Reset_State (Self : Machine) return ADB_Reset_Machine.State is
   begin
      return ADB_Reset_Machine.Current_State (Self.ADB_Reset_Child);
   end Adb_Reset_State;

   procedure Step_Adb_Reset (Self : in out Machine; Evt : ADB_Reset_Machine.Event) is
   begin
      ADB_Reset_Machine.Step (Self.ADB_Reset_Child, Evt);
   end Step_Adb_Reset;


   function Address_Resolution_State (Self : Machine) return Address_Resolution_Machine.State is
   begin
      return Address_Resolution_Machine.Current_State (Self.Address_Resolution_Child);
   end Address_Resolution_State;

   procedure Step_Address_Resolution (Self : in out Machine; Evt : Address_Resolution_Machine.Event) is
   begin
      Address_Resolution_Machine.Step (Self.Address_Resolution_Child, Evt);
   end Step_Address_Resolution;


   function Execute_Explicit_Command_State (Self : Machine) return Execute_Explicit_Command_Machine.State is
   begin
      return Execute_Explicit_Command_Machine.Current_State (Self.Execute_Explicit_Command_Child);
   end Execute_Explicit_Command_State;

   procedure Step_Execute_Explicit_Command (Self : in out Machine; Evt : Execute_Explicit_Command_Machine.Event) is
   begin
      Execute_Explicit_Command_Machine.Step (Self.Execute_Explicit_Command_Child, Evt);
   end Step_Execute_Explicit_Command;


   function Autopolling_State (Self : Machine) return Autopolling_Machine.State is
   begin
      return Autopolling_Machine.Current_State (Self.Autopolling_Child);
   end Autopolling_State;

   procedure Step_Autopolling (Self : in out Machine; Evt : Autopolling_Machine.Event) is
   begin
      Autopolling_Machine.Step (Self.Autopolling_Child, Evt);
   end Step_Autopolling;


   function Srq_Resolution_State (Self : Machine) return SRQ_Resolution_Machine.State is
   begin
      return SRQ_Resolution_Machine.Current_State (Self.SRQ_Resolution_Child);
   end Srq_Resolution_State;

   procedure Step_Srq_Resolution (Self : in out Machine; Evt : SRQ_Resolution_Machine.Event) is
   begin
      SRQ_Resolution_Machine.Step (Self.SRQ_Resolution_Child, Evt);
   end Step_Srq_Resolution;


end Machine;
