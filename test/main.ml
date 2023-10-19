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
