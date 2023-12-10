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
    - #2) Heavy front loading is annoying... -------- Use promises to not stall
      everything
    - #3) Front loads twice because of updating [EDIT: SEMI-RESOLVED - rw]...
      -------- Perhaps fill with placeholders, only update when necessary
    - #4) Barebone interface
    - #5) Detailed summary doesn't fit [EDIT: RESOLVED - rw]
    - #6) Stock_list displays in reverse order [EDIT: RESOLVED - rw]
    - #7) Stock_list doesn't update [EDIT: RESOLVED - rw]
    - #8) Selecting which stock to inspect takes a while (hitreg or delay?)
    - #9) Follow list is not scroll able [EDIT: RESOLVED - rw]
    - #10) Main menu shrinks
    - #n) *)

let port = ref (SaveWrite.load ()) (* Global Portfolio State. *)
let obs_stk_tkr = Var.create "AAPL"
let stock_info = W.text_display "Hey, something went wrong!"

let instruct =
  W.text_display
    "Welcome to STOCKHOME! Here, you can follow any stock, which adds it to \
     your watchlist, which can be viewed in the [Followed Stocks] tab. The \
     clear button clears all information in your portfolio, and the update \
     buttons updates all stocks in your watchlist with current data.\n\n\
     In the [Followed Stocks] tab, you can click on any stock to view more \
     details about that stock.\n\n\
     In the [Trade Stocks] tab, you can simulate a trading enviroment where \
     you can buy/sell stocks in relation to their current time data. Finally, \
     feel free to come back anytime, as the application saves all information \
     stored in your portfolio."

(* ------------------- Start of Follow List Display ------------------- *)

let update_button =
  let refresh _ =
    let updated_port, stk = Portfolio.follow (Var.get obs_stk_tkr) !port in
    port := updated_port;
    let view_ =
      match Stock.cur_data stk with
      | None ->
          Stock.to_string_detailed stk ^ "\n\tThat's strange... refresh failed!"
      | Some cd -> DaySum.to_string cd
    in
    W.set_text stock_info view_
  in
  W.button ~action:refresh "Refresh?"

let stock_detail_l =
  L.tower_of_w ~w:400 ~scale_content:true [ stock_info; update_button ]

let stock_window =
  let hide (elem : L.t) = Some (fun _ -> L.hide_window elem) in
  Window.create ?on_close:(hide stock_detail_l) stock_detail_l

(** Attach click listener on [obj] and update the [layout] container which [obj]
    is housed in. *)
let rec create_stk_listener layout obj stk =
  let action src dst ev =
    let tkr = Stock.ticker stk in
    Var.set obs_stk_tkr tkr;
    ignore Trigger.var_changed;
    L.show_window stock_detail_l;
    let dsply =
      match Stock.cur_data stk with
      | None ->
          Stock.to_string stk
          ^ "\n\t... More detailed stats currently unavailable..."
      | Some s -> DaySum.to_string s
    in
    W.set_text stock_info dsply;
    update_followed_stocks layout
  in
  W.connect_main obj obj action Trigger.buttons_up |> W.add_connection obj

(** Update followed_stocks layout with an array. *)
and update_followed_stocks layout =
  (* Create list of Widgets for followed stocks. Enables toggle between
     different display details. *)
  let create_widgets stk_list =
    let make_stk_simp stk =
      let view_ = Stock.to_string_detailed stk in
      let elem = W.text_display ~w:550 ~h:75 view_ in
      elem
    in
    List.map make_stk_simp stk_list
  in
  (* Make new tower and apply. *)
  let stock_list = Portfolio.get_followed_stocks !port |> List.rev in
  let widgets = create_widgets stock_list in
  let tower = L.tower_of_w widgets in
  L.set_rooms layout [ L.make_clip ~h:200 tower ];
  Sync.push (fun () -> L.fit_content ~sep:0 layout);
  List.iter2 (create_stk_listener layout) widgets stock_list

(* ------------------- End of Follow List Display ------------------- *)

(* ------------------- Window Initializations ------------------- *)

let _ = L.hide_window stock_detail_l

(* ------------------- Main ------------------- *)

let main () =
  (* create label widgets for heading *)
  let title_label = W.label ~align:Center ~size:40 "STOCKHOME" in

  let date_label = W.label ~align:Center ~size:25 "Date Time" in

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
  let balance_label =
    W.label ~align:Min ~size:30
      (Printf.sprintf "Balance: $%.2f" (Portfolio.get_balance !port))
  in

  let total_holding_label =
    W.label ~align:Min ~size:30
      (Printf.sprintf "Total Stock Holdings: $%.2f"
         (Portfolio.get_stock_holdings !port))
  in
  let each_holding_label =
    W.text_display
      ("Holdings Per Stock: "
      ^ List.fold_left
          (fun acc (t, a) ->
            let s = Printf.sprintf "[%s - %.2f]" t a in
            if acc = "" then s else acc ^ ", " ^ s)
          ""
          (Portfolio.get_bought_stocks !port))
  in

  (* Button that adds $100 to the balance everytime it is pressed. *)
  let button_deposit =
    let button =
      W.button ~border_radius:10 ~fg:(255, 255, 255, 0) "Deposit $100"
    in
    let click _ =
      port := Portfolio.update_balance 100. !port;
      W.set_text balance_label
        (Printf.sprintf "Balance: $%.2f" (Portfolio.get_balance !port))
    in
    W.on_click ~click button;
    button
  in

  let trade_opt_message = W.label "Input Option Below: buy/sell" in
  let trade_ticker_message = W.label "Input Ticker Below" in
  let trade_amt_message = W.label "Input Quantity Below" in

  let stock_details =
    W.text_display ~w:400 ~h:75 (Portfolio.stock_detail !port)
  in
  let portfolio_stocks = W.label ~align:Min "" in

  (* trade tab message*)
  let trade_output_message = W.label "" in

  (* create main containers *)
  let heading_container =
    L.tower ~name:"heading container" ~hmargin:30 ~align:Draw.Center
      [
        L.resident ~h:50 ~w:300 title_label;
        L.resident ~h:50 ~w:150 date_label;
        L.resident ~h:200 ~w:500 instruct;
      ]
  in

  let text_input = W.text_input ~text:"" ~prompt:"Enter Stock Ticker" () in

  let followed_stocks =
    L.empty ~w:150 ~h:400 ~name:"followed_stocks" () |> L.make_clip ~h:200
  in
  update_followed_stocks followed_stocks;

  (* Text input for trade tab. *)
  let trade_opt_input = W.text_input ~text:"" ~prompt:"Enter Option Type" () in
  let trade_ticker_input = W.text_input ~text:"" ~prompt:"Enter Ticker" () in
  let trade_amt_input = W.text_input ~text:"" ~prompt:"Enter Quantity" () in

  (*Add button for new stocks, adds to portfolio*)
  let button_add =
    let add_stock _ =
      let text =
        String.uppercase_ascii (W.get_text text_input |> String.trim)
      in
      let output =
        try
          (*let port_from_file = SaveWrite.load () in*)
          let port_updated, stock = Portfolio.follow text !port in
          (*SaveWrite.save port_updated;*)
          W.set_text stock_details (Portfolio.stock_detail port_updated);
          port := port_updated;
          update_followed_stocks followed_stocks;
          Stock.to_string stock
        with
        | DaySum.MalformedFile -> "Something went wrong with parsing!"
        | Stock.UnretrievableStock s -> s
        | e -> "Unexpected error... Did not add."
      in
      W.set_text portfolio_stocks output
    in
    W.button ~border_radius:10 ~fg:(255, 255, 255, 0) ~action:add_stock "Follow"
  in

  (* Button that updates all stocks in the follow_list of given portfolio. *)
  let button_update =
    let button = W.button ~fg:(255, 255, 255, 0) ~border_radius:10 "Update" in
    let click _ = port := Portfolio.update_stocks !port |> fst in
    W.on_click ~click button;
    button
  in

  (* Button that clears the portfolio*)
  let button_clear =
    let clear_following _ =
      SaveWrite.clear ();
      port := Portfolio.new_portfolio ();
      update_followed_stocks followed_stocks;
      W.set_text stock_details (Portfolio.stock_detail !port);
      W.set_text balance_label
        (Printf.sprintf "Balance: $%.2f" (Portfolio.get_balance !port));

      W.set_text total_holding_label
        (Printf.sprintf "Total Stock Holdings: $%.2f"
           (Portfolio.get_stock_holdings !port));

      W.set_text each_holding_label
        ("Holdings Per Stock: "
        ^ List.fold_left
            (fun acc (t, a) ->
              let s = Printf.sprintf "[%s - %.2f]" t a in
              if acc = "" then s else acc ^ ", " ^ s)
            ""
            (Portfolio.get_bought_stocks !port));
      L.hide_window stock_detail_l
    in
    W.button ~border_radius:10 ~fg:(255, 255, 255, 0) ~action:clear_following
      "Clear"
  in

  (* Button that trades stocks. *)
  let button_trade =
    W.button ~fg:(255, 255, 255, 0) ~border_radius:10 "Trade"
  in
  let click _ =
    let output =
      try
        let text_opt =
          String.lowercase_ascii (W.get_text trade_opt_input |> String.trim)
        in
        let text_ticker =
          String.uppercase_ascii (W.get_text trade_ticker_input |> String.trim)
        in
        let text_amt = W.get_text trade_amt_input |> String.trim in
        let port_updated =
          Portfolio.ticker_transact text_opt text_ticker text_amt !port
        in
        port := port_updated;
        update_followed_stocks followed_stocks;
        match text_opt with
        | "buy" -> "Bought " ^ text_amt ^ " stock(s) of " ^ text_ticker
        | "sell" -> "Sold " ^ text_amt ^ " stock(s) of " ^ text_ticker
        | _ -> raise (Invalid_argument "Impossible")
      with
      | Portfolio.Out_of_balance m -> m
      | Invalid_argument m -> m
      | _ -> "Unknown error"
    in

    W.set_text trade_output_message output;
    W.set_text balance_label
      (Printf.sprintf "Balance: $%.2f" (Portfolio.get_balance !port));

    W.set_text total_holding_label
      (Printf.sprintf "Total Stock Holdings: $%.2f"
         (Portfolio.get_stock_holdings !port));

    W.set_text each_holding_label
      ("Holdings Per Stock: "
      ^ List.fold_left
          (fun acc (t, a) ->
            let s = Printf.sprintf "[%s - %.2f]" t a in
            if acc = "" then s else acc ^ ", " ^ s)
          ""
          (Portfolio.get_bought_stocks !port))
  in
  W.on_click ~click button_trade;

  (* Row of buttons*)
  let buttons =
    L.flat ~align:Center ~name:"button row"
      [
        L.resident ~w:100 button_add;
        L.resident ~w:100 button_update;
        L.resident ~w:100 button_clear;
      ]
  in

  let portfolio_container =
    L.tower ~name:"portfolio container" ~hmargin:30 ~align:Center
      [
        prompt;
        L.resident ~w:400 text_input;
        buttons;
        L.resident ~w:400 portfolio_stocks;
      ]
  in

  let main_container =
    L.tower ~sep:0 ~align:Center ~name:"main_container"
      [ heading_container; portfolio_container ]
  in

  let trade_labels =
    L.tower ~name:"trade labels"
      [
        L.resident ~w:500 balance_label;
        L.resident ~w:500 total_holding_label;
        L.resident ~w:500 ~h:100 each_holding_label;
      ]
  in
  let trade_menu =
    L.tower ~name:"trade menu"
      [
        L.resident trade_opt_message;
        L.resident trade_opt_input;
        L.resident trade_ticker_message;
        L.resident trade_ticker_input;
        L.resident trade_amt_message;
        L.resident trade_amt_input;
        L.flat ~name:"trade button row"
          [ L.resident ~w:100 button_trade; L.resident ~w:100 button_deposit ];
      ]
  in
  (* The trade tab. *)
  let trade_stocks =
    L.tower ~name:"followed_stocks"
      [ trade_labels; trade_menu; L.resident ~w:500 trade_output_message ]
  in

  let tabs =
    Tabs.create ~slide:Avar.Right ~name:"StockHome"
      [
        ("Add Stocks", main_container);
        ("Followed Stocks", followed_stocks);
        ("Trade Stocks", trade_stocks);
      ]
  in

  let end_pgrm w =
    Window.destroy stock_window;
    Window.destroy w
  in

  let main_window = Window.create ?on_close:(Some end_pgrm) tabs in
  Sync.push (fun () -> Window.set_size ~w:350 ~h:500 stock_window);
  let board = Main.create [ main_window; stock_window ] in
  Bogue.run board

let () =
  main ();
  SaveWrite.save !port;
  Bogue.quit ()
