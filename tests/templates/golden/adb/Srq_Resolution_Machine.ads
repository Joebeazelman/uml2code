--  State machine generated from examples/adb_protocol.puml
--  2026-09-27
--  examples/adb_protocol.puml

with State_Machine;

package Srq_Resolution_Machine is

   type State is
       (Identify_Source, Route_Srq);

   type Event is
       (Data_Received, Srq_Line_Cleared, Timeout_Try_Next_Address);

   type Machine is new State_Machine.Machine with record
      Current : State := Identify_Source;

   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);


end Srq_Resolution_Machine;
