package body Address_Resolution_Machine is


   function Current_State (Self : Machine) return State is
   begin
      return Self.Current;
   end Current_State;

   procedure Reset (Self : in out Machine) is
   begin
      Self.Current := Check_Default_Address;

   end Reset;

   type Transition_Result is record
      Has_Transition : Boolean;
      Target         : State;
      Is_Terminal    : Boolean;
   end record;

   type Transition_Table is array (State, Event) of Transition_Result;

   Table : constant Transition_Table :=
       [Check_Default_Address => [Command_Sent => (Has_Transition => True, Target => Await_Default_Response, Is_Terminal => False), Relocation_Command_Sent => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Repeat_For_Remaining_Devices => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Response_Detected => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Timeout_No_Devices => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Winner_Data_Received => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False)],
      Await_Default_Response => [Command_Sent => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Relocation_Command_Sent => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Repeat_For_Remaining_Devices => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Response_Detected => (Has_Transition => True, Target => Relocate_Devices, Is_Terminal => False), Timeout_No_Devices => (Has_Transition => True, Target => Check_Default_Address, Is_Terminal => True), Winner_Data_Received => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False)],
      Relocate_Devices => [Command_Sent => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Relocation_Command_Sent => (Has_Transition => True, Target => Resolve_Collisions, Is_Terminal => False), Repeat_For_Remaining_Devices => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Response_Detected => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Timeout_No_Devices => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Winner_Data_Received => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False)],
      Resolve_Collisions => [Command_Sent => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Relocation_Command_Sent => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Repeat_For_Remaining_Devices => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Response_Detected => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Timeout_No_Devices => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Winner_Data_Received => (Has_Transition => True, Target => Validate_Winner, Is_Terminal => False)],
      Validate_Winner => [Command_Sent => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Relocation_Command_Sent => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Repeat_For_Remaining_Devices => (Has_Transition => True, Target => Check_Default_Address, Is_Terminal => False), Response_Detected => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Timeout_No_Devices => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False), Winner_Data_Received => (Has_Transition => False, Target => Check_Default_Address, Is_Terminal => False)]];

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


end Address_Resolution_Machine;
