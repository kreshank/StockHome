open Stocks
open Parser
open Stock

let data = "data/stock_info.csv"
let data = Parser.of_csv data

let rec chat () =
  print_string "Enter ticker: ";
  flush stdout;
  let ticker = read_line () in
  Printf.printf "You said: %s\n" ticker;
  let stock_info =
    match Parser.to_stock ticker data with
    | Some v -> v
    | None -> failwith "Not a Real Ticker"
  in
  let stock_info_string = Stock.to_string_simple stock_info in
  print_string stock_info_string;
  chat ()

let () =
  print_endline "\nWelcome to OCamlInvestor.\n";
  chat ()
