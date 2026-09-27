--  State machine generated from examples/history.puml
--  2026-09-27
--  examples/history.puml

with Middle_Machine;
with State_Machine;

package Outer_Machine is

   type State is
       (Middle);

   type Event is
       (Tick);

   type Machine is new State_Machine.Machine with record
      Current : State := Middle;
      Middle_Child : Middle_Machine.Machine;
   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);

   function Middle_State (Self : Machine) return Middle_Machine.State;
   procedure Step_Middle (Self : in out Machine; Evt : Middle_Machine.Event);

end Outer_Machine;
