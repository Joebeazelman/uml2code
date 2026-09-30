package body {{ name|ada }} is

   function Next_State
     (Current : State;
      Event   : String) return State
   is
   begin
{% for s in states %}      if Current = {{ s.name|ada }} then
{% for t in s.outgoing %}         if Event = "{{ t.event }}" then
            return {{ t.target|ada }};
         end if;
{% endfor %}         return {{ s.name|ada }};
      end if;
{% endfor %}      return Current;
   end Next_State;

end {{ name|ada }};
