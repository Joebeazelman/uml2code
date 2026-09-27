--  State machine generated from examples/history.puml
--  2026-09-27
--  examples/history.puml

with Outer_Machine;
with State_Machine;

package HistoryTest is

   type State is
       (Idle, Outer);

   type Event is
       (Back, Enter_Deep, Enter_Fresh, Enter_Shallow);

   type Machine is new State_Machine.Machine with record
      Current : State := Idle;
      Outer_Child : Outer_Machine.Machine;
   end record;

   function Current_State (Self : Machine) return State;
   procedure Step (Self : in out Machine; Evt : Event);
   procedure Reset (Self : in out Machine);

   function Outer_State (Self : Machine) return Outer_Machine.State;
   procedure Step_Outer (Self : in out Machine; Evt : Outer_Machine.Event);

end HistoryTest;
