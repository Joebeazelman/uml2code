with Ada.Environment_Variables;
with Ada.Exceptions;
with Ada.Strings.Fixed;       use Ada.Strings.Fixed;
with Ada.Strings.Unbounded;   use Ada.Strings.Unbounded;
with Jintp;
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
   use type UML_Model.State_Machine.State_Kind;

   Current_Settings : UML2Code.Settings := UML2Code.Empty_Settings;

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

   function Settings_Dictionary return Jintp.Dictionary is
      D : Jintp.Dictionary;
   begin
      Jintp.Insert (D, "author",    To_String (Current_Settings.Author));
      Jintp.Insert (D, "company",   To_String (Current_Settings.Company));
      Jintp.Insert (D, "copyright", To_String (Current_Settings.Copyright));
      return D;
   end Settings_Dictionary;

   --  Classify a UML type name into a language-neutral category.
   function Type_Category (Name : String) return String is
   begin
      if Name = "String" or else Name = "string" then
         return "string";
      elsif Name = "Integer" or else Name = "integer" then
         return "integer";
      elsif Name = "Boolean" or else Name = "boolean" then
         return "boolean";
      elsif Name = "Float" or else Name = "float" then
         return "float";
      elsif Name'Length = 0 then
         return "integer";
      else
         return "user";
      end if;
   end Type_Category;

   --  Classify a multiplicity: "single", "optional", or "multi".
   function Multiplicity_Class (M : Multiplicity) return String is
   begin
      if Is_Unbounded (M) then
         return "multi";
      elsif M.Lower = 0 then
         return "optional";
      else
         return "single";
      end if;
   end Multiplicity_Class;

   --  Field name for a relation: the target role if present, else
   --  the target class name. Returned unfiltered; templates apply
   --  whatever casing filter they prefer.
   function Field_Name (R : Relation) return String is
   begin
      if Length (R.Target_Role) > 0 then
         return To_String (R.Target_Role);
      else
         return To_String (R.Target);
      end if;
   end Field_Name;

   function Property_Dictionary (P : UML_Model.Class.Property)
     return Jintp.Dictionary
   is
      D   : Jintp.Dictionary;
      Cat : constant String := Type_Category (To_String (P.Of_Type));
   begin
      Jintp.Insert (D, "name",         To_String (P.Name));
      Jintp.Insert (D, "type",         To_String (P.Of_Type));
      Jintp.Insert (D, "visibility",
                    UML_Model.Class.Visibility'Image (P.Visibility));
      Jintp.Insert (D, "multiplicity", To_String (P.Multiplicity));
      Jintp.Insert (D, "default",      To_String (P.Default));
      Jintp.Insert (D, "stereotypes",  Stereotype_List (P.Stereotypes));
      Jintp.Insert (D, "type_category", Cat);
      Jintp.Insert (D, "is_string",    Cat = "string");
      Jintp.Insert (D, "is_integer",   Cat = "integer");
      Jintp.Insert (D, "is_boolean",   Cat = "boolean");
      Jintp.Insert (D, "is_float",     Cat = "float");
      Jintp.Insert (D, "is_user_type", Cat = "user");
      Jintp.Insert (D, "has_default",  not Is_Empty (P.Default));
      Jintp.Insert (D, "settings",     Settings_Dictionary);
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
      Jintp.Insert (D, "has_return",  Is_Valid (O.Return_Type.Name));
      Jintp.Insert (D, "has_parameters", not O.Parameters.Is_Empty);
      for P of O.Parameters loop
         Jintp.Append (Params, Property_Dictionary (P));
      end loop;
      Jintp.Insert (D, "parameters", Params);
      Jintp.Insert (D, "settings",   Settings_Dictionary);
      return D;
   end Operation_Dictionary;

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
      Jintp.Insert (D, "target_multiplicity_class",
                    Multiplicity_Class (R.Target_Multiplicity));
      Jintp.Insert (D, "field_name",   Field_Name (R));
      Jintp.Insert (D, "has_role",     Length (R.Target_Role) > 0);
      Jintp.Insert (D, "is_inheritance", R.Kind = Inheritance);
      Jintp.Insert (D, "is_realization", R.Kind = Realization);
      Jintp.Insert (D, "is_composition", R.Kind = Composition);
      Jintp.Insert (D, "is_aggregation", R.Kind = Aggregation);
      Jintp.Insert (D, "is_association", R.Kind = Association);
      Jintp.Insert (D, "stereotypes",  Stereotype_List (R.Stereotypes));
      Jintp.Insert (D, "settings",     Settings_Dictionary);
      return D;
   end Relation_Dictionary;

   function Base_Name
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return String
   is
   begin
      for R of Relations loop
         if (R.Kind = Inheritance or else R.Kind = Realization)
           and then R.Source = C.Name
         then
            return To_String (R.Target);
         end if;
      end loop;
      return "";
   end Base_Name;

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

   function Referenced_Packages
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Jintp.List
   is
      Result : Jintp.List;
      Seen   : Unbounded_String;

      procedure Add (Name : String) is
      begin
         if Name'Length = 0 then
            return;
         end if;
         if Index (Seen, ASCII.LF & Name & ASCII.LF) > 0 then
            return;
         end if;
         Append (Seen, Name & ASCII.LF);
         Jintp.Append (Result, Name);
      end Add;

   begin
      Add (Base_Name (C, Relations));
      for R of Relations loop
         if R.Source = C.Name
           and then R.Kind in Composition | Aggregation | Association
         then
            Add (To_String (R.Target));
         end if;
      end loop;
      return Result;
   end Referenced_Packages;

   function Vector_Targets
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Jintp.List
   is
      Result : Jintp.List;
      Seen   : Unbounded_String;
   begin
      for R of Relations loop
         if R.Source = C.Name
           and then R.Kind in Composition | Aggregation | Association
           and then Is_Unbounded (R.Target_Multiplicity)
         then
            declare
               Name : constant String := To_String (R.Target);
            begin
               if Index (Seen, ASCII.LF & Name & ASCII.LF) = 0 then
                  Append (Seen, Name & ASCII.LF);
                  Jintp.Append (Result, Name);
               end if;
            end;
         end if;
      end loop;
      return Result;
   end Vector_Targets;

   function Vector_Target_Count
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Natural
   is
      Count : Natural := 0;
   begin
      for R of Relations loop
         if R.Source = C.Name
           and then R.Kind in Composition | Aggregation | Association
           and then Is_Unbounded (R.Target_Multiplicity)
         then
            Count := Count + 1;
         end if;
      end loop;
      return Count;
   end Vector_Target_Count;

   function Relation_Out_Count
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Natural
   is
      Count : Natural := 0;
   begin
      for R of Relations loop
         if R.Source = C.Name
           and then R.Kind in Composition | Aggregation | Association
         then
            Count := Count + 1;
         end if;
      end loop;
      return Count;
   end Relation_Out_Count;

   function Class_Dictionary
     (C         : UML_Model.Class.Class_Model;
      Relations : Relation_Vector) return Jintp.Dictionary
   is
      D        : Jintp.Dictionary;
      Attrs    : Jintp.List;
      Ops      : Jintp.List;
      Rels_Out : Jintp.List;
      Rel_Out_Count : Natural := 0;
      Base     : constant String := Base_Name (C, Relations);
      Has_Str  : Boolean := False;
      Vectors  : constant Jintp.List := Vector_Targets (C, Relations);
   begin
      for P of C.Attributes loop
         Jintp.Append (Attrs, Property_Dictionary (P));
         if Type_Category (To_String (P.Of_Type)) = "string" then
            Has_Str := True;
         end if;
      end loop;
      for O of C.Operations loop
         Jintp.Append (Ops, Operation_Dictionary (O));
      end loop;
      for R of Relations loop
         if R.Source = C.Name
           and then R.Kind in Composition | Aggregation | Association
         then
            Jintp.Append (Rels_Out, Relation_Dictionary (R));
            Rel_Out_Count := Rel_Out_Count + 1;
         end if;
      end loop;

      Jintp.Insert (D, "name",        To_String (C.Name));
      Jintp.Insert (D, "visibility",
                    UML_Model.Class.Visibility'Image (C.Visibility));
      Jintp.Insert (D, "stereotypes", Stereotype_List (C.Stereotypes));
      Jintp.Insert (D, "base_name",   Base);
      Jintp.Insert (D, "has_base",    Base'Length > 0);
      Jintp.Insert (D, "is_base",     Is_Base (C, Relations));
      Jintp.Insert (D, "attributes",  Attrs);
      Jintp.Insert (D, "has_attributes", not C.Attributes.Is_Empty);
      Jintp.Insert (D, "operations",  Ops);
      Jintp.Insert (D, "has_operations", not C.Operations.Is_Empty);
      Jintp.Insert (D, "relations_out", Rels_Out);
      Jintp.Insert (D, "has_relations_out", Rel_Out_Count > 0);
      Jintp.Insert (D, "referenced_packages",
                    Referenced_Packages (C, Relations));
      Jintp.Insert (D, "vector_targets", Vectors);
      Jintp.Insert (D, "has_vector_targets",
                    Natural (Vector_Target_Count (C, Relations)) > 0);
      Jintp.Insert (D, "has_string_attribute", Has_Str);
      Jintp.Insert (D, "has_fields",
                    not C.Attributes.Is_Empty
                    or else Relation_Out_Count (C, Relations) > 0);
      Jintp.Insert (D, "settings",    Settings_Dictionary);
      return D;
   end Class_Dictionary;

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
      Jintp.Insert (D, "has_event",   not Is_Empty (T.Event));
      Jintp.Insert (D, "has_guard",   not Is_Empty (T.Guard));
      Jintp.Insert (D, "has_action",  not Is_Empty (T.Action));
      Jintp.Insert (D, "stereotypes", Stereotype_List (T.Stereotypes));
      Jintp.Insert (D, "settings",    Settings_Dictionary);
      return D;
   end Transition_Dictionary;

   function State_Dictionary
     (S           : UML_Model.State_Machine.State;
      Transitions : UML_Model.State_Machine.Transition_Vector)
     return Jintp.Dictionary
   is
      D        : Jintp.Dictionary;
      Outgoing : Jintp.List;
      Out_Count : Natural := 0;
   begin
      for T of Transitions loop
         if T.Source = S.Name then
            Jintp.Append (Outgoing, Transition_Dictionary (T));
            Out_Count := Out_Count + 1;
         end if;
      end loop;

      Jintp.Insert (D, "name",         To_String (S.Name));
      Jintp.Insert (D, "kind",
                    UML_Model.State_Machine.State_Kind'Image (S.Kind));
      Jintp.Insert (D, "parent",       To_String (S.Parent));
      Jintp.Insert (D, "entry_action", To_String (S.Entry_Action));
      Jintp.Insert (D, "exit_action",  To_String (S.Exit_Action));
      Jintp.Insert (D, "has_parent",   Is_Valid (S.Parent));
      Jintp.Insert (D, "has_entry",    not Is_Empty (S.Entry_Action));
      Jintp.Insert (D, "has_exit",     not Is_Empty (S.Exit_Action));
      Jintp.Insert (D, "is_initial",   S.Kind = UML_Model.State_Machine.Initial);
      Jintp.Insert (D, "is_final",     S.Kind = UML_Model.State_Machine.Final);
      Jintp.Insert (D, "is_composite", S.Kind = UML_Model.State_Machine.Composite);
      Jintp.Insert (D, "is_simple",    S.Kind = UML_Model.State_Machine.Simple);
      Jintp.Insert (D, "stereotypes",  Stereotype_List (S.Stereotypes));
      Jintp.Insert (D, "outgoing",     Outgoing);
      Jintp.Insert (D, "has_outgoing", Out_Count > 0);
      Jintp.Insert (D, "settings",     Settings_Dictionary);
      return D;
   end State_Dictionary;

   function State_Machine_Dictionary
     (M : UML_Model.State_Machine.State_Chart_Model) return Jintp.Dictionary
   is
      D  : Jintp.Dictionary;
      St : Jintp.List;
      Tr : Jintp.List;
   begin
      for S of M.States loop
         Jintp.Append (St, State_Dictionary (S, M.Transitions));
      end loop;
      for T of M.Transitions loop
         Jintp.Append (Tr, Transition_Dictionary (T));
      end loop;

      Jintp.Insert (D, "name",        To_String (M.Name));
      Jintp.Insert (D, "initial",     To_String (M.Initial));
      Jintp.Insert (D, "has_initial", Is_Valid (M.Initial));
      Jintp.Insert (D, "states",      St);
      Jintp.Insert (D, "transitions", Tr);
      Jintp.Insert (D, "stereotypes", Stereotype_List (M.Stereotypes));
      Jintp.Insert (D, "settings",    Settings_Dictionary);
      return D;
   end State_Machine_Dictionary;

   function Render_One
     (Template_Path : String;
      Dict          : Jintp.Dictionary;
      Env           : in out Jintp.Environment)
      return Emit_Results.Result
   is
   begin
      return Emit_Results.Ok (Jintp.Render (Template_Path, Dict, Env));
   exception
      when E : Jintp.Template_Error =>
         return Emit_Results.Err
           (Make_Error (No_Location,
                        "template error: " & Template_Path
                        & " (" & Ada.Exceptions.Exception_Message (E) & ")"));
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
            declare
               Chunk : constant String := To_String (R.Output);
            begin
               Append (Buf, Chunk);
               if Chunk'Length > 0
                 and then Chunk (Chunk'Last) /= ASCII.LF
               then
                  Append (Buf, ASCII.LF);
               end if;
            end;
         end;
      end loop;
      return Emit_Results.Ok (Buf);
   end Walk_Classes;

   function Walk_Class_Bodies
     (Path : String;
      Env  : in out Jintp.Environment;
      M    : Model) return Emit_Results.Result
   is
      Buf : Unbounded_String;
   begin
      for C of M.Classes loop
         if not C.Operations.Is_Empty then
            declare
               R : constant Emit_Results.Result :=
                 Render_One (Path, Class_Dictionary (C, M.Relations), Env);
            begin
               if not R.Success then
                  return R;
               end if;
               declare
                  Chunk : constant String := To_String (R.Output);
               begin
                  Append (Buf, Chunk);
                  if Chunk'Length > 0
                    and then Chunk (Chunk'Last) /= ASCII.LF
                  then
                     Append (Buf, ASCII.LF);
                  end if;
               end;
            end;
         end if;
      end loop;
      return Emit_Results.Ok (Buf);
   end Walk_Class_Bodies;

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
            declare
               Chunk : constant String := To_String (R.Output);
            begin
               Append (Buf, Chunk);
               if Chunk'Length > 0
                 and then Chunk (Chunk'Last) /= ASCII.LF
               then
                  Append (Buf, ASCII.LF);
               end if;
            end;
         end;
      end loop;
      return Emit_Results.Ok (Buf);
   end Walk_State_Machines;

   function Dispatch
     (Section : String;
      Kind    : String;
      Path    : String;
      Env     : in out Jintp.Environment;
      M       : Model) return Emit_Results.Result
   is
   begin
      if Section = "code-spec" then
         if Kind = "class" then
            return Walk_Classes (Path, Env, M);
         elsif Kind = "state_machine" then
            return Walk_State_Machines (Path, Env, M);
         else
            return Emit_Results.Err
              (Make_Error (No_Location,
                           "unknown element kind: " & Kind));
         end if;
      elsif Section = "code-body" then
         if Kind = "class" then
            return Walk_Class_Bodies (Path, Env, M);
         elsif Kind = "state_machine" then
            return Walk_State_Machines (Path, Env, M);
         else
            return Emit_Results.Err
              (Make_Error (No_Location,
                           "unknown code-body element kind: " & Kind));
         end if;
      else
         if Kind = "class" then
            return Walk_Classes (Path, Env, M);
         elsif Kind = "state_machine" then
            return Walk_State_Machines (Path, Env, M);
         else
            return Emit_Results.Err
              (Make_Error (No_Location,
                           "unknown test element kind: " & Kind));
         end if;
      end if;
   end Dispatch;

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

   function Emit
     (M : Model;
      S : UML2Code.Settings) return Pipeline_Results.Result
   is
      Root_Res  : constant Paths.Search_Result := Paths.Find_Templates_Root;
      Preferred : constant String :=
        Ada.Environment_Variables.Value ("UML2CODE_TEMPLATE_SET", "");
   begin
      Current_Settings := S;

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
