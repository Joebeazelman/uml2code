with AUnit.Test_Cases; use AUnit.Test_Cases;
with AUnit.Test_Suites;

package {{ name|ada }}_Tests is

   type Test is new Test_Case with null record;

   overriding function Name (T : Test) return AUnit.Message_String;
   overriding procedure Register_Tests (T : in out Test);

   procedure Test_Construct (T : in out Test_Case'Class);
{% for op in operations %}   procedure Test_{{ op.name|ada }} (T : in out Test_Case'Class);
{% endfor %}
   function Suite return AUnit.Test_Suites.Access_Test_Suite;

end {{ name|ada }}_Tests;
