(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stockhome
open Portfolio
open Stock

(* Helper Functions and Printers*)

(* STOCKS TESTS *)
let tsla =
  Stock.of_input "TSLA" "Tesla, Inc." 220.11
    ((10, 19, 23), (0, 0, 0))
    698627000000. 169685075

let aapl = Stock.make "AAPL"

let stock_tests =
  "Stock.ml Test Suite"
  >::: [
         ("TSLA ticker" >:: fun _ -> assert_equal "TSLA" (Stock.ticker tsla));
         ("TSLA name" >:: fun _ -> assert_equal "Tesla, Inc." (Stock.name tsla));
         ("TSLA price" >:: fun _ -> assert_equal 220.11 (Stock.price tsla));
         ( "TSLA date" >:: fun _ ->
           assert_equal ((10, 19, 23), (0, 0, 0)) (Stock.time tsla) );
         ( "TSLA market cap" >:: fun _ ->
           assert_equal 698627000000. (Stock.market_cap tsla) );
         ("TSLA volume" >:: fun _ -> assert_equal 169685075 (Stock.volume tsla));
         ("Tesla Simple Print" >:: fun _ -> print_string (Stock.to_string tsla));
         ( "aapl detailed print" >:: fun _ ->
           print_string (Stock.to_string_detailed aapl) );
         ( "aapl update" >:: fun _ ->
           print_string (Stock.update aapl |> Stock.to_string_detailed) );
       ]

let _ = run_test_tt_main stock_tests
