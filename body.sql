alter session set plsql_ccflags='string_op_debug:false';
create or replace package body txt as
--
-- V0.1
--

   function strtok      (str in varchar2, delimiter in varchar2) -- {
       return varchar2_t
   is
      tokens      varchar2_t :=varchar2_t();
      i           pls_integer;
      t           varchar2(4000);
   begin

      if str is null then
         return tokens;
      end if;

      t := str;

      loop
        i := instr(t, delimiter);

        tokens.extend;

        if i is null or i = 0  then /* none or last one found */
          tokens(tokens.count) :=  t;
          return tokens;
        else
          tokens(tokens.count) := substr(t, 0, i -1);
        end if;

        t := substr(t,i + length(delimiter),length(t));

      end loop;

   end strtok; -- }

   function grep_re(str in varchar2, regexp    in varchar2) return varchar2_t -- {
   is
      tokens       varchar2_t := varchar2_t();
      substr_      varchar2(4000);
      occurrence_  number := 1;
   begin

        loop -- {

          substr_ := regexp_substr(str, regexp, occurrence => occurrence_);

          if substr_ is null then
             return tokens;
          end if;

          tokens.extend;
          tokens(tokens.count) := upper(substr_);

          occurrence_ := occurrence_ + 1;

        end loop; -- }

   end grep_re; -- }

   function replace_entire_words(text clob, what varchar2, replacement varchar2) return clob -- {
   is 
        ret clob;
   begin

        ret := regexp_replace(
                        text,
           '(\A|\W)' || what        || '(\W|\Z)',
           '\1'      || replacement || '\2',
            1, 0, 'ni');

        return ret;

   end replace_entire_words; -- }

-- sprintf related  -- {

   function sprintf     (fmt in varchar2, parms in varchar2_t) return varchar2 -- {
   is -- {

      ret          varchar2(4000);

      cur_pos      number := 0;
      cur_format   varchar2(4000);
      len_format   number := length(fmt);

      left_aligned boolean;
      print_sign   boolean;

      cur_param    number := 0;
 -- }
   begin

      loop -- {
        -- Iterating over each character in the fmt.
        -- cur_pos points to the character 'being examined'.
        cur_pos := cur_pos + 1;

        exit when cur_pos > len_format;
          -- The iteration is over when cur_pos is past the last character.

        if substr(fmt, cur_pos, 1) = '%' then -- { A % sign is recognized.

          -- I assume the default: left aligned, sign (+) not printed
          left_aligned := false;
          print_sign   := false;

          -- Advance cur_pos so that it points to the character
          -- right of the %
          cur_pos := cur_pos + 1;

          if substr(fmt, cur_pos, 1) = '%' then -- {
             -- If % is immediately followed by another %, a literal
             -- % is wanted:
             ret := ret || '%';

             -- No need to further process the fmt (it is none)
             goto percent;
          end if; -- }

          if substr(fmt, cur_pos, 1) = '-' then -- {
             -- Current fmt will be left aligned
             left_aligned := true;
             cur_pos      := cur_pos + 1;
          end if; -- }

          if substr(fmt, cur_pos, 1) = '+' then -- {
             -- Print plus sign explicitely (only number, %d)
             print_sign := true;
             cur_pos    := cur_pos + 1;
          end if; -- }

          -- Now, reading the rest until 'd' or 's' and
          -- store it in cur_format.
          cur_format := '';

          -- cur_param points to the corresponding entry
          -- in parms
          cur_param  := cur_param + 1;

          loop -- {

            -- Make sure, iteration doesn't loop forever
            -- (for example if incorrect fmt is given)
            exit when cur_pos > len_format;

            if    substr(fmt, cur_pos, 1) = 'd' then -- {

              declare -- { some 'local' variables, only used for %d
                chars_left_dot number;
                chars_rite_dot number;
                chars_total    number;
                dot_pos        number;
                to_char_format varchar2(50);
                buf            varchar2(50);
                num_left_dot   char(1) := '9';
              -- }
              begin

              if cur_format is null then -- {
                 -- Format is: %d (maybe %-d, or %+d which SHOULD be
                 -- handled, but isn't)
                 ret := ret || to_char(parms(cur_param), 'TM9', 'nls_numeric_characters=''.,''');
                 -- current fmt specification finished, exit the loop
                 exit;
              end if; -- }

              -- does the current fmt contain a dot?
              -- dot_pos will be the position of the dot
              -- if it contains one, or will be 0 otherwise.
              dot_pos := instr(cur_format, '.');

              if substr(cur_format, 1, 1) = '0' then -- {
                -- Is the current fmt something like %0...d?
                num_left_dot := '0';
              end if; -- }

              -- determine how many digits (chars) are to be printed left
              -- and right of the dot.
              if dot_pos = 0 then -- {
                 -- If no dot, there won't be any characters rigth of the dot
                 -- (and no dot will be printed, either)
                 chars_rite_dot := 0;
                 chars_left_dot := to_number(cur_format);
                 chars_total    := chars_left_dot;
              -- }
              else -- {
                 chars_rite_dot := to_number(substr(cur_format,    dot_pos + 1));
                 chars_left_dot := to_number(substr(cur_format, 1, dot_pos - 1));
                 chars_total    := chars_left_dot + chars_rite_dot + 1;
              end if; -- }

              if parms(cur_param) is null then -- {
                 --  null h
                 ret := ret || lpad(' ', chars_total);
                 exit;
              end if; -- }

              to_char_format := lpad('9', chars_left_dot-1, '9') || num_left_dot;

              if dot_pos != 0 then  -- {
                 -- There will be a dot
                 to_char_format := to_char_format || '.' || lpad('9', chars_rite_dot, '9');
              end if; -- }

              if print_sign then -- {
                 to_char_format := 'S' || to_char_format;
                 -- The explicit printing of the sign widens the output by one character
                 chars_total := chars_total + 1;
              end if; -- }

              $if $$string_op_debug $then
                  dbms_output.put_line('cur_param: ' || cur_param || ', parms(cur_param) = ' || parms(cur_param) || '<');
              $end

              buf := to_char(to_number(parms(cur_param)), to_char_format, 'nls_numeric_characters=''.,''');

              if left_aligned then -- {
                 buf := rpad(trim(buf), chars_total);
              else
                 buf := lpad(trim(buf), chars_total);
              end if; -- }

              ret := ret || buf;

              exit;
              end;
            -- }
            elsif substr(fmt, cur_pos, 1) = 's' then -- {

              $if $$string_op_debug $then
                  dbms_output.put_line('string fmt, fmt = ' || fmt || ', cur_pos: ' || cur_pos);
              $end

              if cur_format is null then
                ret := ret || parms(cur_param);
                exit;
              end if;

              if left_aligned then
                 $if $$string_op_debug $then
                     dbms_output.put_line('  left_aligned, cur_format=' || cur_format);
                 $end
                 ret := ret || rpad(nvl(parms(cur_param), ' '), to_number(cur_format));
              else
                 $if $$string_op_debug $then
                     dbms_output.put_line('  right_aligned, cur_format=' || cur_format);
                 $end
                 ret := ret || lpad(nvl(parms(cur_param), ' '), to_number(cur_format));
              end if;

              exit;

            end if; -- }

           cur_format := cur_format || substr(fmt, cur_pos, 1);

           cur_pos := cur_pos + 1;
          end loop; -- }

        -- }
        else -- { A non-% character
          ret := ret || substr(fmt, cur_pos, 1);
        end if; -- }

        <<PERCENT>> null;

      end loop; -- }

      return ret;

   end sprintf; -- }

   function sprintf(fmt varchar2, p_01 varchar2                                                                           ) return varchar2 is begin return sprintf(fmt, varchar2_t(p_01                              )); end sprintf;
   function sprintf(fmt varchar2, p_01 varchar2, p_02 varchar2                                                            ) return varchar2 is begin return sprintf(fmt, varchar2_t(p_01, p_02                        )); end sprintf;
   function sprintf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2                                             ) return varchar2 is begin return sprintf(fmt, varchar2_t(p_01, p_02, p_03                  )); end sprintf;
   function sprintf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2                              ) return varchar2 is begin return sprintf(fmt, varchar2_t(p_01, p_02, p_03, p_04            )); end sprintf;
   function sprintf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2, p_05 varchar2               ) return varchar2 is begin return sprintf(fmt, varchar2_t(p_01, p_02, p_03, p_04, p_05      )); end sprintf;
   function sprintf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2, p_05 varchar2, p_06 varchar2) return varchar2 is begin return sprintf(fmt, varchar2_t(p_01, p_02, p_03, p_04, p_05, p_06)); end sprintf;
   -- }

-- printf related -- {
   procedure printf(fmt varchar2, parms in varchar2_t) is begin dbms_output.put_line(sprintf(fmt, parms)); end printf;
   procedure printf(fmt varchar2, p_01 varchar2                                                                           ) is begin dbms_output.put_line(sprintf(fmt, p_01                              )); end printf;
   procedure printf(fmt varchar2, p_01 varchar2, p_02 varchar2                                                            ) is begin dbms_output.put_line(sprintf(fmt, p_01, p_02                        )); end printf;
   procedure printf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2                                             ) is begin dbms_output.put_line(sprintf(fmt, p_01, p_02, p_03                  )); end printf;
   procedure printf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2                              ) is begin dbms_output.put_line(sprintf(fmt, p_01, p_02, p_03, p_04            )); end printf;
   procedure printf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2, p_05 varchar2               ) is begin dbms_output.put_line(sprintf(fmt, p_01, p_02, p_03, p_04, p_05      )); end printf;
   procedure printf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2, p_05 varchar2, p_06 varchar2) is begin dbms_output.put_line(sprintf(fmt, p_01, p_02, p_03, p_04, p_05, p_06)); end printf;
 -- }

   function is_number(str varchar2) return boolean is -- {
      num number;
   begin
   --
   -- Check if str is numerical.
   -- Consider using SQL function validate_conversion(expr as number) instead.
   --

   -- num := to_number(str, …, nls_param => 'nls_numeric_characters=''.,''');
      num := to_number(str);
      return true;

   exception when value_error then
      return false;
   end is_number; -- }

   function is_number_sql(str varchar2) return number is -- {
      num number;
   begin
   --
   -- Check if str is numerical.
   -- Consider using SQL function validate_conversion(expr as number) instead.
   --

      if is_number(str) then return 1; end if;

      return 0;

   end is_number_sql; -- }

   function from_(b boolean) return varchar2 is begin -- {
   
       if     b then return 'true' ; end if;
       if not b then return 'false'; end if;
                     return 'null' ;
   end from_; -- }

end txt;
/
show errors
