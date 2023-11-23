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
         ("dow : monday" >:: fun _ -> assert_equal 0 (Date.dow (07, 03, 2017)));
         ("dow : sunday" >:: fun _ -> assert_equal 6 (Date.dow (01, 01, 2023)));
         ( "date difference" >:: fun _ ->
           assert_equal ~printer:string_of_int 8527
             (Date.diff (02, 27, 1994) (07, 03, 2017)) );
         ( "next_business after thanksgiving 2023" >:: fun _ ->
           assert_equal ~printer:Date.to_string (11, 24, 2023)
             (Date.next_business (11, 22, 2023)) );
         ( "next_business, new years 1/1/23 is a sunday -->, next business is \
            tuesday"
         >:: fun _ ->
           assert_equal ~printer:Date.to_string (01, 03, 2023)
             (Date.next_business (12, 31, 2022)) );
         ( "next_business, new years 1/1/23 is a saturday, observed on friday, \
            next business is monday"
         >:: fun _ ->
           assert_equal ~printer:Date.to_string (01, 03, 2022)
             (Date.next_business (12, 30, 2021)) );
         ( "next_business, if isn't a business day, returns same as previous"
         >:: fun _ ->
           assert_equal ~printer:Date.to_string
             (Date.next_business (12, 31, 2022))
             (Date.next_business (01, 01, 2023)) );
       ]

let _ = run_test_tt_main date_tests
