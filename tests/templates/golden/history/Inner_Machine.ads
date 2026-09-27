--  State machine generated from examples/history.puml
--  2026-09-27
--  examples/history.puml

with State_Machine;

package Inner_Machine is

   type State is
       (A, B);

   type Event is
       (Advance);

   type Machine is new State_Machine.Machine with record
      Current : State := A;

   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);


end Inner_Machine;
