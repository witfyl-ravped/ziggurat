::  /+ zig-sys-smart
|%
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
--