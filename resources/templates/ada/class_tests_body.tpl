with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases.Registration;
with {{ name|ada }}; use {{ name|ada }};

package body {{ name|ada }}_Tests is

   overriding function Name (T : Test) return AUnit.Message_String is
     (AUnit.Format ("{{ name|ada }}"));

   overriding procedure Register_Tests (T : in out Test) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Construct'Access,
                        "construct the record");
{% for op in operations %}      Register_Routine (T, Test_{{ op.name|ada }}'Access,
                        "{{ op.name }}");
{% endfor %}   end Register_Tests;

   procedure Test_Construct (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
      X : {{ name|ada }}_T;
   begin
      --  Assign each field a sample value as you develop.
      --  X.<field> := <value>;
      Assert (True, "record constructed");
   end Test_Construct;
{% for op in operations %}
   procedure Test_{{ op.name|ada }} (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      --  Call {{ op.name }} once its stub body is replaced with a
      --  real implementation.
      Assert (True, "{{ op.name }} declared");
   end Test_{{ op.name|ada }};
{% endfor %}
   The_Test : aliased Test;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      Result.Add_Test (The_Test'Access);
      return Result;
   end Suite;

end {{ name|ada }}_Tests;
