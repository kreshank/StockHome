build:
	dune build

utop:
	OCAMLRUNPARAM=b dune utop src

test:
	OCAMLRUNPARAM=b dune exec test/main.exe

display:
	OCAMLRUNPARAM=b dune exec bin/main.exe