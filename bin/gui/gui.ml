(*To test GUI, run [make gui] in terminal*)
open Bogue
open Stockhome
open Stock
open Portfolio
open Date
open Parser
open Savewrite
module W = Widget
module L = Layout

(** Issue thread -
    - #1) Calling savewrite every action is lazy... leads to long load times
    - #1.a) Can resolve perhaps by storing the port state, and only saving on
      close. *)

let main () =
  let oldport = SaveWrite.load () in
  let port = Portfolio.update_stocks oldport in

  (* create label widgets for heading *)
  let title_label = W.label ~size:30 "OCAML STOCKS" in

  let date_label = W.label ~size:30 "Date Time" in

  let _ =
    let now = Unix.time () |> Unix.localtime in
    let date, time =
      ( (now.tm_mon + 1, now.tm_mday, now.tm_year + 1900),
        (now.tm_hour, now.tm_min, now.tm_sec) )
    in
    W.set_text date_label
      (Printf.sprintf "%s %s" (Date.to_string date) (Date.t_to_string time))
  in

  let prompt_message = W.label "Input Ticker Below" in
  let prompt = L.flat ~name:"Prompt" [ L.resident prompt_message ] in

  (*fix*)
  let portfolio_lst_label = W.label "My Portfolio:" in
  let followed_stocks_label =
    W.text_display ~w:250 ~h:75 (Portfolio.to_string port)
  in
  let stock_details =
    W.text_display ~w:250 ~h:75 (Portfolio.stock_detail port)
  in
  let portfolio_stocks = W.label "" in

  (* create main containers *)
  let heading_container =
    L.tower ~name:"heading container"
      [ L.resident title_label; L.resident date_label ]
  in
  let second_tier_container =
    L.flat ~name:"second tier container"
      [ L.resident portfolio_lst_label; L.resident followed_stocks_label ]
  in

  let text_input = W.text_input ~text:"" ~prompt:"Enter Company Ticker" () in

  (*Add button for new stocks, adds to portfolio*)
  let button_add = W.button ~border_radius:10 "Add" in
  let click _ =
    let text = String.uppercase_ascii (W.get_text text_input |> String.trim) in
    let output =
      try
        let port_from_file = SaveWrite.load () in
        let port_updated, stock = Portfolio.follow text port_from_file in
        SaveWrite.save port_updated;
        W.set_text followed_stocks_label (Portfolio.to_string port_updated);
        W.set_text stock_details (Portfolio.stock_detail port_updated);
        Stock.to_string stock
      with e -> "Invalid Ticker / Error Parsing"
    in
    W.set_text portfolio_stocks output
  in
  W.on_click ~click button_add;

  (*Button that clears the portfolio*)
  let button_clear = W.button ~border_radius:10 "Clear" in
  let click _ =
    SaveWrite.clear ();
    let port = SaveWrite.load () in
    W.set_text followed_stocks_label (Portfolio.to_string port);
    W.set_text stock_details (Portfolio.stock_detail port)
  in
  W.on_click ~click button_clear;

  (*Row of buttons*)
  let buttons =
    L.flat ~name:"button row"
      [ L.resident ~w:100 button_add; L.resident ~w:100 button_clear ]
  in

  let portfolio_container =
    L.tower ~name:"portfolio container"
      [
        prompt;
        L.resident ~w:400 text_input;
        buttons;
        L.resident ~w:400 portfolio_stocks;
      ]
  in

  let main_container =
    L.tower ~name:"main_container"
      [ heading_container; second_tier_container; portfolio_container ]
  in

  let stock_list =
    L.tower ~name:"stock_list" [ L.resident ~w:400 stock_details ]
  in

  let tabs =
    Tabs.create ~slide:Avar.Right ~name:"StockHome"
      [ ("Add Stocks", main_container); ("Stock List", stock_list) ]
  in

  let board = Bogue.make [] [ tabs ] in
  Bogue.run board

let () =
  main ();
  Bogue.quit ()
