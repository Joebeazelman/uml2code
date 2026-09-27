--  State machine generated from examples/history.puml
--  2026-09-27
--  examples/history.puml

with Inner_Machine;
with State_Machine;

package Middle_Machine is

   type State is
       (Inner);

   type Event is
       (Tick);

   type Machine is new State_Machine.Machine with record
      Current : State := Inner;
      Inner_Child : Inner_Machine.Machine;
   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);

   function Inner_State (Self : Machine) return Inner_Machine.State;
   procedure Step_Inner (Self : in out Machine; Evt : Inner_Machine.Event);

end Middle_Machine;
