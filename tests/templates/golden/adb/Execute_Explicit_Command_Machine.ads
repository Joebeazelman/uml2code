--  State machine generated from examples/adb_protocol.puml
--  2026-09-27
--  examples/adb_protocol.puml

with State_Machine;

package Execute_Explicit_Command_Machine is

   type State is
       (Transmit_Explicit, Await_Explicit, Delegate_Explicit);

   type Event is
       (Data_Received, Is_Listen_Or_Flush_Command, Is_Talk_Command, Timeout_Transaction_Failed);

   type Machine is new State_Machine.Machine with record
      Current : State := Transmit_Explicit;

   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);


end Execute_Explicit_Command_Machine;
