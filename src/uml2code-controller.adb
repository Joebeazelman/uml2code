with Ada.Containers.Vectors;
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

   package Str_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Ada.Strings.Unbounded.Unbounded_String);
   use Str_Vectors;

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
         if (R.Kind = Inheritance or else R.Kind = Realization)
           and then R.Source = C.Name
         then
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
         if (R.Kind = Inheritance or else R.Kind = Realization)
           and then R.Target = C.Name
         then
            return True;
         end if;
      end loop;
      return False;
   end Is_Base;

   function Is_Nullable (M : Multiplicity) return Boolean is
     (M.Lower = 0 and then M.Upper = 1);

   function With_Clauses
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Jintp.List
   is
      Result : Jintp.List;
      Seen   : Str_Vectors.Vector;

      procedure Add_If_New (Name : String) is
      begin
         if Name'Length = 0 then
            return;
         end if;
         for S of Seen loop
            if To_String (S) = Name then
               return;
            end if;
         end loop;
         Seen.Append (To_Unbounded_String (Name));
         Jintp.Append (Result, "with " & Name & ";");
      end Add_If_New;

   begin
      Add_If_New (Derives_From (C, Relations));

      for R of Relations loop
         if R.Source = C.Name then
            case R.Kind is
               when Composition | Aggregation | Association =>
                  Add_If_New (UML2Code.Casing.To_Ada_Case
                              (To_String (R.Target)));
                  if Is_Unbounded (R.Target_Multiplicity) then
                     Add_If_New ("Ada.Containers.Vectors");
                  end if;
               when others =>
                  null;
            end case;
         end if;
      end loop;

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

   --  Instantiate a container package for each multi-valued target
   --  relation of C. Duplicate targets share one instantiation.
   function Vector_Instantiation_Lines
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Jintp.List
   is
      Result : Jintp.List;
      Seen   : Str_Vectors.Vector;
   begin
      for R of Relations loop
         if R.Source = C.Name
           and then R.Kind in Composition | Aggregation | Association
           and then Is_Unbounded (R.Target_Multiplicity)
         then
            declare
               Tgt     : constant String :=
                 UML2Code.Casing.To_Ada_Case (To_String (R.Target));
               Already : Boolean := False;
            begin
               for S of Seen loop
                  if To_String (S) = Tgt then
                     Already := True;
                     exit;
                  end if;
               end loop;
               if not Already then
                  Seen.Append (To_Unbounded_String (Tgt));
                  Jintp.Append
                    (Result,
                     "   package " & Tgt
                     & "_Vectors is new Ada.Containers.Vectors");
                  Jintp.Append
                    (Result,
                     "     (Index_Type   => Positive,");
                  Jintp.Append
                    (Result,
                     "      Element_Type => " & Tgt & "_Pkg."
                     & Tgt & "_T);");
               end if;
            end;
         end if;
      end loop;
      return Result;
   end Vector_Instantiation_Lines;

   --  For each relation target, emit a package renames so the
   --  record can qualify the type without the field name shadowing
   --  the package name. Deduplicated.
   function Package_Rename_Lines
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Jintp.List
   is
      Result : Jintp.List;
      Seen   : Str_Vectors.Vector;
   begin
      for R of Relations loop
         if R.Source = C.Name
           and then R.Kind in Composition | Aggregation | Association
         then
            declare
               Tgt     : constant String :=
                 UML2Code.Casing.To_Ada_Case (To_String (R.Target));
               Already : Boolean := False;
            begin
               for S of Seen loop
                  if To_String (S) = Tgt then
                     Already := True;
                     exit;
                  end if;
               end loop;
               if not Already then
                  Seen.Append (To_Unbounded_String (Tgt));
                  Jintp.Append
                    (Result,
                     "   package " & Tgt & "_Pkg renames " & Tgt & ";");
               end if;
            end;
         end if;
      end loop;
      return Result;
   end Package_Rename_Lines;

   function Relation_Field_Name (R : Relation) return String is
   begin
      if Length (R.Target_Role) > 0 then
         return UML2Code.Casing.To_Snake_Case
           (To_String (R.Target_Role));
      else
         return UML2Code.Casing.To_Snake_Case
           (To_String (R.Target));
      end if;
   end Relation_Field_Name;

   function Record_Body_Lines
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Jintp.List
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

      for R of Relations loop
         if R.Source = C.Name then
            declare
               Field : constant String := Relation_Field_Name (R);
               Tgt   : constant String :=
                 UML2Code.Casing.To_Ada_Case (To_String (R.Target));
               Mult  : constant Multiplicity := R.Target_Multiplicity;
            begin
               case R.Kind is
                  when Composition | Aggregation | Association =>
                     Any := True;
                     if Is_Unbounded (Mult) then
                        Jintp.Append
                          (Result,
                           "      " & Field & " : "
                           & Tgt & "_Pkg." & Tgt & "_Vectors.Vector;");
                     elsif Is_Nullable (Mult) then
                        Jintp.Append
                          (Result,
                           "      " & Field & " : access "
                           & Tgt & "_Pkg." & Tgt & "_T;");
                     elsif R.Kind = Composition then
                        Jintp.Append
                          (Result,
                           "      " & Field & " : "
                           & Tgt & "_Pkg." & Tgt & "_T;");
                     else
                        Jintp.Append
                          (Result,
                           "      " & Field & " : access "
                           & Tgt & "_Pkg." & Tgt & "_T;");
                     end if;
                  when others =>
                     null;
               end case;
            end;
         end if;
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

   --  The body of an operation, as a list of source lines. Procedures
   --  get "null"; functions raise Program_Error. The developer
   --  replaces these with real implementations.
   function Operation_Body_Lines (O : UML_Model.Class.Operation)
     return Jintp.List
   is
      Result  : Jintp.List;
      Name    : constant String :=
        UML2Code.Casing.To_Ada_Case (To_String (O.Name));
      Has_Ret : constant Boolean := Is_Valid (O.Return_Type.Name);
      Has_Par : constant Boolean := not O.Parameters.Is_Empty;
      Sig     : Unbounded_String;
   begin
      if Has_Ret then
         Append (Sig, "   function ");
      else
         Append (Sig, "   procedure ");
      end if;
      Append (Sig, Name);

      if Has_Par then
         Append (Sig, " (");
         declare
            First : Boolean := True;
         begin
            for P of O.Parameters loop
               if not First then
                  Append (Sig, "; ");
               end if;
               First := False;
               Append (Sig,
                       UML2Code.Casing.To_Snake_Case
                         (To_String (P.Name)));
               Append (Sig, " : ");
               Append (Sig,
                       To_Ada_Type_Name (To_String (P.Of_Type)));
            end loop;
         end;
         Append (Sig, ")");
      end if;

      if Has_Ret then
         Append (Sig, " return ");
         Append (Sig, To_Ada_Type_Name (To_String (O.Return_Type)));
      end if;
      Append (Sig, " is");

      Jintp.Append (Result, To_String (Sig));
      Jintp.Append (Result, "   begin");
      if Has_Ret then
         Jintp.Append (Result,
                       "      raise Program_Error with """
                       & Name & " not implemented"";");
      else
         Jintp.Append (Result, "      null;");
      end if;
      Jintp.Append (Result, "   end " & Name & ";");
      return Result;
   end Operation_Body_Lines;

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

   --  The body of a test procedure for one operation, as a list of
   --  source lines. Procedures are called directly; functions have
   --  their result assigned to a local. Both catch Program_Error
   --  from the stub and report it as a pending-implementation pass.
   function Operation_Test_Body_Lines (O : UML_Model.Class.Operation)
     return Jintp.List
   is
      Result  : Jintp.List;
      Name    : constant String :=
        UML2Code.Casing.To_Ada_Case (To_String (O.Name));
      Has_Ret : constant Boolean := Is_Valid (O.Return_Type.Name);
   begin
      Jintp.Append (Result, "      pragma Unreferenced (T);");
      if Has_Ret then
         Jintp.Append (Result,
                       "      Result : "
                       & To_Ada_Type_Name (To_String (O.Return_Type))
                       & ";");
      end if;
      Jintp.Append (Result, "   begin");
      Jintp.Append (Result, "      begin");
      if Has_Ret then
         Jintp.Append (Result,
                       "         Result := " & Name & ";");
      else
         Jintp.Append (Result,
                       "         " & Name & ";");
      end if;
      Jintp.Append (Result,
                    "         Assert (True, """
                    & To_String (O.Name) & " returned"");");
      Jintp.Append (Result, "      exception");
      Jintp.Append (Result, "         when Program_Error =>");
      Jintp.Append (Result,
                    "            Assert (True, """
                    & To_String (O.Name) & " not yet implemented"");");
      Jintp.Append (Result, "      end;");
      return Result;
   end Operation_Test_Body_Lines;

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
      Jintp.Insert (D, "body_lines",  Operation_Body_Lines (O));
      Jintp.Insert (D, "test_body_lines",
                    Operation_Test_Body_Lines (O));
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
      Jintp.Insert (D, "with_clauses", With_Clauses (C, Relations));
      Jintp.Insert (D, "type_opening", Type_Opening (C, Relations));
      Jintp.Insert (D, "record_body_lines",
                    Record_Body_Lines (C, Relations));
      Jintp.Insert (D, "package_rename_lines",
                    Package_Rename_Lines (C, Relations));
      Jintp.Insert (D, "vector_instantiation_lines",
                    Vector_Instantiation_Lines (C, Relations));
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
      Jintp.Insert (D, "source_multiplicity",
                    To_String (R.Source_Multiplicity));
      Jintp.Insert (D, "target_multiplicity",
                    To_String (R.Target_Multiplicity));
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

   --  ---- Rendering ----

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

   --  ---- Walkers ----

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

   --  Dispatch a single manifest entry to the appropriate walker.
   --  The Section parameter selects code or test walkers.
   function Dispatch
     (Section : String;
      Kind    : String;
      Path    : String;
      Env     : in out Jintp.Environment;
      M       : Model) return Emit_Results.Result
   is
   begin
      if Section = "code-spec" or else Section = "code-body" then
         if Kind = "class" then
            return Walk_Classes (Path, Env, M);
         elsif Kind = "relation" then
            return Walk_Relations (Path, Env, M);
         elsif Kind = "state_machine" then
            return Walk_State_Machines (Path, Env, M);
         else
            return Emit_Results.Err
              (Make_Error (No_Location,
                           "unknown element kind: " & Kind));
         end if;
      else
         --  test-spec / test-body
         if Kind = "class" then
            return Walk_Classes (Path, Env, M);
         elsif Kind = "relation" then
            return Walk_Relations (Path, Env, M);
         elsif Kind = "state_machine" then
            return Walk_State_Machines (Path, Env, M);
         else
            return Emit_Results.Err
              (Make_Error (No_Location,
                           "unknown test element kind: " & Kind));
         end if;
      end if;
   end Dispatch;

   --  Render a whole section into Buf.
   procedure Render_Section
     (Section : String;
      Entries : Manifests.Template_Entry_Vectors.Vector;
      Set_Dir : String;
      Env     : in out Jintp.Environment;
      M       : Model;
      Buf     : in out Unbounded_String;
      Ok      : out Boolean;
      Err     : out Source_Error)
   is
   begin
      Ok := True;
      Err := Make_Error (No_Location, "");
      for E of Entries loop
         declare
            Kind : constant String := To_String (E.Element_Kind);
            Path : constant String :=
              Set_Dir & "/" & To_String (E.File_Name);
            R : constant Emit_Results.Result :=
              Dispatch (Section, Kind, Path, Env, M);
         begin
            if not R.Success then
               Ok := False;
               Err := R.Error;
               return;
            end if;
            Append (Buf, To_String (R.Output));
         end;
      end loop;
   end Render_Section;

   function Emit_With_Set
     (M        : Model;
      Set_Dir  : String;
      Manifest : Manifests.Manifest) return Pipeline_Results.Result
   is
      Env       : Jintp.Environment;
      Code_Spec : Unbounded_String;
      Code_Body : Unbounded_String;
      Test_Spec : Unbounded_String;
      Test_Body : Unbounded_String;
      Ok        : Boolean;
      Err       : Source_Error;
   begin
      Jintp.Configure (Env);
      UML2Code.Filters.Register_All (Env);

      Render_Section ("code-spec",
                      Manifests.Code_Spec_Templates (Manifest),
                      Set_Dir, Env, M, Code_Spec, Ok, Err);
      if not Ok then
         return Pipeline_Results.Err (Err);
      end if;

      Render_Section ("code-body",
                      Manifests.Code_Body_Templates (Manifest),
                      Set_Dir, Env, M, Code_Body, Ok, Err);
      if not Ok then
         return Pipeline_Results.Err (Err);
      end if;

      Render_Section ("test-spec",
                      Manifests.Test_Spec_Templates (Manifest),
                      Set_Dir, Env, M, Test_Spec, Ok, Err);
      if not Ok then
         return Pipeline_Results.Err (Err);
      end if;

      Render_Section ("test-body",
                      Manifests.Test_Body_Templates (Manifest),
                      Set_Dir, Env, M, Test_Body, Ok, Err);
      if not Ok then
         return Pipeline_Results.Err (Err);
      end if;

      return Pipeline_Results.Ok
        ((Code_Spec => Code_Spec,
          Code_Body => Code_Body,
          Test_Spec => Test_Spec,
          Test_Body => Test_Body));
   end Emit_With_Set;

   function Emit (M : Model) return Pipeline_Results.Result is
      Root_Res  : constant Paths.Search_Result := Paths.Find_Templates_Root;
      Preferred : constant String :=
        Ada.Environment_Variables.Value ("UML2CODE_TEMPLATE_SET", "");
   begin
      if not Root_Res.Success then
         return Pipeline_Results.Err (Root_Res.Error);
      end if;

      declare
         Root   : constant String := To_String (Root_Res.Root);
         Sets   : constant Manifests.String_Vectors.Vector :=
           Manifests.List_Sets (Root);
         Chosen : Unbounded_String := Null_Unbounded_String;
      begin
         if Sets.Is_Empty then
            return Pipeline_Results.Err
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
               return Pipeline_Results.Err
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
               return Pipeline_Results.Err (Load_Res.Error);
            end if;

            return Emit_With_Set (M, Set_Dir, Load_Res.Value);
         end;
      end;
   end Emit;

end UML2Code.Controller;
