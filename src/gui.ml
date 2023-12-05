open Bogue
open Stock
open Portfolio
open Date
module W = Widget
module L = Layout

let main () =
  (* create a sample stock and display it *)
  let data =
    Stock.of_input "AAPL" "APPLE" 123.45 (Date.of_string "12-01-2023") 1.0 10
  in
  let stock_string = Stock.to_string data in

  (* create label widgets for heading *)
  let title_label = W.label "OCAML STOCKS" in
  let date_label = W.label "November 21, 2023" in
  let watch_lst_label = W.label "Watch List" in
  let portfolio_lst_label = W.label "My Portfolio" in
  let sample_stock_label = W.label stock_string in
  let portfolio_stocks = W.label "Portfolio Stocks" in

  (* create main containers *)
  let heading_container =
    L.flat_of_w ~name:"heading container" [ title_label; date_label ]
  in
  let second_tier_container =
    L.flat_of_w ~name:"second tier container"
      [ watch_lst_label; portfolio_lst_label ]
  in
  let watch_list_container =
    L.tower_of_w ~name:"watch list container" [ sample_stock_label ]
  in

  let main_container =
    L.tower ~name:"main_container" [ heading_container; second_tier_container ]
  in

  let board = Bogue.of_layout main_container in
  Bogue.run board

let () =
  main ();
  Bogue.quit ()
