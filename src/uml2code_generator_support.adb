with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Text_IO;                 use Ada.Text_IO;

with Uml2Code_Template_Path;

package body Uml2Code_Generator_Support is

   procedure Write_File (Path, Content : String) is
      F : File_Type;
   begin
      Create (F, Out_File, Path);
      Put (F, Content);
      Close (F);
   end Write_File;

   function Render_Dict
     (Subdir   : String;
      Template : String;
      D        : Jintp.Dictionary;
      Env      : in out Jintp.Environment) return String
   is
      Path    : constant String := Uml2Code_Template_Path.Locate (Subdir, Template);
   begin
      return Jintp.Render (Path, D, Env);
   end Render_Dict;

   procedure Render_To_Dict
     (Subdir   : String;
      Template : String;
      Output   : String;
      D        : Jintp.Dictionary;
      Env      : in out Jintp.Environment)
   is
      Path    : constant String := Uml2Code_Template_Path.Locate (Subdir, Template);
      Content : constant String := Jintp.Render (Path, D, Env);
   begin
      Write_File (Output, Content);
      Put_Line ("wrote " & Output);
   end Render_To_Dict;

   procedure Render_If_Missing_Dict
     (Subdir   : String;
      Template : String;
      Output   : String;
      D        : Jintp.Dictionary;
      Env      : in out Jintp.Environment)
   is
   begin
      if Ada.Directories.Exists (Output) then
         Put_Line ("kept  " & Output);
      else
         Render_To_Dict (Subdir, Template, Output, D, Env);
      end if;
   end Render_If_Missing_Dict;

   procedure Refuse_Crate_Internal_Output (Out_Dir : String) is
      function Contains (Haystack, Needle : String) return Boolean is
        (Ada.Strings.Fixed.Index (Haystack, Needle) > 0);
   begin
      if Contains (Out_Dir, "uml2code/tests")
        or else Contains (Out_Dir, "uml2code/src")
        or else Contains (Out_Dir, "plantuml_parser/tests")
        or else Contains (Out_Dir, "plantuml_parser/src")
      then
         raise Constraint_Error with
           "refusing to write into the crate tree: " & Out_Dir;
      end if;
   end Refuse_Crate_Internal_Output;

end Uml2Code_Generator_Support;
