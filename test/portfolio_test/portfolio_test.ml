(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Portfolio
open Parser
open Scraper
open Stock

(* Helper Functions and Printers*)
let tsla =
  Stock.of_input "TSLA" "Tesla, Inc." 220.11 (10, 19, 23) 698627000000.
    169685075.

let portfolio_tests =
  "portfolio.ml Test Suite"
  >::: [
         ( "Portfolio 1: just created" >:: fun _ ->
           print_string (Portfolio.to_string (Portfolio.create_portfolio 123))
         );
         ( "Portfolio 2" >:: fun _ ->
           print_string
             (Portfolio.to_string
                (Portfolio.add_stock (Portfolio.create_portfolio 456) tsla)) );
       ]

let _ = run_test_tt_main portfolio_tests
