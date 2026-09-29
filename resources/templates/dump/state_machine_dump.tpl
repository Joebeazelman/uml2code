================================================================================
STATE MACHINE: {{ name }}
================================================================================
  name    : {{ name }}
  initial : {{ initial }}

  States:
{% for s in states %}
    {{ s.name }}
      kind         : {{ s.kind }}
      parent       : {{ s.parent }}
      entry_action : {{ s.entry_action }}
      exit_action  : {{ s.exit_action }}
{% endfor %}

  Transitions:
{% for t in transitions %}
    {{ t.source }} -> {{ t.target }}
      event  : {{ t.event }}
      guard  : {{ t.guard }}
      action : {{ t.action }}
{% endfor %}
