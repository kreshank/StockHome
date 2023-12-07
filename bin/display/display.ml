open Stockhome
open Parser
open Stock
open Portfolio

let rec load (lst : string list) (port : Portfolio.t) (parser : Parser.t) :
    Portfolio.t =
  match lst with
  | [] -> port
  | h :: t ->
      let stock = Parser.to_stock h parser in
      if stock = None then load t port parser
      else
        let port_u = Portfolio.follow (Option.get stock) port in
        load t port_u parser

let rec chat (port : Portfolio.t) (pars : Parser.t) =
  print_string
    "Would you like to, add a stock (A), remove a stock (R), or print the \
     portfolio (P)? Exit with anything else: ";
  flush stdout;
  let data = read_line () in
  match data with
  | "A" ->
      print_string "Enter Ticker: ";
      let ticker = read_line () in

      let port_u =
        match Parser.to_stock ticker pars with
        | Some v ->
            print_endline "Added.";
            Portfolio.follow v port
        | None ->
            print_endline "Invalid Ticker";
            port
      in
      chat port_u pars
  | "R" ->
      print_string "Enter Ticker: ";
      let ticker = read_line () in
      let port_u =
        match Parser.to_stock ticker pars with
        | Some v ->
            print_endline "Removed.";
            Portfolio.unfollow v port
        | None ->
            print_endline "Invalid Ticker";
            port
      in
      chat port_u pars
  | "P" ->
      print_endline (Portfolio.to_string port);
      chat port pars
  | _ -> print_endline "Exiting..."

let () =
  print_endline "\nWelcome to OCamlInvestor.\n";
  print_string "Enter CSV to be read: ";
  flush stdout;
  let data = read_line () in
  let data = Parser.of_csv data in
  print_string "Enter tickers to be entered into portfolio (e.g AAPL A MSFT): ";
  let tickers = String.split_on_char ' ' (read_line ()) in
  let port = load tickers (Portfolio.new_portfolio ()) data in
  let _ = chat port data in
  print_endline "Bye"
