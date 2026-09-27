    function Ada_Type_Filter
      (Arguments : Jintp.Unbounded_String_Array)
       return Unbounded_String
    is
       Raw : constant String := To_String (Arguments (Arguments'First));
       S   : constant String := To_Lower (Raw);
    begin
       --  Empty or void types are not real semantic types; keep them explicit so
       --  callers can make a policy choice instead of silently inventing a
       --  substitute. This matches the architecture guidance to avoid dishonest
       --  or implicit type rewriting.
       if Raw = "" or else S = "void" then
          return To_Unbounded_String (""
            );
       elsif S = "string" or else S = "str" then
          return To_Unbounded_String ("Unbounded_String");
       elsif S = "int" or else S = "integer" then
          return To_Unbounded_String ("Integer");
       elsif S = "bool" or else S = "boolean" then
          return To_Unbounded_String ("Boolean");
       elsif S = "float" or else S = "real" then
          return To_Unbounded_String ("Float");
       else
          return To_Unbounded_String
            (Uml2Code_Identifiers.Ada_Case (Raw));
       end if;
    end Ada_Type_Filter;

    function Ada_Rel_Type_Filter
      (Arguments : Jintp.Unbounded_String_Array)
       return Unbounded_String
    is
       Raw : constant String := To_String (Arguments (Arguments'First));
    begin
       if Raw = "" or else To_Lower (Raw) = "void" then
          return To_Unbounded_String ("");
       end if;

       return To_Unbounded_String ("access ")
         & To_Unbounded_String
           (Uml2Code_Identifiers.Ada_Case (Raw));
    end Ada_Rel_Type_Filter;
