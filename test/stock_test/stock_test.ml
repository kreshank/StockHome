(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stockhome
open Portfolio
open Parser
open Scraper
open Stock

(* Helper Functions and Printers*)

(* STOCKS TESTS *)
let tsla =
  Stock.of_input "TSLA" "Tesla, Inc." 220.11
    ((10, 19, 23), (0, 0, 0))
    698627000000. 169685075

let aapl = Stock.make "AAPL"

let stock_tests =
  "Stock.ml Test Suite"
  >::: [
         ("Tesla Simple Print" >:: fun _ -> print_string (Stock.to_string tsla));
         ( "Tesla Detailed Print" >:: fun _ ->
           print_string (Stock.to_string_detailed tsla) );
         ( "aapl detailed print" >:: fun _ ->
           print_string (Stock.to_string_detailed aapl) );
         ( "aapl update" >:: fun _ ->
           print_string (Stock.update aapl |> Stock.to_string_detailed) );
       ]

let _ = run_test_tt_main stock_tests
