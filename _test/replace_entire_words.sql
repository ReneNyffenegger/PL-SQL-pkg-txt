declare

   procedure cmp(text varchar2, word varchar2, replacement varchar2, expected varchar2) is -- {
       gotten varchar2(4000);
   begin

       gotten := txt.replace_entire_words(text, word, replacement);
       if gotten != expected then
          dbms_output.put_line('replace_entire_words: ' || gotten || ' != ' || expected);
       end if;

   end cmp; -- }

begin
   cmp('foo,bar,baz', 'foo', 'xxx', 'xxx,bar,baz');
   cmp('foo,bar,baz', 'bar', 'xxx', 'foo,xxx,baz');
   cmp('foo,bar,baz', 'baz', 'xxx', 'foo,bar,xxx');
   cmp('foo,bar,baz', 'FOO', 'xxx', 'xxx,bar,baz');
   cmp('foo,bar,baz', 'BAR', 'xxx', 'foo,xxx,baz');
   cmp('foo,bar,baz', 'BAZ', 'xxx', 'foo,bar,xxx');
   cmp('foo,bar,baz', 'oo' , 'xxx', 'foo,bar,baz');
end;
/
