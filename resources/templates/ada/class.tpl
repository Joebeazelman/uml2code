{% for pkg in referenced_packages %}with {{ pkg|ada }};
{% endfor %}{% if has_string_attribute %}with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
{% endif %}{% if has_vector_targets %}with Ada.Containers.Vectors;
{% endif %}{% for s in stereotypes %}--  <<{{ s }}>>
{% endfor %}package {{ name|ada }} is

{% for pkg in referenced_packages %}   package {{ pkg|ada }}_Pkg renames {{ pkg|ada }};
{% endfor %}{% for v in vector_targets %}   package {{ v|ada }}_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Positive,
      Element_Type => {{ v|ada }}_Pkg.{{ v|ada }}_T);
{% endfor %}
{% if has_base %}   type {{ name|ada }}_T is new {{ base_name|ada }}_Pkg.{{ base_name|ada }}_T with record
{% elif is_base %}   type {{ name|ada }}_T is tagged record
{% else %}   type {{ name|ada }}_T is record
{% endif %}{% for attr in attributes %}      {{ attr.name|snake }} : {% if attr.is_string %}Unbounded_String{% else %}{{ attr.type|ada }}{% endif %};
{% endfor %}{% for rel in relations_out %}      {{ rel.field_name|snake }} : {% if rel.target_multiplicity_class == "multi" %}{{ rel.target|ada }}_Pkg.{{ rel.target|ada }}_Vectors.Vector{% elif rel.is_composition %}{{ rel.target|ada }}_Pkg.{{ rel.target|ada }}_T{% else %}access {{ rel.target|ada }}_Pkg.{{ rel.target|ada }}_T{% endif %};
{% endfor %}{% if not has_fields %}      null;
{% endif %}   end record;
{% for op in operations %}
   {% if op.has_return %}function{% else %}procedure{% endif %} {{ op.name|ada }}{% if op.has_parameters %} ({% for p in op.parameters %}{{ p.name|snake }} : {% if p.is_string %}Unbounded_String{% else %}{{ p.type|ada }}{% endif %}{% if not loop.last %}; {% endif %}{% endfor %}){% endif %}{% if op.has_return %} return {% if op.return_type == "String" %}Unbounded_String{% else %}{{ op.return_type|ada }}{% endif %}{% endif %};
{% endfor %}
end {{ name|ada }};
