package body {{ name|ada }} is

{% for op in operations %}{% for line in op.body_lines %}{{ line }}
{% endfor %}
{% endfor %}end {{ name|ada }};
