(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Portfolio
open Parser
open Scraper
open Stock

(* Helper Functions and Printers*)

let portfolio_tests =
  "portfolio.ml Test Suite"
  >::: [
         ( "Portfolio Creation 1" >:: fun _ ->
           print_string (Portfolio.to_string (Portfolio.create_portfolio 123))
         );
       ]

let _ = run_test_tt_main portfolio_tests
