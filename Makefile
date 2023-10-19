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
	OCAMLRUNPARAM=b dune exec test/main.exe

chat:
	OCAMLRUNPARAM=b dune exec bin/main.exe

zip:
	rm -f stocks.zip
	zip -r stocks.zip . -x@exclude.lst

clean:
	dune clean
	rm -f stocks.zip
	
lines:
	make clean
	cloc --by-file --include-lang=OCaml .

