(* Build a network from scratch!

    BUILD       - Build a mesh network from scratch

  The current version works on two ring node connections only!


Het opbouwen van het netwerk kan beter, het komt nu niet verder dan één ring!
Door de indirecte tabellen te gebruiken om de tweede ring, etc. samen te stellen.
Het aantal indirecte nodes kan als referentie gebruikt worden.

1) Een node start het scannen
2) Alle gevonden nodes scannen ook
3) Alle nodes wisselen verbinding data uit
Start lus, en bewaar aantal indirecte nodes:
  a) Alle indirecte nodes scannen nu ook
  b) Alle nodes wisselen verbinding data uit
Stop lus als aantal indirecte nodes niet veranderd is
4) Alle nodes verzamelen node type info


Het bouwen gaat nu binnen 4 sec. maar het kan sneller...

SCAN kan in 80 millisec. nu allen 100 millisec. timeout
HOP  kan in 20 millisec.
INFO kan in 30 millisec.

*)

v: inside also
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

v: fresh
\ End ;;;
