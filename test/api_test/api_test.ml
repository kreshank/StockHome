(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stockhome
open Api

(* Helper Functions and Printers*)

(* API TESTS *)
let api_tests =
  "api.ml Test Suite"
  >::: [
         ("historical.py" >:: fun _ -> ignore (API.historical [ "aapl" ]));
         ("current.py" >:: fun _ -> ignore (API.current "aapl"));
         ("stats.py" >:: fun _ -> ignore (API.stats "aapl"));
         ("stats_val.py" >:: fun _ -> ignore (API.stats_valuation "aapl"));
       ]

let _ = run_test_tt_main api_tests
