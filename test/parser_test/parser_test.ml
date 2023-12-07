(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stockhome
open Portfolio
open Parser
open Scraper
open Stock

(* Helper Functions and Printers*)

(* PARSER TESTS *)

let simple_map = Parser.of_csv "data/stock_info_simple.csv"
let full_map = Parser.of_csv "data/stock_info.csv"

let parser_tests =
  "parser.ml Test Suite"
  >::: [
         ( "Simple Parse 1" >:: fun _ ->
           print_string
             (Stock.to_string_detailed
                (Option.get (Parser.to_stock "A" simple_map))) );
         ( "Simple Parse 2" >:: fun _ ->
           print_string
             (Stock.to_string_detailed
                (Option.get (Parser.to_stock "AAL" simple_map))) );
         ( "Full Parse 1" >:: fun _ ->
           print_string
             (Stock.to_string_detailed
                (Option.get (Parser.to_stock "A" full_map))) );
         ( "Full Parse 2" >:: fun _ ->
           print_string
             (Stock.to_string_detailed
                (Option.get (Parser.to_stock "AAPL" full_map))) );
       ]

let _ = run_test_tt_main parser_tests
