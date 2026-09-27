--  State machine generated from examples/adb_protocol.puml
--  2026-09-27
--  examples/adb_protocol.puml
--  Apple Desktop Bus (ADB) Host Protocol Operations

with ADB_Reset_Machine;
with Address_Resolution_Machine;
with Execute_Explicit_Command_Machine;
with Autopolling_Machine;
with SRQ_Resolution_Machine;
with State_Machine;

package Machine is

   type State is
       (Adb_Reset, Address_Resolution, Bus_Idle, Execute_Explicit_Command, Autopolling, Evaluate_Srq, Srq_Resolution);

   type Event is
       (Bus_Enumerated, Command_Queued, Poll_Interval_Reached_And_Queue_Empty, Reset_Complete, Srq_Asserted, Srq_Cleared, Srq_Not_Asserted, Transaction_Complete);

   type Machine is new State_Machine.Machine with record
      Current : State := Adb_Reset;
      ADB_Reset_Child : ADB_Reset_Machine.Machine;      Address_Resolution_Child : Address_Resolution_Machine.Machine;      Execute_Explicit_Command_Child : Execute_Explicit_Command_Machine.Machine;      Autopolling_Child : Autopolling_Machine.Machine;      SRQ_Resolution_Child : SRQ_Resolution_Machine.Machine;
   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);

   function Adb_Reset_State (Self : Machine) return ADB_Reset_Machine.State;
   procedure Step_Adb_Reset (Self : in out Machine; Evt : ADB_Reset_Machine.Event);
   function Address_Resolution_State (Self : Machine) return Address_Resolution_Machine.State;
   procedure Step_Address_Resolution (Self : in out Machine; Evt : Address_Resolution_Machine.Event);
   function Execute_Explicit_Command_State (Self : Machine) return Execute_Explicit_Command_Machine.State;
   procedure Step_Execute_Explicit_Command (Self : in out Machine; Evt : Execute_Explicit_Command_Machine.Event);
   function Autopolling_State (Self : Machine) return Autopolling_Machine.State;
   procedure Step_Autopolling (Self : in out Machine; Evt : Autopolling_Machine.Event);
   function Srq_Resolution_State (Self : Machine) return SRQ_Resolution_Machine.State;
   procedure Step_Srq_Resolution (Self : in out Machine; Evt : SRQ_Resolution_Machine.Event);

end Machine;
