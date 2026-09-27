--  State machine generated from examples/nested.puml
--  2026-09-27
--  examples/nested.puml

with State_Machine;

package Running_Machine is

   type State is
       (Spinning, Waiting);

   type Event is
       (Pause, Resume, Yield);

   type Machine is new State_Machine.Machine with record
      Current : State := Spinning;

   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);


end Running_Machine;
