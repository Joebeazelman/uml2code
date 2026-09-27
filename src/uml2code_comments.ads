--  Ada-specific comment rendering for generated source files.
--
--  This is deliberately kept out of templates: templates receive rendered
--  comment_lines and only decide where those lines are placed.

with Jintp;

package Uml2Code_Comments is

    --  Convert semantic comment text into Ada comment lines. Existing line
    --  breaks are preserved. A wrap width of zero disables wrapping entirely,
    --  which keeps generated output deterministic and allows callers to defer
    --  presentation policy to the adapter layer.
    function Comment_Lines
      (Text       : String;
       Wrap_Width : Natural := 78) return Jintp.List;

end Uml2Code_Comments;
