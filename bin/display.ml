(* If giving errors, remember to run [dune build] *)

(* read-eval-print loop *)
let rec repl (eval : string -> string) : unit =
  print_string "> ";
  let input = read_line () in
  match input with
  | "" -> print_endline "bye"
  | _ ->
      input |> eval |> print_endline;
      repl eval

let () =
  print_endline "\nWelcome to OCamlInvestor.\n";
  print_endline "Please enter the ticker:";
  print_string "> ";
  let ticker = read_line () in
  print_endline ticker
