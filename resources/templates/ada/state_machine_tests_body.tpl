with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases.Registration;
with {{ name|ada }}; use {{ name|ada }};

package body {{ name|ada }}_Tests is

   overriding function Name (T : Test) return AUnit.Message_String is
     (AUnit.Format ("{{ name|ada }}"));

   overriding procedure Register_Tests (T : in out Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Each_TransitionAccess,
                        "every declared transition is reachable");
      Register_Routine (T, Test_Unknown_EventAccess,
                        "unknown event leaves state unchanged");
   end Register_Tests;

   procedure Test_Each_Transition (T : in out Test_CaseClass) is
      pragma Unreferenced (T);
   begin
{% for t in transitions %}      Assert
        (Next_State ({{ t.source|ada }}, "{{ t.event }}") = {{ t.target|ada }},
         "{{ t.source|ada }} + {{ t.event }} -> {{ t.target|ada }}");
{% endfor %}   end Test_Each_Transition;

   procedure Test_Unknown_Event (T : in out Test_CaseClass) is
      pragma Unreferenced (T);
{% for s in states %}      Assert (Next_State ({{ s.name|ada }}, "nonexistent_event") = {{ s.name|ada }},
              "{{ s.name|ada }} unchanged by unknown event");
{% endfor %}   end Test_Unknown_Event;

   The_Test : aliased Test;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      Result.Add_Test (The_TestAccess);
      return Result;
   end Suite;

end {{ name|ada }}_Tests;
