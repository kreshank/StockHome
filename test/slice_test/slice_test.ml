(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Date
open Slice
(* Helper Functions and Printers*)

let aapl = Slice.make "AAPL" (12, 3, 2002)

let aal =
  Slice.make "AAL" ~open_price:12.84000015258789 ~high:13.100000381469727
    ~low:12.680000305175781 ~close_price:12.75 ~adjclose:12.75 ~volume:38342700
    (10, 02, 2023)

let slice_test =
  "slice.ml Test Suite"
  >::: [
         ("AAPL" >:: fun _ -> print_string (Slice.to_string aapl));
         ("AAL" >:: fun _ -> print_string (Slice.to_string aal));
       ]

let _ = run_test_tt_main slice_test
