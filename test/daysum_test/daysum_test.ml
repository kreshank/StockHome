(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Daysum

(* Helper Functions and Printers*)

let aapl = DaySum.load_from "data/stock_info/aapl/aapl_cur.csv"

let daysum_tests =
  "Daysum.ml Test Suite"
  >::: [
         ("Aapl Simple Print" >:: fun _ -> print_string (DaySum.to_string aapl));
       ]

let _ = run_test_tt_main daysum_tests
