(*To test GUI, run [make gui] in terminal*)
open Bogue
open Stockhome
open Stock
open Portfolio
open Date
open Savewrite
open Daysum
module W = Widget
module L = Layout

(** Issue thread -
    - #1) Calling savewrite every action is lazy... [EDIT: RESOLVED - rw]
    - #2) Heavy front loading is annoying...

    -------- Use promises to not stall everything
    - #3) Front loads twice because of updating [EDIT: SEMI-RESOLVED - rw]...

    -------- Perhaps fill with placeholders, only update when necessary
    - #4) Barebone interface
    - #5) Detailed summary doesn't fit completely on gui space... make dynamic!
    - #6) Stock_list displays in reverse order
    - #7) Stock_list doesn't update
    - #n) *)

let port = ref (SaveWrite.load ())

(** Return list of List.t for followed stocks. Enables toggle between different
    display details. *)
let clickable_stock_list () =
  let following = Portfolio.get_followed_stocks !port in
  let rec stock_to_resident stk =
    let show_simple = Var.create true in
    let detail_view = Stock.to_string_detailed stk in
    let toggle this =
      let view_ =
        print_endline (W.get_text this);
        if Var.get show_simple then begin
          Var.set show_simple false;
          match Stock.cur_data stk with
          | None -> "Detailed Summary Unavailable"
          | Some s -> DaySum.to_string s
        end
        else begin
          Var.set show_simple true;
          detail_view
        end
      in
      W.set_text this view_
    in
    let txt = W.text_display ~h:325 detail_view in
    W.on_click ~click:toggle txt;
    L.resident ~name:(Stock.ticker stk) txt
    |> L.make_clip ~h:75 ~scrollbar:false
  in
  List.rev (List.map stock_to_resident following)

(** Button that updates all stocks in the follow_list of given portfolio. *)
let button_update pf =
  let button = W.button ~border_radius:10 ~fg:(255, 255, 255, 0) "Update" in
  let click _ = port := Portfolio.update_stocks !port |> fst in
  W.on_click ~click button;
  button

(** Button that adds $100 to the balance everytime it is pressed. *)
let button_deposit =
  let button =
    W.button ~border_radius:10 ~fg:(255, 255, 255, 0) "Deposit $100"
  in
  let click _ = port := Portfolio.update_balance 100. !port in
  W.on_click ~click button;
  button

let main () =
  (* create label widgets for heading *)
  let title_label = W.label ~size:30 "OCAML STOCKS" in

  let date_label = W.label ~size:30 "Date Time" in

  let _ =
    let now = Unix.time () |> Unix.localtime in
    let date, time =
      ( (now.tm_mon + 1, now.tm_mday, now.tm_year + 1900),
        (now.tm_hour, now.tm_min, now.tm_sec) )
    in
    W.set_text date_label (Printf.sprintf "%s" (Date.to_string date))
  in

  let prompt_message = W.label "Input Ticker Below" in
  let prompt = L.flat ~name:"Prompt" [ L.resident prompt_message ] in

  (* Prompt for the trade tab. *)
  let holdings_label =
    W.text_display
      ("Balance: "
      ^ string_of_float (Portfolio.get_balance !port)
      ^ "\n" ^ "Stock Holdings: "
      ^ string_of_float (Portfolio.get_stock_holdings !port))
  in

  let trade_opt_message = W.label "Input Option Below: buy/sell" in
  let trade_ticker_message = W.label "Input Ticker Below" in
  let trade_amt_message = W.label "Input Quantity Below" in

  (*fix*)
  let portfolio_lst_label = W.label "My Portfolio:" in
  let followed_stocks_label =
    W.text_display ~w:250 ~h:75 (Portfolio.to_string !port)
  in
  let stock_details =
    W.text_display ~w:250 ~h:75 (Portfolio.stock_detail !port)
  in
  let portfolio_stocks = W.label "" in

  (* create main containers *)
  let heading_container =
    L.flat ~name:"heading container" ~hmargin:30 ~align:Draw.Center
      [ L.resident title_label; L.resident date_label ]
  in
  let second_tier_container =
    L.flat ~name:"second tier container"
      [ L.resident portfolio_lst_label; L.resident followed_stocks_label ]
  in

  let text_input = W.text_input ~text:"" ~prompt:"Enter Stock Ticker" () in

  (* Text input for trade tab. *)
  let trade_opt_input = W.text_input ~text:"" ~prompt:"Enter Option Type" () in
  let trade_ticker_input = W.text_input ~text:"" ~prompt:"Enter Ticker" () in
  let trade_amt_input = W.text_input ~text:"" ~prompt:"Enter Quantity" () in

  (*Add button for new stocks, adds to portfolio*)
  let button_add = W.button ~border_radius:10 ~fg:(255, 255, 255, 0) "Add" in
  let click _ =
    let text = String.uppercase_ascii (W.get_text text_input |> String.trim) in
    let output =
      try
        (*let port_from_file = SaveWrite.load () in*)
        let port_updated, stock = Portfolio.follow text !port in
        (*SaveWrite.save port_updated;*)
        W.set_text followed_stocks_label (Portfolio.to_string port_updated);
        W.set_text stock_details (Portfolio.stock_detail port_updated);
        port := port_updated;
        Stock.to_string stock
      with e -> "Invalid Ticker / Error Parsing"
    in
    W.set_text portfolio_stocks output;
    (*W.set_text text_input "";This crashes the gui*)
    ignore (clickable_stock_list ())
  in
  W.on_click ~click button_add;

  (* Button that clears the portfolio*)
  let button_clear =
    W.button ~border_radius:10 ~fg:(255, 255, 255, 0) "Clear"
  in
  let click _ =
    SaveWrite.clear ();
    port := Portfolio.new_portfolio ();
    W.set_text followed_stocks_label (Portfolio.to_string !port);
    W.set_text stock_details (Portfolio.stock_detail !port);
    ignore (clickable_stock_list ())
  in
  W.on_click ~click button_clear;

  (* Button that trades stocks. *)
  let button_trade = W.button ~border_radius:10 "Trade" in
  let click _ =
    let text_opt =
      String.lowercase_ascii (W.get_text trade_opt_input |> String.trim)
    in
    let text_ticker =
      String.uppercase_ascii (W.get_text trade_ticker_input |> String.trim)
    in
    let text_amt = W.get_text trade_amt_input |> String.trim in
    let output =
      try
        let port_updated =
          Portfolio.ticker_transact text_opt text_ticker text_amt !port
        in
        port := port_updated;
        text_opt ^ " " ^ text_amt ^ " stocks of " ^ text_ticker
      with e -> "Invalid Input"
    in
    W.set_text portfolio_stocks output
  in
  W.on_click ~click button_trade;

  (*Row of buttons*)
  let buttons =
    L.flat ~name:"button row"
      [
        L.resident ~w:100 button_add;
        L.resident ~w:100 (button_update port);
        L.resident ~w:100 button_clear;
        L.resident ~w:100 button_deposit;
        (* L.resident ~w:100 button_trade; *)
      ]
  in

  let portfolio_container =
    L.tower ~name:"portfolio container" ~align:Draw.Center
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

  (*let stock_list = L.tower ~name:"stock_list" [ L.resident ~w:400
    stock_details ] in*)
  let followed_stocks =
    L.tower ~clip:true ~scale_content:true ~name:"followed_stocks"
      [ L.resident ~w:400 stock_details ]
  in

  (* The trade tab. *)
  let trade_stocks =
    L.tower ~name:"followed_stocks"
      [
        L.resident holdings_label;
        L.resident trade_opt_message;
        L.resident trade_opt_input;
        L.resident trade_ticker_message;
        L.resident trade_ticker_input;
        L.resident trade_amt_message;
        L.resident trade_amt_input;
        L.resident ~w:200 button_trade;
      ]
  in

  let tabs =
    Tabs.create ~slide:Avar.Right ~name:"StockHome"
      [
        ("Add Stocks", main_container);
        ("Followed Stocks", followed_stocks);
        ("Trade Stocks", trade_stocks);
      ]
  in

  let board = Bogue.make [] [ tabs ] in
  Bogue.run board

let () =
  main ();
  SaveWrite.save !port;
  Bogue.quit ()
