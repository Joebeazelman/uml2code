package {{ name|ada }} is

   type {{ name|ada }}_T is record
{% for attr in attributes %}      {{ attr.name|snake }} : {{ attr.type|ada }};
{% endfor %}   end record;

end {{ name|ada }};
