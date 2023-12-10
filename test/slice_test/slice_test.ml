(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stockhome
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
         ("AAPL ticker" >:: fun _ -> assert_equal "AAPL" (Slice.ticker aapl));
         ("AAPL open_price" >:: fun _ -> assert_equal 0. (Slice.open_price aapl));
         ("AAPL high" >:: fun _ -> assert_equal 0. (Slice.high aapl));
         ("AAPL low" >:: fun _ -> assert_equal 0. (Slice.low aapl));
         ( "AAPL close_price" >:: fun _ ->
           assert_equal 0. (Slice.close_price aapl) );
         ("AAPL adjclose" >:: fun _ -> assert_equal 0. (Slice.adjclose aapl));
         ("AAPL volume" >:: fun _ -> assert_equal 0 (Slice.volume aapl));
         ("AAPL time" >:: fun _ -> assert_equal (12, 3, 2002) (Slice.time aapl));
         ("AAL ticker" >:: fun _ -> assert_equal "AAL" (Slice.ticker aal));
         ( "AAL open_price" >:: fun _ ->
           assert_equal 12.84000015258789 (Slice.open_price aal) );
         ( "AAL high" >:: fun _ ->
           assert_equal 13.100000381469727 (Slice.high aal) );
         ("AAL low" >:: fun _ -> assert_equal 12.680000305175781 (Slice.low aal));
         ( "AAL close_price" >:: fun _ ->
           assert_equal 12.75 (Slice.close_price aal) );
         ("AAL adjclose" >:: fun _ -> assert_equal 12.75 (Slice.adjclose aal));
         ("AAL volume" >:: fun _ -> assert_equal 38342700 (Slice.volume aal));
         ("AAL time" >:: fun _ -> assert_equal (10, 02, 2023) (Slice.time aal));
         ("AAPL" >:: fun _ -> print_string (Slice.to_string aapl));
         ("AAPL" >:: fun _ -> print_string (Slice.to_string_detailed aapl));
         ("AAL" >:: fun _ -> print_string (Slice.to_string aal));
         ("AAL" >:: fun _ -> print_string (Slice.to_string_detailed aal));
       ]

let _ = run_test_tt_main slice_test
