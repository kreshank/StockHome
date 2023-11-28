(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Portfolio
open Parser
open Scraper
open Stock

(* Helper Functions and Printers*)

let simple_map = Parser.of_csv "data/stock_info_simple.csv"

let tsla =
  Stock.of_input "TSLA" "Tesla, Inc." 220.11 (10, 19, 23) 698627000000. 123432

let aapl =
  Stock.of_input "AAPL" "Apple, Inc." 168.22 (10, 19, 23) 698627000000.
    169685075

let crnl =
  Stock.of_input "CRNL" "Cornell University" 18.65 (10, 19, 23) 698627000000.
    169685075

let buy = Portfolio.Buy

let p1 =
  Portfolio.(
    stock_transact Buy crnl 10000.
      (add_bank_account 400477288577
         (add_bank_account 300123242123
            (follow crnl
               (update_balance 1000000.
                  (follow aapl (follow tsla (new_portfolio ()))))))))

let portfolio_tests =
  "portfolio.ml Test Suite"
  >::: [
         ( "Portfolio #1: print" >:: fun _ ->
           print_string ("\n" ^ "Portfolio #1: " ^ Portfolio.to_string p1) );
       ]

let _ = run_test_tt_main portfolio_tests
