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
  let button = W.button ~border_radius:10 "Update" in
  let click _ = port := Portfolio.update_stocks !port |> fst in
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
    L.tower ~name:"heading container"
      [ L.resident title_label; L.resident date_label ]
  in
  let second_tier_container =
    L.flat ~name:"second tier container"
      [ L.resident portfolio_lst_label; L.resident followed_stocks_label ]
  in

  let text_input = W.text_input ~text:"" ~prompt:"Enter Stock Ticker" () in

  (*Add button for new stocks, adds to portfolio*)
  let button_add = W.button ~border_radius:10 "Add" in
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
    ignore (clickable_stock_list ())
  in
  W.on_click ~click button_add;

  (* Button that clears the portfolio*)
  let button_clear = W.button ~border_radius:10 "Clear" in
  let click _ =
    SaveWrite.clear ();
    port := Portfolio.new_portfolio ();
    W.set_text followed_stocks_label (Portfolio.to_string !port);
    W.set_text stock_details (Portfolio.stock_detail !port);
    ignore (clickable_stock_list ())
  in
  W.on_click ~click button_clear;

  (*Row of buttons*)
  let buttons =
    L.flat ~name:"button row"
      [
        L.resident ~w:100 button_add;
        L.resident ~w:100 (button_update port);
        L.resident ~w:100 button_clear;
      ]
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

  (*let stock_list = L.tower ~name:"stock_list" [ L.resident ~w:400
    stock_details ] in*)
  let followed_stocks =
    L.tower ~clip:true ~scale_content:true ~name:"followed_stocks"
      [ L.resident ~w:400 stock_details ]
  in

  let tabs =
    Tabs.create ~slide:Avar.Right ~name:"StockHome"
      [ ("Add Stocks", main_container); ("Followed Stocks", followed_stocks) ]
  in

  let board = Bogue.make [] [ tabs ] in
  Bogue.run board

let () =
  main ();
  SaveWrite.save !port;
  Bogue.quit ()
