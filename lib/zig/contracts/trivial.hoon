/=  library    /lib/zig/contracts/library/hoon
::  /=  library-2  /lib/zig/contracts/library-2/hoon
|_  =cart
++  write
  |=  =embryo
  ^-  chick
  ::  =/  number  (adding-arm:library-2 (special-arm:library 100))
  =/  number  (special-arm:library 100)
  =.  number  (dec number)
  [%& ~ ~ crow=~[[%you-arre-gayyy [%s `@t`number]]]]
++  read
  |_  =path
  ++  json
    ~
  ++  noun
    ~
  --
--
