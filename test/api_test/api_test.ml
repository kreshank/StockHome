(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Api

(* Helper Functions and Printers*)

(* API TESTS *)
let api_tests =
  "api.ml Test Suite"
  >::: [
         ( "run historical.py" >:: fun _ ->
           ignore (API.historical [ "aapl"; "msft"; "wow" ]) );
         ("run current.py" >:: fun _ -> ignore (API.current "aapl"));
       ]

let _ = run_test_tt_main api_tests
