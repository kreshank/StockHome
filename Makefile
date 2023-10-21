.PHONY: test check

build:
	dune build

code:
	-dune build
	code .
	! dune build --watch

utop:
	OCAMLRUNPARAM=b dune utop src

test:
	OCAMLRUNPARAM=b dune exec test/parser_test/parser_test.exe
	OCAMLRUNPARAM=b dune exec test/portfolio_test/portfolio_test.exe
	OCAMLRUNPARAM=b dune exec test/stock_test/stock_test.exe

display:
	OCAMLRUNPARAM=b dune exec bin/display.exe

zip:
	rm -f stocks.zip
	zip -r stocks.zip . -x@exclude.lst

clean:
	dune clean
	rm -f stocks.zip
	
lines:
	make clean
	cloc --by-file --include-lang=OCaml .

