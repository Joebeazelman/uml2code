with Ada.Environment_Variables;
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
      for P of O.Parameters loop
         Jintp.Append (Params, Property_Dictionary (P));
      end loop;
      Jintp.Insert (D, "parameters", Params);
      return D;
   end Operation_Dictionary;

   function Class_Dictionary (C : UML_Model.Class.Class_Model)
     return Jintp.Dictionary
   is
      D     : Jintp.Dictionary;
      Attrs : Jintp.List;
      Ops   : Jintp.List;
   begin
      Jintp.Insert (D, "name",       To_String (C.Name));
      Jintp.Insert (D, "visibility",
                    UML_Model.Class.Visibility'Image (C.Visibility));
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
      return D;
   end Relation_Dictionary;

   function State_Dictionary (S : UML_Model.State_Machine.State)
     return Jintp.Dictionary
   is
      D : Jintp.Dictionary;
   begin
      Jintp.Insert (D, "name",         To_String (S.Name));
      Jintp.Insert (D, "kind",
                    UML_Model.State_Machine.State_Kind'Image (S.Kind));
      Jintp.Insert (D, "parent",       To_String (S.Parent));
      Jintp.Insert (D, "entry_action", To_String (S.Entry_Action));
      Jintp.Insert (D, "exit_action",  To_String (S.Exit_Action));
      return D;
   end State_Dictionary;

   function Transition_Dictionary (T : UML_Model.State_Machine.Transition)
     return Jintp.Dictionary
   is
      D : Jintp.Dictionary;
   begin
      Jintp.Insert (D, "source", To_String (T.Source));
      Jintp.Insert (D, "target", To_String (T.Target));
      Jintp.Insert (D, "event",  To_String (T.Event));
      Jintp.Insert (D, "guard",  To_String (T.Guard));
      Jintp.Insert (D, "action", To_String (T.Action));
      return D;
   end Transition_Dictionary;

   function State_Machine_Dictionary
     (M : UML_Model.State_Machine.State_Chart_Model) return Jintp.Dictionary
   is
      D  : Jintp.Dictionary;
      St : Jintp.List;
      Tr : Jintp.List;
   begin
      Jintp.Insert (D, "name",    To_String (M.Name));
      Jintp.Insert (D, "initial", To_String (M.Initial));
      for S of M.States loop
         Jintp.Append (St, State_Dictionary (S));
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

   --  ---- Per-kind walks ----

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
              Render_One (Path, Class_Dictionary (C), Env);
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

   --  ---- Manifest-driven dispatch ----

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

   --  ---- Public entry point ----

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
