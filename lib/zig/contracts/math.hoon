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
    ?-    -.action
        %make-value
      [%& ~ ~ ~]
    ::
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
  +$  action
    $%  [%make-value ~]
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
