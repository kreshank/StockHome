(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Date
open Slice
(* Helper Functions and Printers*)

let slice_test = "slice.ml Test Suite" >::: []
let _ = run_test_tt_main slice_test
