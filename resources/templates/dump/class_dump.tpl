================================================================================
CLASS: {{ name }}
================================================================================
name        : {{ name }}
visibility  : {{ visibility }}
has_base    : {% if has_base %}yes{% else %}no{% endif %}
base_name   : {{ base_name }}
is_base     : {% if is_base %}yes{% else %}no{% endif %}

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
    has_return  : {% if op.has_return %}yes{% else %}no{% endif %}
{% endfor %}

Relations:
{% for rel in relations_out %}
  {{ rel.kind }}
    source              : {{ rel.source }}
    target              : {{ rel.target }}
    kind                : {{ rel.kind }}
    source_multiplicity : {{ rel.source_multiplicity }}
    target_multiplicity : {{ rel.target_multiplicity }}
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
