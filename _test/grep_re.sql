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

   test_grep_re_num('none'        , ''                             , varchar2_t(                    ));
   test_grep_re_num('abc_num_abc', 'one1two2three3forty-two42rest', varchar2_t( '1', '2', '3', '42'));
   test_grep_re_num(    'num_abc', '  11two2three3forty-two42rest', varchar2_t('11', '2', '3', '42'));
   test_grep_re_num('abc_num'    , 'one1two2three3forty-two42'    , varchar2_t( '1', '2', '3', '42'));

end;
/

