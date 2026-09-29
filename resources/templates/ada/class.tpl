{% for w in with_clauses %}{{ w }}
{% endfor %}with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
{% for s in stereotypes %}--  <<{{ s }}>>
{% endfor %}package {{ name|ada }} is

{% for line in vector_instantiation_lines %}{{ line }}
{% endfor %}{{ type_opening }}
{% for line in record_body_lines %}{{ line }}
{% endfor %}   end record;

{% for op in operations %}   {{ op.declaration }}
{% endfor %}
end {{ name|ada }};
