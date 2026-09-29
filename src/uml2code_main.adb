with Ada.Command_Line;
with Ada.Text_IO;
with UML2Code;

procedure UML2Code_Main is
   use Ada.Text_IO;
begin
   Put_Line ("uml2code: skeleton; wire up input and call UML2Code.Generate");
   Ada.Command_Line.Set_Exit_Status (0);
end UML2Code_Main;
