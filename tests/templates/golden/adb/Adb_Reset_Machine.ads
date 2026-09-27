--  State machine generated from examples/adb_protocol.puml
--  2026-09-27
--  examples/adb_protocol.puml

with State_Machine;

package Adb_Reset_Machine is

   type State is
       (Send_Reset_Cmd);

   type Event is
       (Tick);

   type Machine is new State_Machine.Machine with record
      Current : State := Send_Reset_Cmd;

   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);


end Adb_Reset_Machine;
