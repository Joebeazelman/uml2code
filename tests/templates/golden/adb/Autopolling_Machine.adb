package body Autopolling_Machine is


   function Current_State (Self : Machine) return State is
   begin
      return Self.Current;
   end Current_State;

   procedure Reset (Self : in out Machine) is
   begin
      Self.Current := Select_Next_Target;

   end Reset;

   type Transition_Result is record
      Has_Transition : Boolean;
      Target         : State;
      Is_Terminal    : Boolean;
   end record;

   type Transition_Table is array (State, Event) of Transition_Result;

   Table : constant Transition_Table :=
       [Select_Next_Target => [Command_Sent => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False), Payload_Received => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False), Target_Selected => (Has_Transition => True, Target => Send_Poll_Command, Is_Terminal => False), Timeout_Normal_No_Data => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False)],
      Send_Poll_Command => [Command_Sent => (Has_Transition => True, Target => Await_Poll_Response, Is_Terminal => False), Payload_Received => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False), Target_Selected => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False), Timeout_Normal_No_Data => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False)],
      Await_Poll_Response => [Command_Sent => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False), Payload_Received => (Has_Transition => True, Target => Route_Poll_Data, Is_Terminal => False), Target_Selected => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False), Timeout_Normal_No_Data => (Has_Transition => True, Target => Select_Next_Target, Is_Terminal => True)],
      Route_Poll_Data => [Command_Sent => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False), Payload_Received => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False), Target_Selected => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False), Timeout_Normal_No_Data => (Has_Transition => False, Target => Select_Next_Target, Is_Terminal => False)]];

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


end Autopolling_Machine;
