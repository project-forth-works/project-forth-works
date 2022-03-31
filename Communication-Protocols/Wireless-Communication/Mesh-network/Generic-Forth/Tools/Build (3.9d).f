\ Build a network from scratch!
\
\ BUILD       - Build a mesh network from scratch
\
\ This version works on multi ring node connections!
\

\ Use the tables NEW & INDIRECT to reduce the number of redundand actions
create NEW      #map allot      \ Help accu to find new hopping nodes 
: BUILD     ( -- )
    scanx cr  direct >work  ch s >others  \ SCANX on myself & all new found nodes
    hop cr   direct >work  ch h >others   \ HOP on myself & all new found nodes
    1  begin                    \ Indirect nodes not scanned yet!
        indirect count*         \ old new
    tuck <> while               \ new
        indirect new #map move  \ Copy node map
        new >work  ch s >others \ SCANX on indirect nodes
        hop cr  all >work  ch h >others \ HOP on all nodes
    repeat  drop
    finish ;

\ End ;;;
