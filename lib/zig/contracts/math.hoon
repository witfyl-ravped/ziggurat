|_  =cart
++  write
  |=  =embryo
  ^-  chick
  |^
  ?~  args.inp  !!
  (process ;;(action u.args.inp) caller.inp)
  ::
  ++  process
    |=  [args=action caller-id=id]
    ?:  ?=(%make-value -.action)
      =/  salt=@           500
      =/  value-germ=germ  [%& salt [number=0]]
      =/  value-id=id      0x1
      =/  val=grain  
        [value-id lord=me.cart holder=caller-id town-id.cart value-germ]
      [%& changed=~ issued=(malt ~[[id.val val]]) crow=~]
    =/  val=grain  (snag 0 ~(val by owns.inp))
    ?>  =(caller-id holder.value)  :: only the holder of the grain can modify it
    ?>  ?=(%& -.germ.val)
    =/  =value  ;;(value data.p.germ.val)
    ?-    -.action
        %add
      =*  amount           amount.action
      =.  number.value     (add amount number.value)
      =.  data.p.germ.val  value  
      [%& changed=(malt ~[[id.val val]]) ~ ~]
    ::
        %sub
      =*  amount           amount.action
      ?>  (gte number.value amount.action)  :: prevent subtraction underflow from causing a crash
      =.  number.value     (sub amount.action number.value)
      =.  data.p.germ.val  value
      [%& changed=(malt ~[[id.val val]]) ~ ~]
    ::
        %mul
      =*  mult   multiplier.action
      ?:  =(0 mult)
        =.  data.p.germ.val  value(number 0)
        [%& changed=(malt ~[[id.val val]]) ~ ~]
      ?:  =(1 mult)
        [%& ~ ~ ~]
      =.  number.value     (add number.value number.value)
      =.  data.p.germ.val  value
      =/  =yolk
        :*  me.cart 
            `[%mul (dec mult)]
            my-grains=~
            cont-grains=(silt ~[id.val])
        ==
      [next=[to=me.cart town-id.cart yolk] roost=[changed=(malt ~[[id.val val]]) ~ ~]]
        %giv
      ::  ?<  =(holder.val who.action)  :: cannot give something to yourself
      [%& changed=(malt ~[[id.val val(holder who.action)]]) ~ ~]
    ==
  ::
  +$  value
    [number=@ud]  :: could extend to [number=@ud last-modified=@ud]
  ::
  +$  action
    $%  [%make-value initial=@ud]
        [%add amount=@ud]
        [%sub amount=@ud]
        [%mul multiplier=@ud]
        [%giv who=id]
        ::  [%swp ~]
        ::  [%fib n=@ud] would need multiple cont calls??
    ==
  ::
  +$  event
    $%
      [%owner-changed grain=id old=id new=id]
      :: [%hit-zero value=id]
    ==
  ::
++  read
  |_  =path
  ++  json
    ~
  ++  noun
    ?+    path  !!
        [%is-odd ~]
      ^-  ?
      =/  val=grain   (snag 0 ~(val by owns.inp))
      =/  value=germ  data.p.germ.val
      =(1 (mod number.value))
  --
--
