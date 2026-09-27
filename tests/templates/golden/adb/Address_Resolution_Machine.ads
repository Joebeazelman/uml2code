--  State machine generated from examples/adb_protocol.puml
--  2026-09-27
--  examples/adb_protocol.puml

with State_Machine;

package Address_Resolution_Machine is

   type State is
       (Check_Default_Address, Await_Default_Response, Relocate_Devices, Resolve_Collisions, Validate_Winner);

   type Event is
       (Command_Sent, Relocation_Command_Sent, Repeat_For_Remaining_Devices, Response_Detected, Timeout_No_Devices, Winner_Data_Received);

   type Machine is new State_Machine.Machine with record
      Current : State := Check_Default_Address;

   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);


end Address_Resolution_Machine;
