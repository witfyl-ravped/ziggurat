/-  rollup, smart=zig-sys-smart
|%
+$  basket  (mop )  ::  transactions stored sorted by priority
::
+$  town-action
  $%  ::  administration
      $:  %init
          town-id=id:rollup
          =address:rollup
          starting-state=(unit state:smart)
          mode=availability-method:rollup
      ==
      [%clear-state ~]
      ::  transactions
      [%receive eggs=(set egg:smart)]
      ::  batching
      [%trigger-batch ~]
  ==
--