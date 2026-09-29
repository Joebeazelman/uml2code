package {{ name|ada }} is
   type State is ({% for s in states %}{{ s.name|ada }}{% if not loop.last %}, {% endif %}{% endfor %});
end {{ name|ada }};
