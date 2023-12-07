(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stockhome
open Daysum

(* Helper Functions and Printers*)

let aapl = DaySum.load_from "data/test/aapl_cur.csv"

let daysum_tests =
  "Daysum.ml Test Suite"
  >::: [
         ( "time stamp" >:: fun _ ->
           assert_equal ((12, 5, 2023), (2, 51, 19)) (DaySum.timestamp aapl) );
         ( "52wk" >:: fun _ ->
           assert_equal (124.17, 198.23) (DaySum.week_range_52w aapl) );
         ("avg vol" >:: fun _ -> assert_equal 57268612 (DaySum.avg_day_vol aapl));
         ("1y targ" >:: fun _ -> assert_equal 198.01 (DaySum.targ_est_1y aapl));
         ("beta" >:: fun _ -> assert_equal 1.31 (DaySum.beta_5y_mly aapl));
         ("bid" >:: fun _ -> assert_equal (193.44, 900) (DaySum.bid aapl));
         ( "day range" >:: fun _ ->
           assert_equal (190.21, 194.40) (DaySum.day_range aapl) );
         ("eps" >:: fun _ -> assert_equal 6.14 (DaySum.eps_ttm aapl));
         ( "earnings" >:: fun _ ->
           assert_equal
             ((1, 31, 2024), (2, 05, 2024))
             (DaySum.earnings_date aapl) );
         ( "ex date" >:: fun _ ->
           assert_equal (11, 10, 2023) (DaySum.ex_date aapl) );
         ( "forward & yield" >:: fun _ ->
           assert_equal (0.96, 0.51) (DaySum.forward_div_yield aapl) );
         ( "market cap" >:: fun _ ->
           assert_equal 3008000000000. (DaySum.market_cap aapl) );
         ("open" >:: fun _ -> assert_equal 190.21 (DaySum.open_price aapl));
         ("pe ratio" >:: fun _ -> assert_equal 31.5 (DaySum.pe_ratio_ttm aapl));
         ("prev close" >:: fun _ -> assert_equal 189.43 (DaySum.prev_close aapl));
         ( "quote price" >:: fun _ ->
           assert_equal 193.4199981689453 (DaySum.quote_price aapl) );
         ("volume" >:: fun _ -> assert_equal 63350286 (DaySum.volume aapl));
         ("Aapl Simple Print" >:: fun _ -> print_string (DaySum.to_string aapl));
       ]

let _ = run_test_tt_main daysum_tests
