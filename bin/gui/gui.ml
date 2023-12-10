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

let port = ref (SaveWrite.load ()) (* Global Portfolio State. *)

(* ---------------------- START OF FOLLOW_LIST DISPLAY ---------------------- *)

let obs_stk_tkr = Var.create "_EMPTY"
let stock_info = W.text_display "Hey, something went wrong!"

(** Updates all the stocks. *)
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
  let no_followed_stocks_message =
    W.label ~size:20 "YOU AREN'T FOLLOWING ANY STOCKS!"
  in
  let tower =
    if Portfolio.isempty !port then L.resident ~h:400 no_followed_stocks_message
    else L.tower_of_w widgets
  in
  L.set_rooms layout [ tower |> L.make_clip ~h:400 ];
  Sync.push (fun () -> L.fix_content layout);
  List.iter2 (create_stk_listener layout) widgets stock_list

(* ----------------------- END OF FOLLOW_LIST DISPLAY ----------------------- *)

(* ------------------------- WINDOW INITIALIZATIONS ------------------------- *)

let _ =
  L.hide_window stock_detail_l;

  Sync.push (fun () -> Window.set_size ~w:350 ~h:500 stock_window)

(* ---------------------------------- MAIN ---------------------------------- *)

let main () =
  (* ------------------------ START OF WATCHLIST TAB ------------------------ *)
  let follow_heading_container =
    let follow_title =
      let content = W.label ~align:Center ~size:40 "Watchlist" in
      L.resident ~h:100 ~w:550 content
    in
    let follow_desc =
      let content =
        W.text_display ~w:550 ~h:125
          "This is your Watchlist tab. You can scroll through all the stocks \
           that you are actively following/watching. This naturally includes \
           the stocks that you have traded as well. If you wish for more \
           detailed information, simply click on an entry in the list below, \
           and there should be a window popup with a detailed Summary, if \
           available."
      in
      L.resident ~h:130 ~w:550 content
    in
    L.tower ~name:"watchlist container" ~align:Draw.Center
      [ follow_title; follow_desc ]
  in

  let followed_stocks =
    L.empty ~w:550 ~h:400 ~name:"followed_stocks" () |> L.make_clip ~h:400
  in
  update_followed_stocks followed_stocks;

  let watchlist =
    L.tower ~sep:0 ~align:Min ~name:"watchlist"
      [ follow_heading_container; followed_stocks ]
  in

  (* ------------------------- END OF WATCHLIST TAB ------------------------- *)

  (* -------------------------- START OF TRADE TAB -------------------------- *)
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

  let portfolio_stocks = W.label ~size:20 ~align:Center "" in

  (* Output message label. *)
  let trade_output_message = W.label ~size:20 "" in

  let add_stock_input =
    W.text_input ~size:20 ~text:"" ~prompt:"Enter Stock Ticker (ex. AAPL)" ()
  in

  (* Prompt and input boxes for the trade tab. *)
  let trade_opt_message = W.label ~size:20 "Input Option Below: Buy / Sell" in
  let trade_opt_input =
    W.text_input ~size:20 ~text:"" ~prompt:"Buy / Sell" ()
  in
  let trade_ticker_message = W.label ~size:20 "Input Ticker Below" in
  let trade_ticker_input =
    W.text_input ~size:20 ~text:"" ~prompt:"Enter Ticker" ()
  in
  let trade_amt_message = W.label ~size:20 "Input Quantity Below" in
  let trade_amt_input =
    W.text_input ~size:20 ~text:"" ~prompt:"Enter Quantity" ()
  in

  (* Button that trades stocks. *)
  let button_trade =
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
        | Invalid_argument m -> m
        | Portfolio.Out_of_balance m -> m
        | Stock.UnretrievableStock m -> m
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
    W.button ~action:click ~fg:(255, 255, 255, 0) ~border_radius:10 "Trade"
  in

  (* Deposit money button. *)
  let button_deposit =
    let click _ =
      port := Portfolio.update_balance 100. !port;
      W.set_text balance_label
        (Printf.sprintf "Balance: $%.2f" (Portfolio.get_balance !port))
    in
    W.button ~action:click ~border_radius:10 ~fg:(255, 255, 255, 0)
      "Deposit $100"
  in

  let trade_labels =
    L.tower ~name:"trade labels" ~align:Min
      [
        L.resident ~w:500 balance_label;
        L.resident ~w:500 total_holding_label;
        L.resident ~w:500 ~h:100 each_holding_label;
      ]
  in
  let trade_menu =
    L.tower ~name:"trade menu" ~align:Min
      [
        L.resident trade_opt_message;
        L.resident ~h:50 trade_opt_input;
        L.resident trade_ticker_message;
        L.resident ~h:50 trade_ticker_input;
        L.resident trade_amt_message;
        L.resident ~h:50 trade_amt_input;
        L.flat ~name:"trade button row"
          [
            L.resident ~h:40 ~w:150 button_trade;
            L.resident ~h:40 ~w:150 button_deposit;
          ];
      ]
  in
  (* The trade tab. *)
  let trade_stocks =
    L.tower ~name:"followed_stocks" ~align:Min
      [ trade_labels; trade_menu; L.resident ~w:550 trade_output_message ]
  in

  (* --------------------------- END OF TRADE TAB --------------------------- *)

  (* -------------------------- START OF MAIN TAB -------------------------- *)
  let heading_container =
    let title_label = W.label ~align:Center ~size:40 "STOCKHOME" in

    let date_label =
      let now = Unix.time () |> Unix.localtime in
      let date, time =
        ( (now.tm_mon + 1, now.tm_mday, now.tm_year + 1900),
          (now.tm_hour, now.tm_min, now.tm_sec) )
      in
      W.label ~align:Center ~size:25 (Printf.sprintf "%s" (Date.to_string date))
    in

    let instruct =
      W.text_display ~h:200
        "Welcome to STOCKHOME! Here, you can follow any stock, which adds it \
         to your watchlist, which can be viewed in the [Followed Stocks] tab. \
         The clear button clears all information in your portfolio, and the \
         update buttons updates all stocks in your watchlist with current \
         data.\n\n\
         In the [Followed Stocks] tab, you can click on any stock to view more \
         details about that stock.\n\n\
         In the [Trade Stocks] tab, you can simulate a trading enviroment \
         where you can buy/sell stocks in relation to their current time data. \
         Finally, feel free to come back anytime, as the application saves all \
         information stored in your portfolio."
    in

    L.tower ~name:"heading container" ~hmargin:30 ~align:Draw.Center
      [
        L.resident ~h:50 ~w:300 title_label;
        L.resident ~h:50 ~w:150 date_label;
        L.resident ~h:200 ~w:500 instruct;
      ]
  in
  let prompt_message = W.label ~size:20 "Input Ticker Below" in
  let prompt = L.flat ~name:"Prompt" [ L.resident ~h:40 prompt_message ] in

  (* Follows a stock ticker. *)
  let button_add =
    let add_stock _ =
      let text =
        String.uppercase_ascii (W.get_text add_stock_input |> String.trim)
      in
      let output =
        try
          let port_updated, stock = Portfolio.follow text !port in
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
  (* Update all stocks in follow list. *)
  let button_update =
    let update_stocks _ =
      port := Portfolio.update_stocks !port |> fst;
      update_followed_stocks followed_stocks
    in
    W.button ~fg:(255, 255, 255, 0) ~border_radius:10 ~action:update_stocks
      "Update All"
  in
  (* Empties out portfolio. *)
  let button_clear =
    let clear_following _ =
      SaveWrite.clear ();
      port := Portfolio.new_portfolio ();
      update_followed_stocks followed_stocks;
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
  let main_container_buttons =
    L.flat ~align:Center ~name:"button row"
      [
        L.resident ~h:40 ~w:125 button_add;
        L.resident ~h:40 ~w:125 button_update;
        L.resident ~h:40 ~w:125 button_clear;
      ]
  in
  let portfolio_container =
    L.tower ~name:"portfolio container" ~hmargin:30 ~align:Center
      [
        prompt;
        L.resident ~h:40 add_stock_input;
        main_container_buttons;
        L.resident ~h:90 ~w:550 portfolio_stocks;
      ]
  in
  let main_container =
    L.tower ~sep:0 ~align:Center ~name:"main_container"
      [ heading_container; portfolio_container ]
  in

  (* --------------------------- END OF MAIN TAB --------------------------- *)
  let tabs =
    Tabs.create ~slide:Avar.Right ~name:"StockHome"
      [
        ("Add Stocks", main_container);
        ("Watchlist", watchlist);
        ("Trade Stocks", trade_stocks);
      ]
  in

  let main_window =
    let end_pgrm w =
      Window.destroy stock_window;
      Window.destroy w
    in
    Window.create ?on_close:(Some end_pgrm) tabs
  in

  let board = Main.create [ main_window; stock_window ] in
  Bogue.run board

let () =
  main ();
  SaveWrite.save !port;
  Bogue.quit ()
