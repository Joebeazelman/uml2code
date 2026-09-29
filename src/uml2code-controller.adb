with Ada.Environment_Variables;
with Ada.Strings.Unbounded;   use Ada.Strings.Unbounded;
with Jintp;
with UML2Code.Casing;
with UML2Code.Filters;
with UML2Code.Manifests;
with UML2Code.Paths;
with UML_Model;
with UML_Model.Class;
with UML_Model.Elements;      use UML_Model.Elements;
with UML_Model.Models;
with UML_Model.Source;
with UML_Model.State_Machine;
with UML_Model.Types;

package body UML2Code.Controller is

   use UML_Model.Source;
   use UML_Model.Models;
   use UML_Model.Types;

   Quote : constant Character := '"';

   --  ---- Small helpers, in dependency order ----

   function Stereotype_List
     (Stereotypes : Stereotype_Vector) return Jintp.List
   is
      Result : Jintp.List;
   begin
      for S of Stereotypes loop
         Jintp.Append (Result, To_String (S));
      end loop;
      return Result;
   end Stereotype_List;

   --  Map a UML type name to an Ada type legal as a record component.
   function To_Ada_Type_Name (Name : String) return String is
   begin
      if Name = "String" or else Name = "string" then
         return "Unbounded_String";
      elsif Name = "Integer" or else Name = "integer" then
         return "Integer";
      elsif Name = "Boolean" or else Name = "boolean" then
         return "Boolean";
      elsif Name = "Float" or else Name = "float" then
         return "Float";
      elsif Name'Length = 0 then
         return "Integer";
      else
         return UML2Code.Casing.To_Ada_Case (Name);
      end if;
   end To_Ada_Type_Name;

   function Derives_From
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return String
   is
   begin
      for R of Relations loop
         if R.Kind = Inheritance and then R.Source = C.Name then
            return UML2Code.Casing.To_Ada_Case (To_String (R.Target));
         end if;
      end loop;
      return "";
   end Derives_From;

   function Is_Base
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Boolean
   is
   begin
      for R of Relations loop
         if R.Kind = Inheritance and then R.Target = C.Name then
            return True;
         end if;
      end loop;
      return False;
   end Is_Base;

   function With_Clauses
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Jintp.List
   is
      Result : Jintp.List;
      Base   : constant String := Derives_From (C, Relations);
   begin
      if Base'Length > 0 then
         Jintp.Append (Result, "with " & Base & ";");
      end if;
      return Result;
   end With_Clauses;

   function Type_Opening
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return String
   is
      Name : constant String :=
        UML2Code.Casing.To_Ada_Case (To_String (C.Name));
      Base : constant String := Derives_From (C, Relations);
   begin
      if Base'Length > 0 then
         return "type " & Name & "_T is new " & Base
                & "." & Base & "_T with record";
      elsif Is_Base (C, Relations) then
         return "type " & Name & "_T is tagged record";
      else
         return "type " & Name & "_T is record";
      end if;
   end Type_Opening;

   function Record_Body_Lines (C : UML_Model.Class.Class_Model)
     return Jintp.List
   is
      Result : Jintp.List;
      Any    : Boolean := False;
   begin
      for P of C.Attributes loop
         Any := True;
         Jintp.Append
           (Result,
            "      "
            & UML2Code.Casing.To_Snake_Case (To_String (P.Name))
            & " : "
            & To_Ada_Type_Name (To_String (P.Of_Type))
            & ";");
      end loop;
      if not Any then
         Jintp.Append (Result, "      null;");
      end if;
      return Result;
   end Record_Body_Lines;

   function State_Body_Expression
     (S           : UML_Model.State_Machine.State;
      Transitions : UML_Model.State_Machine.Transition_Vector)
     return String
   is
      function Cased (Id : Identifier) return String is
        (UML2Code.Casing.To_Ada_Case (To_String (Id)));

      Has_Outgoing : Boolean := False;
   begin
      for T of Transitions loop
         if T.Source = S.Name then
            Has_Outgoing := True;
            exit;
         end if;
      end loop;

      if not Has_Outgoing then
         return Cased (S.Name);
      end if;

      declare
         Result : Unbounded_String := To_Unbounded_String ("(");
         First  : Boolean := True;
      begin
         for T of Transitions loop
            if T.Source = S.Name then
               if First then
                  Append (Result, "if ");
                  First := False;
               else
                  Append (Result, "elsif ");
               end if;
               Append (Result, "Event = ");
               Append (Result, Quote);
               Append (Result, To_String (T.Event));
               Append (Result, Quote);
               Append (Result, " then ");
               Append (Result, Cased (T.Target));
               Append (Result, " ");
            end if;
         end loop;
         Append (Result, "else ");
         Append (Result, Cased (S.Name));
         Append (Result, ")");
         return To_String (Result);
      end;
   end State_Body_Expression;

   function Operation_Declaration (O : UML_Model.Class.Operation)
     return String
   is
      Result     : Unbounded_String;
      Has_Ret    : constant Boolean := Is_Valid (O.Return_Type.Name);
      Has_Params : constant Boolean := not O.Parameters.Is_Empty;
   begin
      if Has_Ret then
         Append (Result, "function ");
      else
         Append (Result, "procedure ");
      end if;
      Append (Result,
              UML2Code.Casing.To_Ada_Case (To_String (O.Name)));

      if Has_Params then
         Append (Result, " (");
         declare
            First : Boolean := True;
         begin
            for P of O.Parameters loop
               if not First then
                  Append (Result, "; ");
               end if;
               First := False;
               Append (Result,
                       UML2Code.Casing.To_Snake_Case
                         (To_String (P.Name)));
               Append (Result, " : ");
               Append (Result,
                       To_Ada_Type_Name (To_String (P.Of_Type)));
            end loop;
         end;
         Append (Result, ")");
      end if;

      if Has_Ret then
         Append (Result, " return ");
         Append (Result,
                 To_Ada_Type_Name (To_String (O.Return_Type)));
      end if;

      Append (Result, ";");
      return To_String (Result);
   end Operation_Declaration;

   --  ---- Dictionary construction ----

   function Property_Dictionary (P : UML_Model.Class.Property)
     return Jintp.Dictionary
   is
      D : Jintp.Dictionary;
   begin
      Jintp.Insert (D, "name",         To_String (P.Name));
      Jintp.Insert (D, "type",         To_String (P.Of_Type));
      Jintp.Insert (D, "visibility",
                    UML_Model.Class.Visibility'Image (P.Visibility));
      Jintp.Insert (D, "multiplicity", To_String (P.Multiplicity));
      Jintp.Insert (D, "default",      To_String (P.Default));
      Jintp.Insert (D, "stereotypes",  Stereotype_List (P.Stereotypes));
      return D;
   end Property_Dictionary;

   function Operation_Dictionary (O : UML_Model.Class.Operation)
     return Jintp.Dictionary
   is
      D      : Jintp.Dictionary;
      Params : Jintp.List;
   begin
      Jintp.Insert (D, "name",        To_String (O.Name));
      Jintp.Insert (D, "return_type", To_String (O.Return_Type));
      Jintp.Insert (D, "visibility",
                    UML_Model.Class.Visibility'Image (O.Visibility));
      Jintp.Insert (D, "stereotypes", Stereotype_List (O.Stereotypes));
      Jintp.Insert (D, "declaration", Operation_Declaration (O));
      Jintp.Insert (D, "has_parameters", not O.Parameters.Is_Empty);
      Jintp.Insert (D, "has_return", Is_Valid (O.Return_Type.Name));
      for P of O.Parameters loop
         Jintp.Append (Params, Property_Dictionary (P));
      end loop;
      Jintp.Insert (D, "parameters", Params);
      return D;
   end Operation_Dictionary;

   function Class_Dictionary
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Jintp.Dictionary
   is
      D     : Jintp.Dictionary;
      Attrs : Jintp.List;
      Ops   : Jintp.List;
   begin
      Jintp.Insert (D, "name",        To_String (C.Name));
      Jintp.Insert (D, "visibility",
                    UML_Model.Class.Visibility'Image (C.Visibility));
      Jintp.Insert (D, "stereotypes", Stereotype_List (C.Stereotypes));
      Jintp.Insert (D, "derives_from", Derives_From (C, Relations));
      Jintp.Insert (D, "with_clauses",
                    With_Clauses (C, Relations));
      Jintp.Insert (D, "type_opening", Type_Opening (C, Relations));
      Jintp.Insert (D, "record_body_lines",
                    Record_Body_Lines (C));
      for P of C.Attributes loop
         Jintp.Append (Attrs, Property_Dictionary (P));
      end loop;
      for O of C.Operations loop
         Jintp.Append (Ops, Operation_Dictionary (O));
      end loop;
      Jintp.Insert (D, "attributes", Attrs);
      Jintp.Insert (D, "operations", Ops);
      return D;
   end Class_Dictionary;

   function Relation_Dictionary (R : Relation) return Jintp.Dictionary is
      D : Jintp.Dictionary;
   begin
      Jintp.Insert (D, "kind",         Relation_Kind'Image (R.Kind));
      Jintp.Insert (D, "source",       To_String (R.Source));
      Jintp.Insert (D, "target",       To_String (R.Target));
      Jintp.Insert (D, "source_role",  To_String (R.Source_Role));
      Jintp.Insert (D, "target_role",  To_String (R.Target_Role));
      Jintp.Insert (D, "multiplicity", To_String (R.Multiplicity));
      Jintp.Insert (D, "stereotypes",  Stereotype_List (R.Stereotypes));
      return D;
   end Relation_Dictionary;

   function Transition_Dictionary (T : UML_Model.State_Machine.Transition)
     return Jintp.Dictionary
   is
      D : Jintp.Dictionary;
   begin
      Jintp.Insert (D, "source",      To_String (T.Source));
      Jintp.Insert (D, "target",      To_String (T.Target));
      Jintp.Insert (D, "event",       To_String (T.Event));
      Jintp.Insert (D, "guard",       To_String (T.Guard));
      Jintp.Insert (D, "action",      To_String (T.Action));
      Jintp.Insert (D, "stereotypes", Stereotype_List (T.Stereotypes));
      return D;
   end Transition_Dictionary;

   function State_Dictionary
     (S           : UML_Model.State_Machine.State;
      Transitions : UML_Model.State_Machine.Transition_Vector)
     return Jintp.Dictionary
   is
      D        : Jintp.Dictionary;
      Outgoing : Jintp.List;
   begin
      Jintp.Insert (D, "name",         To_String (S.Name));
      Jintp.Insert (D, "kind",
                    UML_Model.State_Machine.State_Kind'Image (S.Kind));
      Jintp.Insert (D, "parent",       To_String (S.Parent));
      Jintp.Insert (D, "entry_action", To_String (S.Entry_Action));
      Jintp.Insert (D, "exit_action",  To_String (S.Exit_Action));
      Jintp.Insert (D, "case_arm",
                    State_Body_Expression (S, Transitions));
      Jintp.Insert (D, "stereotypes",  Stereotype_List (S.Stereotypes));

      for T of Transitions loop
         if T.Source = S.Name then
            Jintp.Append (Outgoing, Transition_Dictionary (T));
         end if;
      end loop;

      Jintp.Insert (D, "outgoing", Outgoing);
      return D;
   end State_Dictionary;

   function State_Machine_Dictionary
     (M : UML_Model.State_Machine.State_Chart_Model) return Jintp.Dictionary
   is
      D  : Jintp.Dictionary;
      St : Jintp.List;
      Tr : Jintp.List;
   begin
      Jintp.Insert (D, "name",        To_String (M.Name));
      Jintp.Insert (D, "initial",     To_String (M.Initial));
      Jintp.Insert (D, "stereotypes", Stereotype_List (M.Stereotypes));
      for S of M.States loop
         Jintp.Append (St, State_Dictionary (S, M.Transitions));
      end loop;
      for T of M.Transitions loop
         Jintp.Append (Tr, Transition_Dictionary (T));
      end loop;
      Jintp.Insert (D, "states",      St);
      Jintp.Insert (D, "transitions", Tr);
      return D;
   end State_Machine_Dictionary;

   --  ---- Rendering and walks ----

   function Render_One
     (Template_Path : String;
      Dict          : Jintp.Dictionary;
      Env           : in out Jintp.Environment)
      return Emit_Results.Result
   is
   begin
      return Emit_Results.Ok (Jintp.Render (Template_Path, Dict, Env));
   exception
      when Jintp.Template_Error =>
         return Emit_Results.Err
           (Make_Error (No_Location, "template error: " & Template_Path));
   end Render_One;

   function Walk_Classes
     (Path : String;
      Env  : in out Jintp.Environment;
      M    : Model) return Emit_Results.Result
   is
      Buf : Unbounded_String;
   begin
      for C of M.Classes loop
         declare
            R : constant Emit_Results.Result :=
              Render_One (Path, Class_Dictionary (C, M.Relations), Env);
         begin
            if not R.Success then
               return R;
            end if;
            Append (Buf, To_String (R.Output));
         end;
      end loop;
      return Emit_Results.Ok (Buf);
   end Walk_Classes;

   function Walk_Relations
     (Path : String;
      Env  : in out Jintp.Environment;
      M    : Model) return Emit_Results.Result
   is
      Buf : Unbounded_String;
   begin
      for R of M.Relations loop
         declare
            Res : constant Emit_Results.Result :=
              Render_One (Path, Relation_Dictionary (R), Env);
         begin
            if not Res.Success then
               return Res;
            end if;
            Append (Buf, To_String (Res.Output));
         end;
      end loop;
      return Emit_Results.Ok (Buf);
   end Walk_Relations;

   function Walk_State_Machines
     (Path : String;
      Env  : in out Jintp.Environment;
      M    : Model) return Emit_Results.Result
   is
      Buf : Unbounded_String;
   begin
      for S of M.State_Machines loop
         declare
            R : constant Emit_Results.Result :=
              Render_One (Path, State_Machine_Dictionary (S), Env);
         begin
            if not R.Success then
               return R;
            end if;
            Append (Buf, To_String (R.Output));
         end;
      end loop;
      return Emit_Results.Ok (Buf);
   end Walk_State_Machines;

   function Emit_With_Set
     (M        : Model;
      Set_Dir  : String;
      Manifest : Manifests.Manifest) return Emit_Results.Result
   is
      Env     : Jintp.Environment;
      Buf     : Unbounded_String;
      Entries : constant Manifests.Template_Entry_Vectors.Vector :=
        Manifests.Templates (Manifest);
   begin
      Jintp.Configure (Env);
      UML2Code.Filters.Register_All (Env);

      for E of Entries loop
         declare
            Kind : constant String := To_String (E.Element_Kind);
            Path : constant String :=
              Set_Dir & "/" & To_String (E.File_Name);
            R : Emit_Results.Result;
         begin
            if Kind = "class" then
               R := Walk_Classes (Path, Env, M);
            elsif Kind = "relation" then
               R := Walk_Relations (Path, Env, M);
            elsif Kind = "state_machine" then
               R := Walk_State_Machines (Path, Env, M);
            else
               R := Emit_Results.Err
                 (Make_Error (No_Location,
                              "unknown element kind: " & Kind));
            end if;

            if not R.Success then
               return R;
            end if;
            Append (Buf, To_String (R.Output));
         end;
      end loop;

      return Emit_Results.Ok (Buf);
   end Emit_With_Set;

   function Emit (M : Model) return Emit_Results.Result is
      Root_Res  : constant Paths.Search_Result := Paths.Find_Templates_Root;
      Preferred : constant String :=
        Ada.Environment_Variables.Value ("UML2CODE_TEMPLATE_SET", "");
   begin
      if not Root_Res.Success then
         return Emit_Results.Err (Root_Res.Error);
      end if;

      declare
         Root   : constant String := To_String (Root_Res.Root);
         Sets   : constant Manifests.String_Vectors.Vector :=
           Manifests.List_Sets (Root);
         Chosen : Unbounded_String := Null_Unbounded_String;
      begin
         if Sets.Is_Empty then
            return Emit_Results.Err
              (Make_Error (No_Location,
                           "no template sets found in " & Root));
         end if;

         if Preferred'Length > 0 then
            for S of Sets loop
               if To_String (S) = Preferred then
                  Chosen := S;
                  exit;
               end if;
            end loop;
            if Length (Chosen) = 0 then
               return Emit_Results.Err
                 (Make_Error (No_Location,
                              "template set not found: " & Preferred));
            end if;
         else
            Chosen := Sets.Element (1);
         end if;

         declare
            Set_Name : constant String := To_String (Chosen);
            Set_Dir  : constant String := Root & "/" & Set_Name;
            Load_Res : constant Manifests.Load_Result :=
              Manifests.Load (Set_Dir);
         begin
            if not Load_Res.Success then
               return Emit_Results.Err (Load_Res.Error);
            end if;

            return Emit_With_Set (M, Set_Dir, Load_Res.Value);
         end;
      end;
   end Emit;

end UML2Code.Controller;
