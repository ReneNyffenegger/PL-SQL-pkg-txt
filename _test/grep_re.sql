declare

   procedure test_grep_re_num (item varchar2, t in varchar2, expected varchar2_t) is -- {
      gotten varchar2_t;
   begin

      gotten := txt.grep_re(t, '\d+');

      if gotten.count != expected.count then
         raise_application_error(-20800, 'item: ' || item || ': cnt gotten: ' || gotten.count || ', cnt expected: ' || expected.count);
      end if;

      for i in 1 .. gotten.count loop -- {
          if nvl(gotten(i), chr(1)) != nvl(expected(i), chr(1)) then
             raise_application_error(-20800, 'item: ' || item || ', i=' || i || ', gotten: ' || gotten(i) || ', expected: ' || expected(i));
          end if;
      end loop; -- }

   end test_grep_re_num; -- }

begin

   test_grep_re_num('none'       , ''                             , varchar2_t(                    ));
   test_grep_re_num('abc_num_abc', 'one1two2three3forty-two42rest', varchar2_t( '1', '2', '3', '42'));
   test_grep_re_num(    'num_abc', '  11two2three3forty-two42rest', varchar2_t('11', '2', '3', '42'));
   test_grep_re_num('abc_num'    , 'one1two2three3forty-two42'    , varchar2_t( '1', '2', '3', '42'));

end;
/

--
-- Create a table with a large clob
--
create table tq84_test_large_clob(id integer, txt clob);

declare
   c clob;
begin
   dbms_lob.createtemporary(c, false);
   for i in 1 .. 10 loop
       dbms_lob.append(c, to_char(i, 'fm9999') || ': ' || lpad('.', 5000, '.') || case when mod(i,2) = 0 then chr(13) end || chr(10));
   end loop;
   insert into tq84_test_large_clob values (1, c);
end;
/

commit;

declare
   c clob;
   i pls_integer := 0;
begin
   select txt into c from tq84_test_large_clob where id = 1;

   
   for r in (select * from table(txt.grep_re_pipelined(c, '[^' || chr(10) || chr(13) || ']+')) ) loop
       i := i + 1;

       if r.column_value != to_char(i, 'fm9999') || ': ' || lpad('.', 5000, '.') then
          raise_application_error(-20800, 'Wrong data for grep_re_pipelined');
       end if;

   end loop;

end;
/

drop   table tq84_test_large_clob;
