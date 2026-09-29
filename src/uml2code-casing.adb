with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;   use Ada.Strings.Unbounded;

package body UML2Code.Casing is

   package String_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => Unbounded_String);
   use String_Vectors;

   function Is_Separator (C : Character) return Boolean is
     (C = '_' or else C = '-' or else C = ' ');

   function Tokenize (S : String) return String_Vectors.Vector is
      Result : String_Vectors.Vector;
      Buf    : Unbounded_String;
   begin
      for I in S'Range loop
         declare
            C    : constant Character := S (I);
            Prev : constant Character :=
              (if I > S'First then S (I - 1) else ASCII.NUL);
            Next : constant Character :=
              (if I < S'Last then S (I + 1) else ASCII.NUL);
            Boundary : Boolean := False;
         begin
            if Is_Separator (C) then
               if Length (Buf) > 0 then
                  Result.Append (Buf);
                  Buf := Null_Unbounded_String;
               end if;
            else
               if I > S'First and then not Is_Separator (Prev) then
                  if Is_Upper (C) and then Is_Lower (Prev) then
                     Boundary := True;
                  elsif Is_Upper (C) and then Is_Upper (Prev)
                    and then Is_Lower (Next)
                  then
                     Boundary := True;
                  end if;
               end if;

               if Boundary and then Length (Buf) > 0 then
                  Result.Append (Buf);
                  Buf := Null_Unbounded_String;
               end if;

               Append (Buf, C);
            end if;
         end;
      end loop;

      if Length (Buf) > 0 then
         Result.Append (Buf);
      end if;

      return Result;
   end Tokenize;

   function Title_Word (W : String) return String is
     (if W'Length = 0 then ""
      elsif W'Length = 1 then To_Upper (W)
      else To_Upper (W (W'First)) & To_Lower (W (W'First + 1 .. W'Last)));

   --  A separator of ASCII.NUL means "no separator" (used by
   --  PascalCase and CamelCase, where words are concatenated).

   procedure Append_Sep (Result : in out Unbounded_String;
                         Sep    : Character;
                         First  : Boolean) is
   begin
      if not First and then Sep /= ASCII.NUL then
         Append (Result, Sep);
      end if;
   end Append_Sep;

   function Join (Toks : String_Vectors.Vector;
                  Sep  : Character;
                  All_Lower : Boolean) return String
   is
      Result : Unbounded_String;
      First  : Boolean := True;
   begin
      for I in Toks.First_Index .. Toks.Last_Index loop
         Append_Sep (Result, Sep, First);
         First := False;
         declare
            W : constant String := To_String (Toks (I));
         begin
            if All_Lower then
               Append (Result, To_Lower (W));
            else
               Append (Result, Title_Word (W));
            end if;
         end;
      end loop;
      return To_String (Result);
   end Join;

   function Join_Upper (Toks : String_Vectors.Vector;
                        Sep  : Character) return String
   is
      Result : Unbounded_String;
      First  : Boolean := True;
   begin
      for I in Toks.First_Index .. Toks.Last_Index loop
         Append_Sep (Result, Sep, First);
         First := False;
         Append (Result, To_Upper (To_String (Toks (I))));
      end loop;
      return To_String (Result);
   end Join_Upper;

   function To_Snake_Case (Id : String) return String is
     (Join (Tokenize (Id), '_', All_Lower => True));

   function To_Screaming_Case (Id : String) return String is
     (Join_Upper (Tokenize (Id), '_'));

   function To_Kebab_Case (Id : String) return String is
     (Join (Tokenize (Id), '-', All_Lower => True));

   function To_Train_Case (Id : String) return String is
     (Join (Tokenize (Id), '-', All_Lower => False));

   function To_Pascal_Case (Id : String) return String is
     (Join (Tokenize (Id), ASCII.NUL, All_Lower => False));

   function To_Ada_Case (Id : String) return String is
     (Join (Tokenize (Id), '_', All_Lower => False));

   function To_Camel_Case (Id : String) return String is
      Toks : constant String_Vectors.Vector := Tokenize (Id);
   begin
      if Toks.Is_Empty then
         return "";
      end if;

      declare
         Result : Unbounded_String;
      begin
         Append (Result, To_Lower (To_String (Toks (Toks.First_Index))));
         for I in Toks.First_Index + 1 .. Toks.Last_Index loop
            Append (Result, Title_Word (To_String (Toks (I))));
         end loop;
         return To_String (Result);
      end;
   end To_Camel_Case;

end UML2Code.Casing;
