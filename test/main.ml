(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Portfolio
open Parser
open Scraper
open Stock

let tests = "stocks test suite" >::: []
let _ = run_test_tt_main tests
