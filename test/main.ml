(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Portfolio
open Parser
open Scraper
open Stock

(* Helper Functions and Printers*)

(* STOCKS TESTS *)
let tsla =
  Stock.of_input "TSLA" "Tesla, Inc." 220.11 (10, 19, 23) 698627000000.
    169685075.

let stock_tests =
  "Stock.ml Test Suite"
  >::: [
         ( "Tesla Simple Print" >:: fun _ ->
           print_string (Stock.of_string_simple tsla) );
         ( "Tesla Detailed Print" >:: fun _ ->
           print_string (Stock.of_string_detailed tsla) );
       ]

(* PARSER TESTS *)

let simple_map = Parser.of_csv "data/stock_info_simple.csv"
let full_map = Parser.of_csv "data/stock_info.csv"

let parser_tests =
  "parser.ml Test Suite"
  >::: [
         ( "Simple Parse 1" >:: fun _ ->
           print_string
             (Stock.of_string_detailed (Parser.to_stock "A" simple_map)) );
         ( "Simple Parse 2" >:: fun _ ->
           print_string
             (Stock.of_string_detailed (Parser.to_stock "AAL" simple_map)) );
         ( "Full Parse 1" >:: fun _ ->
           print_string
             (Stock.of_string_detailed (Parser.to_stock "A" full_map)) );
         ( "Full Parse 2" >:: fun _ ->
           print_string
             (Stock.of_string_detailed (Parser.to_stock "AAPL" full_map)) );
       ]

let portfolio_tests =
  "portfolio.ml Test Suite"
  >::: [
         ( "Portfolio Creation 1" >:: fun _ ->
           print_string (Portfolio.to_string (Portfolio.create_portfolio 123))
         );
       ]

let _ = run_test_tt_main stock_tests
let _ = run_test_tt_main parser_tests
let _ = run_test_tt_main portfolio_tests
