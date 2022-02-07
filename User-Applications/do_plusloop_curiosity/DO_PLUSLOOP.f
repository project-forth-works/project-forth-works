\ A DO...+LOOP with 2 limits
\ (c) J.J. Hoekstra

: P: postpone postpone ; immediate
: (h+loop) ( c u l a/s -- c u l )
	>r rot 2 pick 2 pick 2dup > if swap then
	rot r> + dup >r -rot within 0= -rot r> -rot ;

: (condswap) dup -rot 2dup > if swap then ;

: hdo p: (condswap) p: 2>r p: >r p: begin ; immediate

: hloop p: 1 p: h+loop ; immediate

: h+loop ( n -- )
	p: r> p: swap p: 2r> p: rot p: (h+loop) p: 2>r
	p: >r p: until p: rdrop p: rdrop p: rdrop ; immediate

: hi ( -- i ) p: r@ ; immediate

: hj ( -- j )
	p: r> p: 2r> p: r@ p: -rot p: 2>r p: swap p: >r ; immediate
