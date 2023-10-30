(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Portfolio
open Parser
open Scraper
open Stock

(* Helper Functions and Printers*)

let simple_map = Parser.of_csv "data/stock_info_simple.csv"

let tsla =
  Stock.of_input "TSLA" "Tesla, Inc." 220.11 (10, 19, 23) 698627000000.
    169685075.

let aapl =
  Stock.of_input "AAPL" "Apple, Inc." 168.22 (10, 19, 23) 698627000000.
    169685075.

let ptf1 = Portfolio.create_portfolio 123
let ptf2 = Portfolio.add_stock ptf1 tsla
let ptf3 = Portfolio.add_stock ptf2 aapl
let ptf4 = Portfolio.update_balance ptf3 200.0
let ptf5 = Portfolio.remove_stock ptf4 aapl
let ptf6 = Portfolio.update_balance ptf5 (-300.)

let portfolio_tests =
  "portfolio.ml Test Suite"
  >::: [
         ( "Portfolio 1: newly created" >:: fun _ ->
           print_string
             ("\n" ^ "Portfolio - newly created: " ^ Portfolio.to_string ptf1)
         );
         ( "Portfolio 2: add a stock" >:: fun _ ->
           print_string
             ("\n" ^ "Portfolio - add tsla: " ^ Portfolio.to_string ptf2) );
         ( "Portfolio 2: add a stock" >:: fun _ ->
           print_string
             ("\n" ^ "Portfolio - add aapl: " ^ Portfolio.to_string ptf3) );
         ( "Portfolio 2: add a stock" >:: fun _ ->
           print_string
             ("\n" ^ "Portfolio - add balance: " ^ Portfolio.to_string ptf4) );
         ( "Portfolio 2: add a stock" >:: fun _ ->
           print_string
             ("\n" ^ "Portfolio - remove aapl: " ^ Portfolio.to_string ptf5) );
       ]

let _ = run_test_tt_main portfolio_tests
