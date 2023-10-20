(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Portfolio
open Parser
open Scraper
open Stock

(* STOCKS TESTS *)
let tsla =
  Stock.of_input "TSLA" "Tesla, Inc." 220.11 (10, 19, 23) 698627000000.
    169685075.

let tests =
  "Stock.ml Test Suite"
  >::: [
         ( "Tesla Simple Print" >:: fun _ ->
           print_string (Stock.of_string_simple tsla) );
         ( "Tesla Detailed Print" >:: fun _ ->
           print_string (Stock.of_string_detailed tsla) );
       ]

let _ = run_test_tt_main tests

(* PARSER TESTS *)
let s1 =
  ",open,high,low,close,adjclose,volume,ticker\n\
   2023-10-02,110.9,111.8,109.7,110.9,110.9,1569000,A"

let simple_map = Parser.of_csv "data/stock_info_simple.csv"

let tests =
  "parser.ml Test Suite"
  >::: [
         ( "Simple Parse" >:: fun _ ->
           print_string
             (Stock.of_string_detailed (Parser.to_stock "A" simple_map)) );
       ]

let _ = run_test_tt_main tests
