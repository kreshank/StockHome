(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stockhome
open Portfolio
open Parser
open Scraper
open Stock
open Savewrite

(* Helper Functions and Printers*)

(* SAVEWRITE TESTS *)

(*Example Maps*)
let simple_map = Parser.of_csv "data/stock_info_simple.csv"
let full_map = Parser.of_csv "data/stock_info.csv"

(* Example Stocks *)
let tsla =
  Stock.of_input "TSLA" "Tesla, Inc." 220.11
    ((10, 19, 2023), (0, 0, 0))
    698627000000. 169685075

let cock =
  Stock.of_input "cock" "cock, Inc." 220.11
    ((10, 10, 2010), (0, 0, 0))
    698627000000. 169685075

let buy : Portfolio.transaction =
  {
    ticker = "TSLA";
    option = Buy;
    price = 220.11;
    quantity = 100.;
    time = (10, 10, 2010);
  }

let sell : Portfolio.transaction =
  {
    ticker = "cock";
    option = Sell;
    price = 220.11;
    quantity = 200.;
    time = (10, 10, 2010);
  }

(*Example Portfolios*)
let empty_port = Portfolio.new_portfolio ()
let port1 = Portfolio.update_balance 100.00 empty_port
let port2 = Portfolio.update_stock_holding 200.00 port1
let port3 = Portfolio.add_bank_account 1 port2
let port4 = Portfolio.add_bank_account 2 port3
let port5 = Portfolio.add_bank_account 3 port4
let port6 = Portfolio.follow tsla port5
let port7 = Portfolio.follow cock port6
let port8 = Portfolio.update_history buy port7
let port9 = Portfolio.update_history sell port8

let save_write_tests =
  "savewrite.ml Test Suite"
  >::: [
         ( "Port_empty save/load" >:: fun _ ->
           SaveWrite.save empty_port;
           assert_equal 0.0 (Portfolio.get_balance (SaveWrite.load ())) );
         ( "Port1 save/load" >:: fun _ ->
           SaveWrite.save port1;
           assert_equal 100.0 (Portfolio.get_balance (SaveWrite.load ())) );
         ( "Port2 save/load" >:: fun _ ->
           SaveWrite.save port2;
           assert_equal 200.0 (Portfolio.get_stock_holdings (SaveWrite.load ()))
         );
         ( "Port3 save/load" >:: fun _ ->
           SaveWrite.save port3;
           assert_equal [ 1 ] (Portfolio.get_bank_accounts (SaveWrite.load ()))
         );
         ( "Port4 save/load" >:: fun _ ->
           SaveWrite.save port4;
           assert_equal [ 1; 2 ]
             (Portfolio.get_bank_accounts (SaveWrite.load ())) );
         ( "Port5 save/load" >:: fun _ ->
           SaveWrite.save port5;
           assert_equal [ 1; 2; 3 ]
             (Portfolio.get_bank_accounts (SaveWrite.load ())) );
         ( "Port6 save/load" >:: fun _ ->
           SaveWrite.save port6;
           assert_equal tsla
             (List.nth (Portfolio.get_followed_stocks (SaveWrite.load ())) 0) );
         ( "Port7 save/load" >:: fun _ ->
           SaveWrite.save port7;
           assert_equal cock
             (List.nth (Portfolio.get_followed_stocks (SaveWrite.load ())) 1) );
         ( "Port8 save/load" >:: fun _ ->
           SaveWrite.save port8;
           assert_equal buy
             (List.nth (Portfolio.get_history (SaveWrite.load ())) 0) );
         ( "Port9 save/load" >:: fun _ ->
           SaveWrite.save port9;
           assert_equal sell
             (List.nth (Portfolio.get_history (SaveWrite.load ())) 1) );
       ]

let _ = run_test_tt_main save_write_tests
