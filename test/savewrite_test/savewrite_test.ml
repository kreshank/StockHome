(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stocks
open Portfolio
open Parser
open Scraper
open Stock
open Save_write

(* Helper Functions and Printers*)

(* SAVEWRITE TESTS *)

(*Example Maps*)
let simple_map = Parser.of_csv "data/stock_info_simple.csv"
let full_map = Parser.of_csv "data/stock_info.csv"

(*Example Portfolios*)
let empty_port = Portfolio.new_portfolio ()
let port1 = Portfolio.update_balance 100.00 empty_port
let port2 = Portfolio.update_stock_holding 200.00 port1

let save_write_tests =
  "savewrite.ml Test Suite"
  >::: [
         ("Port empty save" >:: fun _ -> SaveWrite.save empty_port);
         ( "Port empty load" >:: fun _ ->
           assert_equal 0.0 (Portfolio.get_balance (SaveWrite.load ())) );
         ("Port1 save" >:: fun _ -> SaveWrite.save port1);
         ( "Port1 load" >:: fun _ ->
           assert_equal 100.0 (Portfolio.get_balance (SaveWrite.load ())) );
         ("Port2 save" >:: fun _ -> SaveWrite.save port2);
         ( "Port2 load" >:: fun _ ->
           assert_equal 200.0 (Portfolio.get_stock_holdings (SaveWrite.load ()))
         );
         ("clear" >:: fun _ -> SaveWrite.clear ());
       ]

let _ = run_test_tt_main save_write_tests
