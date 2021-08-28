create or replace package txt as
--
-- V0.1
--

   function strtok (str in varchar2, delimiter    in varchar2) return varchar2_t;
   function grep_re(str in varchar2, regexp       in varchar2) return varchar2_t;

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

   function is_number(str varchar2) return boolean;

   function from_(b boolean) return varchar2;

end txt;
/
show errors
