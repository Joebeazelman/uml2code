with Ada.Command_Line;
with UML2Code.CLI;

procedure UML2Code_Main is
begin
   Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Exit_Status
                                     (UML2Code.CLI.Run));
end UML2Code_Main;
