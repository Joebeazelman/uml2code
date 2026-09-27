package body Animals is

   pragma Warnings (Off, "function ""Name"" is not referenced");
   function Name (Self : in Dog) return Unbounded_String is
      pragma Unreferenced (Self);
   begin
      return Result : Unbounded_String do
         raise Program_Error with "Method Name is not implemented";
      end return;
   end Name;
   pragma Warnings (On, "function ""Name"" is not referenced");

   pragma Warnings (Off, "function ""Name"" is not referenced");
   function Name (Self : in Pet) return Unbounded_String is
      pragma Unreferenced (Self);
   begin
      return Result : Unbounded_String do
         raise Program_Error with "Method Name is not implemented";
      end return;
   end Name;
   pragma Warnings (On, "function ""Name"" is not referenced");


   procedure Speak (Self : in out Animal) is
      pragma Unreferenced (Self);
   begin
      null;
   end Speak;

   procedure Fetch (Self : in out Dog) is
      pragma Unreferenced (Self);
   begin
      null;
   end Fetch;

   procedure Move (Self : in out Dog) is
      pragma Unreferenced (Self);
   begin
      null;
   end Move;

end Animals;
