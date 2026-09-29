with Jintp;

package UML2Code.Filters is

   --  Registers the casing filters into the given JinTP environment.
   --  Filter names (use as {{ value|name }} in templates):
   --     snake       -> foo_bar
   --     screaming   -> FOO_BAR
   --     kebab       -> foo-bar
   --     train       -> Foo-Bar
   --     pascal      -> FooBar
   --     camel       -> fooBar
   --     ada         -> Foo_Bar

   procedure Register_All (Settings : in out Jintp.Environment);

end UML2Code.Filters;
