with Ada.Characters.Handling;
with Ada.Strings.Unbounded;
with Uml2Code_Identifiers;

package body Uml2Code_Filters is

    use Ada.Characters.Handling;
    use Ada.Strings.Unbounded;

    --  Global environment used by Register_Filters (no-arg version)
    Global_Env : Jintp.Environment;

    function Sanitize_Filter
      (Arguments : Jintp.Unbounded_String_Array)
       return Unbounded_String
    is
       S : constant String := To_String (Arguments (Arguments'First));
    begin
       return To_Unbounded_String
         (Uml2Code_Identifiers.Sanitize (S));
    end Sanitize_Filter;

    function Ada_Case_Filter
      (Arguments : Jintp.Unbounded_String_Array)
       return Unbounded_String
    is
       S : constant String := To_String (Arguments (Arguments'First));
    begin
       return To_Unbounded_String
         (Uml2Code_Identifiers.Ada_Case (S));
    end Ada_Case_Filter;

    function Ident_Filter
      (Arguments : Jintp.Unbounded_String_Array)
       return Unbounded_String
    is
       S : constant String := To_String (Arguments (Arguments'First));
    begin
       return To_Unbounded_String
         (Uml2Code_Identifiers.Ident (S));
    end Ident_Filter;

    procedure Initialize is
    begin
       Register_Filters (Global_Env);
    end Initialize;

    function Ada_Ident_Filter
      (Arguments : Jintp.Unbounded_String_Array)
       return Unbounded_String
    is
       S : constant String := To_String (Arguments (Arguments'First));
    begin
       --  Compatibility filter: it remains for migration, but it now
       --  delegates to the centralized Ada naming policy instead of
       --  maintaining a separate copy of the logic.
       return To_Unbounded_String
         (Uml2Code_Identifiers.Ident (S));
    end Ada_Ident_Filter;

    function Ada_Type_Filter
      (Arguments : Jintp.Unbounded_String_Array)
       return Unbounded_String
    is
       S : constant String := To_Lower (To_String (Arguments (Arguments'First)));
    begin
       if S = "string" or else S = "str" then
          return To_Unbounded_String ("Unbounded_String");
       elsif S = "int" or else S = "integer" then
          return To_Unbounded_String ("Integer");
       elsif S = "bool" or else S = "boolean" then
          return To_Unbounded_String ("Boolean");
       elsif S = "float" or else S = "real" then
          return To_Unbounded_String ("Float");
       else
          return To_Unbounded_String
            (Uml2Code_Identifiers.Ada_Case
               (To_String (Arguments (Arguments'First))));
       end if;
    end Ada_Type_Filter;

    function Ada_Rel_Type_Filter
      (Arguments : Jintp.Unbounded_String_Array)
       return Unbounded_String
    is
       Target : constant String := To_String (Arguments (Arguments'First));
    begin
       return To_Unbounded_String ("access ")
         & To_Unbounded_String
           (Uml2Code_Identifiers.Ada_Case (Target));
    end Ada_Rel_Type_Filter;

    procedure Register_Filters (Env : in out Jintp.Environment) is
    begin
       Jintp.Register_Filter (Env, Sanitize_Filter'Access, "sanitize");
       Jintp.Register_Filter (Env, Ada_Case_Filter'Access, "ada_case");
       Jintp.Register_Filter (Env, Ident_Filter'Access, "ident");
       Jintp.Register_Filter (Env, Ada_Ident_Filter'Access, "ada_ident");
       Jintp.Register_Filter (Env, Ada_Type_Filter'Access, "ada_type");
       Jintp.Register_Filter (Env, Ada_Rel_Type_Filter'Access, "ada_rel_type");
    end Register_Filters;

end Uml2Code_Filters;
