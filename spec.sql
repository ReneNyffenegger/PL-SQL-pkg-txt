create or replace package txt as
--
-- V0.3
--

   function strtok (str in varchar2, delimiter    in varchar2) return varchar2_t;
   function grep_re(str in clob    , re           in varchar2) return varchar2_t;

   function grep_re_pipelined(str in clob, re in varchar2) return clob_t pipelined;

   function replace_entire_words(text clob, what varchar2, replacement varchar2) return clob;

-- sprintf related -- {
--         see http://www.adp-gmbh.ch/blog/2007/04/14.php
--         see also utl_lms
   function sprintf(fmt varchar2, parms in varchar2_t) return varchar2;
   function sprintf(fmt varchar2, p_01 varchar2                                                                           ) return varchar2;
   function sprintf(fmt varchar2, p_01 varchar2, p_02 varchar2                                                            ) return varchar2;
   function sprintf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2                                             ) return varchar2;
   function sprintf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2                              ) return varchar2;
   function sprintf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2, p_05 varchar2               ) return varchar2;
   function sprintf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2, p_05 varchar2, p_06 varchar2) return varchar2;
 -- }

-- printf related -- {
   procedure printf(fmt varchar2, parms varchar2_t);
   procedure printf(fmt varchar2, p_01 varchar2                                                                           );
   procedure printf(fmt varchar2, p_01 varchar2, p_02 varchar2                                                            );
   procedure printf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2                                             );
   procedure printf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2                              );
   procedure printf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2, p_05 varchar2               );
   procedure printf(fmt varchar2, p_01 varchar2, p_02 varchar2, p_03 varchar2, p_04 varchar2, p_05 varchar2, p_06 varchar2);
 -- }

--
-- Check if str is numerical.
-- Consider using SQL function validate_conversion(expr as number) instead.
--
   function is_number    (str varchar2) return boolean;
   function is_number_sql(str varchar2) return number;

   function from_(b boolean) return varchar2;

end txt;
/
show errors
