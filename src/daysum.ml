open Date

(** DaySum is a module that contains the values from parsing a file
    [data/stock/ticker/ticker_cur.csv]. Contains a loader, to_string, and
    getters for all relevant values. *)

module type DaySumType = sig
  type t
  (** Representation type *)

  exception MalformedFile

  val load_from : string -> t
  (** [load_from file_addr] processes a file_addr into a day summary value.
      Requires the file to exist. Raises [MalformedFile] is file is in the
      incorrect format. *)

  val ticker : t -> string
  (** [ticker ds] returns the ticker val associated with [ds]. *)

  val timestamp : t -> date * time
  (** [timestamp ds] returns the timestamp and retrieval time of [ds] data. *)

  val targ_est_1y : t -> float
  (** [targ_est_1y ds] returns Yahoo Finance's 1 year price estimate of the
      stock associated with [ds]. *)

  val week_range_52w : t -> float * float
  (** [week_range_52w ds] returns price range [(min, max)] over last 52 weeks of
      the stock associated with [ds]. *)

  val ask : t -> float * int
  (** [ask ds] returns the ask [(price, quantity)] where [price] is the lowest a
      stockholder is willing to sell this stock at a particular [quantity]. *)

  val avg_day_vol : t -> int
  (** [avg_day_vol] returns the average day volume of the stock associated with
      [ds]. *)

  val beta_5y_mly : t -> float
  (** [beta_5y_mly ds] returns the beta (5y monthly) of the stock associated
      with [ds]. *)

  val bid : t -> float * int
  (** [bid ds] returns the bid [(price, quantity)] where [price] is the highest
      a stockholder is willing to buy this stock at a particular [quantity]. *)

  val day_range : t -> float * float
  (** [day_range ds] returns the price range of this stock, over today
      [(min, max)]. *)

  val eps_ttm : t -> float
  (** [eps_ttm ds] returns the Trailing Twelve Month earnings per share for this
      stock. *)

  val earnings_date : t -> date * date
  (** [earning_date] returns the earnings date [(start, end)] of this stock. *)

  val ex_date : t -> date
  (** [ex_date ds] returns the ex-dividend date for the stock of this stock. *)

  val forward_div_yield : t -> float * float
  (** [forward_div_yield] returns the forward dividend and yield percentage in
      format [(dividend_price, yield)], where yield is in percentage. *)

  val market_cap : t -> float
  (** [market_cap ds] returns market cap of the stock. *)

  val open_price : t -> float
  (** [open_price ds] returns the open_price of this stock at time of retrieval. *)

  val pe_ratio_ttm : t -> float
  (** [pe_ratio_ttm ds] returns the trailing twelve month PE ratio of the stock. *)

  val prev_close : t -> float
  (** [prev_close ds] returns the most recent closing price of this stock at
      time of retrieval. *)

  val quote_price : t -> float
  (** [quote_price ds] returns the quote price; the most recent price which the
      stock as been traded. *)

  val volume : t -> int
  (** [volume ds] returns current day trade volume. *)

  val to_string : t -> string
  (** [to_string ds] returns a string format of the data. *)
end
(* end of DaySumType *)

module DaySum : DaySumType = struct
  (* TODO: Change fields all to optionals to account for possibility of N/A
     fields. Known N/A fields are [bid], [ask], [PE_ratio], [forward div],
     [ex-dividend date], [1y target est]. Perhaps we reject a file if it's
     missing any of: open, close, day range, week range, volume, avg volume,
     earnings. *)

  type t = {
    tkr : string;
    timestamp : date * time;
    targ_est_1y : float;
    week_range_52w : float * float;
    ask : float * int;
    avg_day_vol : int;
    beta_5y_mly : float;
    bid : float * int;
    day_range : float * float;
    eps_ttm : float;
    earnings_date : date * date;
    ex_date : date;
    forward_div_yield : float * float;
    market_cap : float;
    open_price : float;
    pe_ratio_ttm : float;
    prev_close : float;
    quote_price : float;
    volume : int;
  }

  exception MalformedFile

  (** Grab the value, ignore label. *)
  let get_val ic =
    let str = input_line ic in
    try
      match String.split_on_char ',' str with
      | _ :: t ->
          let return_val =
            List.fold_left
              (fun acc elt -> if acc <> "" then acc ^ "," ^ elt else acc ^ elt)
              "" t
          in
          return_val
      | _ -> raise MalformedFile
    with e -> raise MalformedFile

  let get_val_float ic = get_val ic |> float_of_string

  (** Split input string to a range pair, given a regex*)
  let splitify reg str =
    let r = Str.regexp reg in
    let lst = Str.split r str in
    (List.hd lst, List.nth lst 1)

  let read_string_date str =
    match Str.(split (regexp {|[, "]+|}) str) with
    | [ m; d; y ] ->
        let mm =
          match m with
          | "Jan" -> 1
          | "Feb" -> 2
          | "Mar" -> 3
          | "Apr" -> 4
          | "May" -> 5
          | "Jun" -> 6
          | "Jul" -> 7
          | "Aug" -> 8
          | "Sep" -> 9
          | "Oct" -> 10
          | "Nov" -> 11
          | _ -> 12
        in
        (mm, int_of_string d, int_of_string y)
    | _ -> raise Date.InvalidDate

  let read_mc str =
    match Str.(split (regexp "[MBT]") str) with
    | amt :: _ ->
        let mult =
          match Str.last_chars str 1 with
          | "M" -> 1_000_000.0
          | "B" -> 1_000_000_000.0
          | "T" -> 1_000_000_000_000.0
          | _ -> 1.0
        in
        float_of_string amt *. mult
    | _ -> raise MalformedFile

  (** [load_from file_addr] processes a file_addr into a day summary value.
      Requires the file to exist. Raises [MalformedFile] is file is in the
      incorrect format. *)
  let load_from file_addr =
    try
      let ic = open_in file_addr in
      let tkr =
        begin
          try List.nth Str.(split (regexp {|/|}) file_addr) 2
          with e -> raise MalformedFile
        end
      in
      (* ignore CSV labels *)
      let _ = input_line ic in
      (* read time*)
      let temp = splitify {|[, "]+|} (get_val ic) in
      let timestamp =
        (fst temp |> Date.of_string, snd temp |> Date.t_of_string)
      in
      let targ_est_1y = get_val_float ic in
      let temp = splitify " - " (get_val ic) in
      let week_range_52w =
        (fst temp |> float_of_string, snd temp |> float_of_string)
      in
      let temp = splitify " x " (get_val ic) in
      let ask = (fst temp |> float_of_string, snd temp |> int_of_string) in
      let avg_day_vol = get_val_float ic |> int_of_float in
      let beta_5y_mly = get_val_float ic in
      let temp = splitify " x " (get_val ic) in
      let bid = (fst temp |> float_of_string, snd temp |> int_of_string) in
      let temp = splitify " - " (get_val ic) in
      let day_range =
        (fst temp |> float_of_string, snd temp |> float_of_string)
      in
      let eps_ttm = get_val_float ic in
      let temp = splitify {|\( - \)\|"|} (get_val ic) in
      let earnings_date =
        (fst temp |> read_string_date, snd temp |> read_string_date)
      in
      let temp = Str.(split (regexp {|"|}) (get_val ic)) |> List.hd in
      let ex_date = temp |> read_string_date in
      let temp = splitify "[ (%)]+" (get_val ic) in
      let forward_div_yield =
        (fst temp |> float_of_string, snd temp |> float_of_string)
      in
      let market_cap = get_val ic |> read_mc in
      let open_price = get_val_float ic in
      let pe_ratio_ttm = get_val_float ic in
      let prev_close = get_val_float ic in
      let quote_price = get_val_float ic in
      let volume = get_val_float ic |> int_of_float in
      {
        tkr;
        timestamp;
        targ_est_1y;
        week_range_52w;
        ask;
        avg_day_vol;
        beta_5y_mly;
        bid;
        day_range;
        eps_ttm;
        earnings_date;
        ex_date;
        forward_div_yield;
        market_cap;
        open_price;
        pe_ratio_ttm;
        prev_close;
        quote_price;
        volume;
      }
    with e -> raise e

  (** [ticker ds] returns the ticker val associated with [ds]. *)
  let ticker ds = ds.tkr

  (** [timestamp ds] returns the timestamp and retrieval time of [ds] data. *)
  let timestamp ds = ds.timestamp

  (** [targ_est_1y ds] returns Yahoo Finance's 1 year price estimate of the
      stock associated with [ds]. *)
  let targ_est_1y ds = ds.targ_est_1y

  (** [week_range_52w ds] returns price range [(min, max)] over last 52 weeks of
      the stock associated with [ds]. *)
  let week_range_52w ds = ds.week_range_52w

  (** [ask ds] returns the ask [(price, quantity)] where [price] is the lowest a
      stockholder is willing to sell this stock at a particular [quantity]. *)
  let ask ds = ds.ask

  (** [avg_day_vol] returns the average day volume of the stock associated with
      [ds]. *)
  let avg_day_vol ds = ds.avg_day_vol

  (** [beta_5y_mly ds] returns the beta (5y monthly) of the stock associated
      with [ds]. *)
  let beta_5y_mly ds = ds.beta_5y_mly

  (** [bid ds] returns the bid [(price, quantity)] where [price] is the highest
      a stockholder is willing to buy this stock at a particular [quantity]. *)
  let bid ds = ds.bid

  (** [day_range ds] returns the price range of this stock, over today
      [(min, max)]. *)
  let day_range ds = ds.day_range

  (** [eps_ttm ds] returns the Trailing Twelve Month earnings per share for this
      stock. *)
  let eps_ttm ds = ds.eps_ttm

  (** [earning_date] returns the earnings date [(start, end)] of this stock. *)
  let earnings_date ds = ds.earnings_date

  (** [ex_date ds] returns the ex-dividend date for the stock of this stock. *)
  let ex_date ds = ds.ex_date

  (** [forward_div_yield] returns the forward dividend and yield percentage in
      format [(dividend_price, yield)], where yield is in percentage. *)
  let forward_div_yield ds = ds.forward_div_yield

  (** [market_cap ds] returns market cap of the stock. *)
  let market_cap ds = ds.market_cap

  (** [open_price ds] returns the open_price of this stock at time of retrieval. *)
  let open_price ds = ds.open_price

  (** [pe_ratio_ttm ds] returns the trailing twelve month PE ratio of the stock. *)
  let pe_ratio_ttm ds = ds.pe_ratio_ttm

  (** [prev_close ds] returns the most recent closing price of this stock at
      time of retrieval. *)
  let prev_close ds = ds.prev_close

  (** [quote_price ds] returns the quote price; the most recent price which the
      stock as been traded. *)
  let quote_price ds = ds.quote_price

  (** [volume ds] returns current day trade volume. *)
  let volume ds = ds.volume

  (** [to_string ds] returns a string format of the data. *)
  let to_string ds =
    match ds with
    | {
     tkr;
     timestamp;
     targ_est_1y;
     week_range_52w;
     ask;
     avg_day_vol;
     beta_5y_mly;
     bid;
     day_range;
     eps_ttm;
     earnings_date;
     ex_date;
     forward_div_yield;
     market_cap;
     open_price;
     pe_ratio_ttm;
     prev_close;
     quote_price;
     volume;
    } ->
        Printf.sprintf
          "%s (retrieved %s, %s) - \n\
          \        \n\
           \tPrevious Close:\t\t%.02f\n\
          \        \n\
           \tOpen:\t\t\t%.02f\n\
          \        \n\
           \tQuote Price:\t\t%#f\n\
          \        \n\
           \tBid:\t\t\t%.02f x %i\n\
          \        \n\
           \tAsk:\t\t\t%.02f x %i\n\
          \        \n\
           \tDay's Range:\t\t%.02f - %.02f\n\
          \        \n\
           \t52 Week Range:\t\t%.02f - %.02f\n\
          \        \n\
           \tVolume:\t\t\t%#i\n\
          \        \n\
           \tAvg. Volume:\t\t%#i\n\
          \        \n\
           \tMarket Cap:\t\t%#.02f\n\
          \        \n\
           \tBeta (5Y Monthly):\t%.02f\n\
          \        \n\
           \tPE Ratio (TTM):\t\t%.02f\n\
          \        \n\
           \tEPS (TTM):\t\t%.02f\n\
          \        \n\
           \tEarnings Date:\t\t%s - %s\n\
          \        \n\
           \tForward Div & Yield:\t%.02f (%.02f%%)\n\
          \        \n\
           \tEx-Dividend Date:\t%s\n\
          \        \n\
           \t1Y Target Estimate:\t%.02f\n\
          \        " tkr
          (fst timestamp |> Date.to_string)
          (snd timestamp |> Date.t_to_string)
          prev_close open_price quote_price (fst bid) (snd bid) (fst ask)
          (snd ask) (fst day_range) (snd day_range) (fst week_range_52w)
          (snd week_range_52w) volume avg_day_vol market_cap beta_5y_mly
          pe_ratio_ttm eps_ttm
          (fst earnings_date |> Date.to_string)
          (snd earnings_date |> Date.to_string)
          (fst forward_div_yield) (snd forward_div_yield)
          (ex_date |> Date.to_string)
          targ_est_1y
        |> String.map (function
             | '_' -> ','
             | char -> char)
end
