{% for s in stereotypes %}--  <<{{ s }}>>
{% endfor %}package {{ name|ada }} is

   type State is ({% for s in states %}{{ s.name|ada }}{% if not loop.last %}, {% endif %}{% endfor %});

   --  Transition reference:
{% for s in states %}   --    From {{ s.name|ada }}:
{% for st in s.stereotypes %}   --      <<{{ st }}>>
{% endfor %}{% for t in s.outgoing %}   --      {{ t.source|ada }} -> {{ t.target|ada }}
   --        event  : {{ t.event }}
   --        guard  : {{ t.guard }}
   --        action : {{ t.action }}
{% endfor %}{% endfor %}
   function Next_State
     (Current : State;
      Event   : String) return State;
   --  Returns the state reached from Current on Event, or Current
   --  if no transition matches. Guard conditions are documented
   --  above but not evaluated.

end {{ name|ada }};
