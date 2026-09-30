{% for s in stereotypes %}--  <<{{ s }}>>
{% endfor %}package body {{ name|ada }} is
{% for op in operations %}
   {% if op.has_return %}function{% else %}procedure{% endif %} {{ op.name|ada }}{% if op.has_parameters %} ({% for p in op.parameters %}{{ p.name|snake }} : {% if p.is_string %}Unbounded_String{% else %}{{ p.type|ada }}{% endif %}{% if not loop.last %}; {% endif %}{% endfor %}){% endif %}{% if op.has_return %} return {% if op.return_type == "String" %}Unbounded_String{% else %}{{ op.return_type|ada }}{% endif %}{% endif %} is
   begin
{% if op.has_return %}      raise Program_Error with "{{ op.name }} not implemented";{% else %}      null;{% endif %}
   end {{ op.name|ada }};
{% endfor %}
end {{ name|ada }};
