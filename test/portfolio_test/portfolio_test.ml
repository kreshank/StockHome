(*If giving errors, remember to run [dune build]*)

open OUnit2
open Stockhome
open Portfolio
open Scraper
open Stock

(* Helper Functions and Printers*)

let tsla =
  Stock.of_input "TSLA" "Tesla, Inc." 220.11
    ((10, 19, 23), (0, 0, 0))
    698627000000. 123432

let aapl =
  Stock.of_input "AAPL" "Apple, Inc." 168.22
    ((10, 19, 23), (0, 0, 0))
    698627000000. 169685075

let crnl =
  Stock.of_input "CRNL" "Cornell University" 18.65
    ((10, 19, 23), (0, 0, 0))
    3456787654. 34567654

let buy = Portfolio.Buy
let sell = Portfolio.Sell

let h1 : Portfolio.transaction =
  {
    ticker = "MSFT";
    option = Buy;
    price = 220.11;
    quantity = 10.;
    time = (12, 10, 2010);
  }

let h2 : Portfolio.transaction =
  {
    ticker = "MSFT";
    option = Buy;
    price = 220.11;
    quantity = 20.;
    time = (20, 10, 2013);
  }

let p = Portfolio.new_portfolio ()

let p1 =
  Portfolio.(
    new_portfolio () |> update_balance 1000000. |> update_balance (-500000.)
    |> add_bank_account 430410204567
    |> follow "TSLA" |> fst |> follow "AAPL" |> fst |> follow "A" |> fst
    |> ticker_transact "buy" "AAPL" "45.5"
    |> ticker_transact "sell" "AAPL" "20.2"
    |> ticker_transact "buy" "TSLA" "62.7"
    |> ticker_transact "buy" "A" "17")

let portfolio_tests =
  "portfolio.ml Test Suite"
  >::: [
         (* Prints *)
         ( "Print Empty Portfolio" >:: fun _ ->
           print_string ("Portfolio #0: \n" ^ Portfolio.to_string p) );
         ( "Print Portfolio 1" >:: fun _ ->
           print_string ("Portfolio #1: \n" ^ Portfolio.to_string p1) );
         (* Testing option functions *)
         ( "Option to string" >:: fun _ ->
           assert_equal "buy" Portfolio.(opt_to_string buy) );
         ( "String to option" >:: fun _ ->
           assert_equal sell Portfolio.(opt_of_string "sell") );
         ( "String to option: raise error" >:: fun _ ->
           assert_raises (Invalid_argument "Option should only be buy/sell")
             (fun () -> Portfolio.opt_of_string "invalid_option") );
         (* Testing update functions *)
         ( "Update balance" >:: fun _ ->
           assert_equal 50.
             Portfolio.(
               p |> update_balance 100. |> update_balance (-50.) |> get_balance)
         );
         ( "Update balance: insufficient balance" >:: fun _ ->
           assert_raises (Portfolio.Out_of_balance "Out of balance. ")
             (fun () -> Portfolio.(p |> update_balance (-100.0))) );
         ( "Update stock_holdings" >:: fun _ ->
           assert_equal 100.
             Portfolio.(
               p |> update_stock_holding 200.
               |> update_stock_holding (-100.)
               |> get_stock_holdings) );
         ( "Update history" >:: fun _ ->
           assert_equal h2
             Portfolio.(
               p |> update_history h1 |> update_history h2 |> get_history
               |> List.hd) );
         ( "Add bank account" >:: fun _ ->
           assert_equal 123
             Portfolio.(
               p |> add_bank_account 123 |> get_bank_accounts |> List.hd) );
         ( "Update bought_stocks" >:: fun _ ->
           assert_equal
             [ ("A", 17.); ("AAPL", 25.3); ("B", 21.2); ("TSLA", 62.7) ]
             Portfolio.(
               p1 |> update_bought_stocks "B" 21.2 |> get_bought_stocks) );
         ( "Update bought_stocks: raise error" >:: fun _ ->
           assert_raises
             (Invalid_argument "New quantity cannot be less than 0.") (fun () ->
               Portfolio.(update_bought_stocks "AAPL" (-50.) p1)) );
         (* Testing transaction *)
         ( "Transaction: empty input" >:: fun _ ->
           assert_raises (Invalid_argument "Arguments should not be empty.")
             (fun () -> Portfolio.(ticker_transact "" "A" "12.6") p) );
         ( "Transaction: out of stock holding" >:: fun _ ->
           assert_raises
             (Invalid_argument "New quantity cannot be less than 0.") (fun () ->
               Portfolio.(ticker_transact "sell" "A" "99999999") p) );
         ( "Transaction: out of balance" >:: fun _ ->
           assert_raises (Portfolio.Out_of_balance "Out of balance. ")
             (fun () -> Portfolio.(ticker_transact "buy" "A" "999999.9") p) );
       ]

let _ = run_test_tt_main portfolio_tests
