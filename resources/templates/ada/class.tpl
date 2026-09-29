{% for s in stereotypes %}--  <<{{ s }}>>
{% endfor %}package {{ name|ada }} is

   type {{ name|ada }}_T is record
{% for attr in attributes %}      {{ attr.name|snake }} : {{ attr.type|ada }};
{% endfor %}   end record;

{% for op in operations %}   {{ op.declaration }}
{% endfor %}
end {{ name|ada }};
