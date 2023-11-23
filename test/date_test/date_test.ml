(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Date

(* Helper Functions and Printers*)

(* DATE TESTS *)
let date_tests =
  "date.ml Test Suite"
  >::: [
         ("day 58" >:: fun _ -> assert_equal 58 (Date.doy (02, 27, 1994)));
         ("day 184" >:: fun _ -> assert_equal 184 (Date.doy (07, 03, 2017)));
         ( "date difference" >:: fun _ ->
           assert_equal ~printer:string_of_int 8527
             (Date.diff (02, 27, 1994) (07, 03, 2017)) );
       ]

let _ = run_test_tt_main date_tests
