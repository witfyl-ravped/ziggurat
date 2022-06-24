/+  *mip
|%
+$  child  *
+$  parent  *
+$  phash  @x                     ::  Pedersen hash
+$  hash-req
  $%  [%cell head=phash tail=phash]
      [%atom val=@]
  ==
::
+$  cairo-hint
  $%  [%0 axis=@ leaf=phash path=(list phash)]
      [%1 res=phash]
      [%2 f1=phash f2=phash f1prod=phash f2prod=phash f1step=@ f2step=@]
      ::  encodes to
      ::   [3 subf-hash atom 0] if atom
      ::   [3 subf-hash 0 cell-hash cell-hash] if cell
      ::
::      $:  %3
::          subf=phash
::          $=  subf-res
::          $%  [%atom @]
::              [%cell head=phash tail=phash]
::          ==
::      ==
::      [%4 subf=phash atom=@]
::      [%5 subf1=phash subf2=phash]
::      [%6 subf1=phash subf2=phash subf3=phash]
::      [%7 subf1=phash subf2=phash]
::      [%8 subf1=phash subf2=phash]
::      [%9 axis=@ subf1=phash leaf=phash path=(list phash)]
::      [%10 axis=@ subf1=phash subf2=phash oldleaf=phash path=(list phash)]
      [%cons f1=phash f2=phash f1prod=phash f2prod=phash f1step=@ f2step=@]
      ::[%jet core=phash sample=* jet=@t]
  ==
:: subject -> formula -> hint
::+$  hints  (mip phash phash cairo-hint)
::+$  hints  (list cairo-hint)
+$  hints  $+(hints (list thee))
::+$  hints  (list thee)
::
+$  thee-hint
  $:  sh=phash
  $%  [%0 axis=@ leaf=phash path=(list phash)]
      [%1 res=phash]
      [%2 f1h=phash f2h=phash p1h=phash p2h=phash hres=phash f1=(list thee) f2=(list thee) f1step=@ f2step=@]
      [%cons f1h=phash f2h=phash p1h=phash p2h=phash f1=(list thee) f2=(list thee) f1step=@ f2step=@]
  ==  ==
::
++  thee
  $+(thee $@(~ thee-hint))
::  map of a noun's merkle children. root -> [left right]
+$  merk-tree  (map phash [phash phash])
::  map from axis to jet name
+$  jetmap  (map @ @tas)
::  Axis map of jets in stdlib
++  jets
  %-  ~(gas by *jetmap)
  :~  [2.398 %dec]
  ==
::  :~  [20 %add]
::      [21 %dec]
::      [4 %mul]
::  ==
--
