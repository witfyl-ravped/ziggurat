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
      =/  val=grain  [value-id lord=me.cart holder=caller-id town-id.cart value-germ]
      [%& changed=~ issued=(malt ~[[id.val val]]) crow=~]
    =/  val=grain  (snag 0 ~(val by owns.inp))
    ?>  =(caller-id holder.value)
    ?>  ?=(%& -.germ.val)
    =/  =value  ;;(value data.p.germ.val)
    ?-    -.action
        %add
      [%& ~ ~ ~]
    ::
        %sub
      [%& ~ ~ ~]
    ::
        %fib
      [%& ~ ~ ~]
    ==
  ::
  +$  value
    [number=@ud]  :: could extend to [number=@ud last-modified=@ud]
  ::
  +$  action
    $%  [%make-value initial=@ud]
        [%add amount=@ud]
        [%sub amount=@ud]
        [%fib n=@ud]
    ==
  ::
  +$  event
    $%
      [%hit-zero value=id]
    ==
  ::
++  read
  |_  =path
  ++  json
    ~
  ++  noun
    ?+    path  !!
        [%is-odd ~]
      !!
  --
--
