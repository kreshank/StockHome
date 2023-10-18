(*If giving errors, remember to run [dune build]*)

open OUnit2

let tests = "stocks test suite" >::: []
let _ = run_test_tt_main tests
