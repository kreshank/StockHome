(*To test GUI, run [make gui] in terminal*)
open Bogue
open Stockhome
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
  let portfolio_stocks = W.label "" in

  (* create main containers *)
  let heading_container =
    L.flat ~name:"heading container"
      [ L.resident title_label; L.resident date_label ]
  in
  let second_tier_container =
    L.flat ~name:"second tier container"
      [ L.resident watch_lst_label; L.resident portfolio_lst_label ]
  in
  let watch_list_container =
    L.tower ~name:"watch list container" [ L.resident sample_stock_label ]
  in

  let action input label _ =
    let text = W.get_text input in
    (* Leo, take the ticker from text and return a string representation of the
       stock that the ticker in [text] refers to. Just make another let
       statement that equals the string. I'm still trying to figure out how to
       make it show to the screen when the user presses enter. *)
    W.set_text label text
  in

  let text_input = W.text_input ~text:"" ~prompt:"Enter Company Ticker" () in
  let c = W.connect text_input portfolio_stocks action Trigger.[ key_up ] in

  let portfolio_container =
    L.tower ~name:"portfolio container"
      [ L.resident ~w:400 text_input; L.resident ~w:400 portfolio_stocks ]
  in

  let main_container =
    L.tower ~name:"main_container"
      [
        heading_container;
        second_tier_container;
        watch_list_container;
        portfolio_container;
      ]
  in

  let board = Bogue.make [ c ] [ main_container ] in
  Bogue.run board

let () =
  main ();
  Bogue.quit ()
