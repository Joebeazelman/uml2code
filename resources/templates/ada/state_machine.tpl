{% for s in stereotypes %}--  <<{{ s }}>>
{% endfor %}package {{ name|ada }} is

   --  State machine: {{ name }}
   --
   --  Source transitions:
{% for s in states %}   --    From {{ s.name|ada }}:
{% for st in s.stereotypes %}   --      <<{{ st }}>>
{% endfor %}{% for t in s.outgoing %}   --      {{ t.source|ada }} -> {{ t.target|ada }}
   --        event  : {{ t.event }}
   --        guard  : {{ t.guard }}
   --        action : {{ t.action }}
{% endfor %}{% endfor %}
   type State is ({% for s in states %}{{ s.name|ada }}{% if not loop.last %}, {% endif %}{% endfor %});

   --  Next_State returns the target of the first transition from
   --  Current whose event matches Event, or Current if none match.
   --  Guard conditions are not evaluated; see the source
   --  transitions above for the original conditions.

   function Next_State
     (Current : State;
      Event   : String) return State is
     (case Current is
{% for s in states %}         when {{ s.name|ada }} =>
           {{ s.case_arm }}{% if not loop.last %},{% endif %}
{% endfor %}     );

end {{ name|ada }};
