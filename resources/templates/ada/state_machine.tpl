package {{ name|ada }} is

   type State is ({% for s in states %}{{ s.name|ada }}{% if not loop.last %}, {% endif %}{% endfor %});

   --  Transition reference:
{% for t in transitions %}   --    {{ t.source|ada }} -> {{ t.target|ada }}
   --      event  : {{ t.event }}
   --      guard  : {{ t.guard }}
   --      action : {{ t.action }}
{% endfor %}
end {{ name|ada }};
