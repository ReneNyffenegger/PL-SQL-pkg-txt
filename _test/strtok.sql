declare


   procedure split_on_comma (item varchar2, t in varchar2, expected varchar2_t) is -- {
      gotten varchar2_t;
   begin

      gotten := txt.strtok(t, ',');

      if gotten.count != expected.count then -- {
         raise_application_error(-20800, 'item: ' || item || ': cnt gotten: ' || gotten.count || ', cnt expected: ' || expected.count);
      end if; -- }

      for i in 1 .. gotten.count loop -- {
          if nvl(gotten(i), chr(1)) != nvl(expected(i), chr(1)) then
             raise_application_error(-20800, 'item: ' || item || ', i=' || i || ', gotten: ' || gotten(i) || ', expected: ' || expected(i));
          end if;
      end loop; -- }

   end split_on_comma; -- }

begin

   split_on_comma('none'        , ''            , varchar2_t(                               ));
   split_on_comma('one'         ,'one'          , varchar2_t('one'                          ));
   split_on_comma('hello_world','hello,world'   , varchar2_t('hello', 'world'               ));
   split_on_comma('foo_bar_baz','foo,,bar,,baz,', varchar2_t('foo', '', 'bar', '', 'baz', ''));

end;
/
