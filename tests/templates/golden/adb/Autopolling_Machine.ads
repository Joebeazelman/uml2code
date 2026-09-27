--  State machine generated from examples/adb_protocol.puml
--  2026-09-27
--  examples/adb_protocol.puml

with State_Machine;

package Autopolling_Machine is

   type State is
       (Select_Next_Target, Send_Poll_Command, Await_Poll_Response, Route_Poll_Data);

   type Event is
       (Command_Sent, Payload_Received, Target_Selected, Timeout_Normal_No_Data);

   type Machine is new State_Machine.Machine with record
      Current : State := Select_Next_Target;

   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);


end Autopolling_Machine;
