with Ada.Exceptions;
with Jintp;
with UML2Code.Manifests; use UML2Code.Manifests;
with UML2Code.Paths;

package body UML2Code.Controller is

   ---------------------------------------------------------------------------
   -- Helper: Bind_Model_Context
   ---------------------------------------------------------------------------
   procedure Bind_Model_Context (Dict : in out Jintp.Dictionary; M : Model) is
   begin
      null;
   end Bind_Model_Context;

   ---------------------------------------------------------------------------
   -- Helper: Emit_With_Set
   ---------------------------------------------------------------------------
   function Emit_With_Set
     (M : Model; S : UML2Code.Settings; Set_Dir : String; Mfst : Manifest)
      return Pipeline_Results.Result
   is
      Dict     : Jintp.Dictionary;
      Out_Data : Generated_Output;

      -- Fetch the vectors of templates using the correct getters
      Spec_Tpls : constant Template_Entry_Vectors.Vector :=
        Code_Spec_Templates (Mfst);
      Body_Tpls : constant Template_Entry_Vectors.Vector :=
        Code_Body_Templates (Mfst);
   begin
      Bind_Model_Context (Dict, M);

      -- Render all Specification Templates defined in the manifest
      for Tpl of Spec_Tpls loop
         declare
            Path : constant String :=
              Set_Dir & "/" & To_String (Tpl.File_Name);
         begin
            Out_Data.Code_Spec :=
              Out_Data.Code_Spec
              & To_Unbounded_String (Jintp.Render (Path, Dict));
         end;
      end loop;

      -- Render all Body Templates defined in the manifest
      for Tpl of Body_Tpls loop
         declare
            Path : constant String :=
              Set_Dir & "/" & To_String (Tpl.File_Name);
         begin
            Out_Data.Code_Body :=
              Out_Data.Code_Body
              & To_Unbounded_String (Jintp.Render (Path, Dict));
         end;
      end loop;

      return Pipeline_Results.Ok (Out_Data);
   exception
      when E : others =>
         return
           Pipeline_Results.Err
             (Make_Error
                (No_Location,
                 "Unhandled exception during template generation: "
                 & Ada.Exceptions.Exception_Message (E)));
   end Emit_With_Set;

   ---------------------------------------------------------------------------
   -- Public Pipeline Entry Point: Emit
   ---------------------------------------------------------------------------
   function Emit
     (M : Model; S : UML2Code.Settings; Set_Name : String := "")
      return Pipeline_Results.Result
   is
      Root_Res  : constant Paths.Search_Result := Paths.Find_Templates_Root;
      Preferred : constant String := Set_Name;
   begin
      if not Root_Res.Success then
         return Pipeline_Results.Err (Root_Res.Error);
      end if;

      declare
         Root   : constant String := To_String (Root_Res.Root);
         Sets   : constant String_Vectors.Vector := List_Sets (Root);
         Chosen : Unbounded_String := Null_Unbounded_String;
      begin
         if Sets.Is_Empty then
            return
              Pipeline_Results.Err
                (Make_Error
                   (No_Location, "no template sets found in " & Root));
         end if;

         if Preferred'Length > 0 then
            for Item of Sets loop
               if To_String (Item) = Preferred then
                  Chosen := Item;
                  exit;
               end if;
            end loop;
            if Length (Chosen) = 0 then
               return
                 Pipeline_Results.Err
                   (Make_Error
                      (No_Location, "template set not found: " & Preferred));
            end if;
         else
            Chosen := Sets.Element (1);
         end if;

         declare
            Selected_Name : constant String := To_String (Chosen);
            Set_Dir       : constant String := Root & "/" & Selected_Name;
            Load_Res      : constant Load_Result := Load (Set_Dir);
         begin
            if not Load_Res.Success then
               return Pipeline_Results.Err (Load_Res.Error);
            end if;
            return Emit_With_Set (M, S, Set_Dir, Load_Res.Value);
         end;
      end;
   end Emit;

end UML2Code.Controller;
