package {{ name|ada }} is

   type State is ({% for s in states %}{{ s.name|ada }}{% if not loop.last %}, {% endif %}{% endfor %});

   function Next_State
     (Current : State;
      Event   : String) return State;
   --  Returns the state reached from Current on Event, or Current
   --  if no transition matches. Implementation is provided in the
   --  package body.

   --  Transition map, grouped by source state:
{% for s in states %}   --
   --  From {{ s.name|ada }}:
{% for t in s.outgoing %}   --    {{ t.source|ada }} -> {{ t.target|ada }}
   --      event  : {{ t.event }}
   --      guard  : {{ t.guard }}
   --      action : {{ t.action }}
{% endfor %}{% endfor %}
end {{ name|ada }};
