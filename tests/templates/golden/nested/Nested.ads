--  State machine generated from examples/nested.puml
--  2026-09-27
--  examples/nested.puml

with Running_Machine;
with State_Machine;

package Nested is

   type State is
       (Idle, Running);

   type Event is
       (Continue, Finish, Start, Stop, Tick);

   type Machine is new State_Machine.Machine with record
      Current : State := Idle;
      Running_Child : Running_Machine.Machine;
   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);

   function Running_State (Self : Machine) return Running_Machine.State;
   procedure Step_Running (Self : in out Machine; Evt : Running_Machine.Event);

end Nested;
