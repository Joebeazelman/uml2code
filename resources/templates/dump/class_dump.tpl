================================================================================
CLASS: {{ name }}
================================================================================
name        : {{ name }}
visibility  : {{ visibility }}

Attributes:
{% for attr in attributes %}
  {{ attr.name }}
    type         : {{ attr.type }}
    visibility   : {{ attr.visibility }}
    multiplicity : {{ attr.multiplicity }}
    default      : {{ attr.default }}
{% endfor %}

Operations:
{% for op in operations %}
  {{ op.name }}
    return_type : {{ op.return_type }}
    visibility  : {{ op.visibility }}
    parameters  :
{% for param in op.parameters %}
      {{ param.name }} : {{ param.type }}
{% endfor %}
{% endfor %}

================================================================================
FILTER REFERENCE  (input: "{{ name }}")
================================================================================
  raw         -> {{ name }}
  snake       -> {{ name|snake }}
  screaming   -> {{ name|screaming }}
  kebab       -> {{ name|kebab }}
  train       -> {{ name|train }}
  pascal      -> {{ name|pascal }}
  camel       -> {{ name|camel }}
  ada         -> {{ name|ada }}
