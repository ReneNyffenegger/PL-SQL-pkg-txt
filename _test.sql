select
  txt.replace_entire_words('foo,bar,baz', 'foo', 'xxx') r1,
  txt.replace_entire_words('foo,bar,baz', 'bar', 'xxx') r2,
  txt.replace_entire_words('foo,bar,baz', 'baz', 'xxx') r3,
  txt.replace_entire_words('foo,bar,baz', 'FOO', 'xxx') r4,
  txt.replace_entire_words('foo,bar,baz', 'BAR', 'xxx') r5,
  txt.replace_entire_words('foo,bar,baz', 'BAZ', 'xxx') r6,
  txt.replace_entire_words('foo,bar,baz', 'oo' , 'xxx') r7
from
  dual;
