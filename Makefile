.PHONY: test check

build:
	dune build

code:
	-dune build
	code .
	! dune build --watch

utop:
	OCAMLRUNPARAM=b dune utop src

test-parser:
	OCAMLRUNPARAM=b dune exec test/parser_test/parser_test.exe

test-portfolio:
	OCAMLRUNPARAM=b dune exec test/portfolio_test/portfolio_test.exe

test-stock:
	OCAMLRUNPARAM=b dune exec test/stock_test/stock_test.exe

test-slice:
	OCAMLRUNPARAM=b dune exec test/slice_test/slice_test.exe

test-save-write:
	OCAMLRUNPARAM=b dune exec test/savewrite_test/savewrite_test.exe -- -runner sequential

test:
	make test-parser
	make test-portfolio
	make test-stock
	make test-slice
	make test-save-write

display:
	OCAMLRUNPARAM=b dune exec bin/display.exe

zip:
	rm -f stocks.zip
	zip -r stocks.zip .

clean:
	dune clean
	rm -f stocks.zip
	
lines:
	make clean
	cloc --by-file --include-lang=OCaml .

