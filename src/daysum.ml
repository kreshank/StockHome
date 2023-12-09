open Date

(** DaySum.ml - A module that contains the values from parsing a file
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

  val targ_est_1y : t -> float option
  (** [targ_est_1y ds] returns Yahoo Finance's 1 year price estimate of the
      stock associated with [ds]. *)

  val week_range_52w : t -> float option * float option
  (** [week_range_52w ds] returns price range [(min, max)] over last 52 weeks of
      the stock associated with [ds]. *)

  val ask : t -> float option * int option
  (** [ask ds] returns the ask [(price, quantity)] where [price] is the lowest a
      stockholder is willing to sell this stock at a particular [quantity]. *)

  val avg_day_vol : t -> int option
  (** [avg_day_vol] returns the average day volume of the stock associated with
      [ds]. *)

  val beta_5y_mly : t -> float option
  (** [beta_5y_mly ds] returns the beta (5y monthly) of the stock associated
      with [ds]. *)

  val bid : t -> float option * int option
  (** [bid ds] returns the bid [(price, quantity)] where [price] is the highest
      a stockholder is willing to buy this stock at a particular [quantity]. *)

  val day_range : t -> float option * float option
  (** [day_range ds] returns the price range of this stock, over today
      [(min, max)]. *)

  val eps_ttm : t -> float option
  (** [eps_ttm ds] returns the Trailing Twelve Month earnings per share for this
      stock. *)

  val earnings_date : t -> date option * date option
  (** [earning_date] returns the earnings date [(start, end)] of this stock. *)

  val ex_date : t -> date option
  (** [ex_date ds] returns the ex-dividend date for the stock of this stock. *)

  val forward_div_yield : t -> float option * float option
  (** [forward_div_yield] returns the forward dividend and yield percentage in
      format [(dividend_price, yield)], where yield is in percentage. *)

  val market_cap : t -> float
  (** [market_cap ds] returns market cap of the stock. *)

  val open_price : t -> float
  (** [open_price ds] returns the open_price of this stock at time of retrieval. *)

  val pe_ratio_ttm : t -> float option
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
  type t = {
    tkr : string;
    timestamp : date * time;
    targ_est_1y : float option;
    week_range_52w : float option * float option;
    ask : float option * int option;
    avg_day_vol : int option;
    beta_5y_mly : float option;
    bid : float option * int option;
    day_range : float option * float option;
    eps_ttm : float option;
    earnings_date : date option * date option;
    ex_date : date option;
    forward_div_yield : float option * float option;
    market_cap : float;
    open_price : float;
    pe_ratio_ttm : float option;
    prev_close : float;
    quote_price : float;
    volume : int;
  }

  exception MalformedFile
  exception ProcessError

  (** Grab the value, ignore label. Raises [MalformedFile] if unable to split
      for whatever reason. *)
  let get_val ?(op = true) ic =
    let str = input_line ic in
    match String.split_on_char ',' str with
    | _ :: t -> begin
        let return_val =
          List.fold_left
            (fun acc elt -> if acc <> "" then acc ^ "," ^ elt else acc ^ elt)
            "" t
        in
        return_val |> String.trim
      end
    | _ -> raise MalformedFile

  (** Tries to compute [f x], if successful, return [Some (f x)]. If fails and
      [op=true], then return [None]. Else, raise [MalformedFile]. *)
  let safe_compute ?(op = true) f x =
    try Some (f x) with e -> if op then None else raise MalformedFile

  let get_val_float_safe ?(op = true) ic =
    safe_compute ~op float_of_string (get_val ic)

  (** Split input string to a range pair, given a regex*)
  let splitify reg str =
    let r = Str.regexp reg in
    let lst = Str.split r str in
    try (List.hd lst, try List.nth lst 1 with Failure _ -> List.hd lst)
    with Failure _ -> ("N/A", "N/A")

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
          try
            List.nth Str.(split (regexp {|/|}) file_addr) 2
            |> String.uppercase_ascii
          with e -> raise MalformedFile
        end
      in
      (* ignore CSV labels *)
      let _ = input_line ic in
      (* read time*)
      let temp = splitify {|[, "]+|} (get_val ~op:false ic) in
      let timestamp =
        ( safe_compute ~op:false Date.of_string (fst temp) |> Option.get,
          safe_compute ~op:false Date.t_of_string (snd temp) |> Option.get )
      in
      let targ_est_1y = get_val_float_safe ic in
      let temp = splitify " - " (get_val ic) in
      let week_range_52w =
        ( safe_compute float_of_string (fst temp),
          safe_compute float_of_string (snd temp) )
      in
      let temp = splitify " x " (get_val ic) in
      let ask =
        ( safe_compute float_of_string (fst temp),
          safe_compute int_of_string (snd temp) )
      in
      let avg_day_vol =
        safe_compute int_of_float (get_val_float_safe ic |> Option.get)
      in
      let beta_5y_mly = get_val_float_safe ic in
      let temp = splitify " x " (get_val ic) in
      let bid =
        ( safe_compute float_of_string (fst temp),
          safe_compute int_of_string (snd temp) )
      in
      let temp = splitify " - " (get_val ic) in
      let day_range =
        ( safe_compute float_of_string (fst temp),
          safe_compute float_of_string (snd temp) )
      in
      let eps_ttm = get_val_float_safe ic in
      let temp = splitify {|\( - \)\|"|} (get_val ic) in
      let earnings_date =
        ( safe_compute read_string_date (fst temp),
          safe_compute read_string_date (snd temp) )
      in
      let temp = safe_compute List.hd Str.(split (regexp {|"|}) (get_val ic)) in
      let ex_date =
        match temp with
        | None -> None
        | Some temp -> safe_compute read_string_date temp
      in
      let temp = splitify "[ (%)]+" (get_val ic) in
      let forward_div_yield =
        ( safe_compute float_of_string (fst temp),
          safe_compute float_of_string (snd temp) )
      in
      let market_cap =
        safe_compute ~op:false read_mc (get_val ic) |> Option.get
      in
      let open_price = get_val_float_safe ~op:false ic |> Option.get in
      let pe_ratio_ttm = get_val_float_safe ic in
      let prev_close = get_val_float_safe ~op:false ic |> Option.get in
      let quote_price = get_val_float_safe ~op:false ic |> Option.get in
      let volume =
        safe_compute ~op:false int_of_float
          (get_val_float_safe ~op:false ic |> Option.get)
        |> Option.get
      in
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

  (** If [None], then return ""*)
  let na fmt v =
    match v with
    | None -> "N/A"
    | Some v -> Printf.sprintf fmt v

  let na_date v =
    match v with
    | None -> "N/A"
    | Some v -> Date.to_string v

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
           \tPrevious Close:\t\t%.02f\n\
           \tOpen:\t\t\t%.02f\n\
           \tQuote Price:\t\t%#f\n\
           \tBid:\t\t\t%s x %s\n\
           \tAsk:\t\t\t%s x %s\n\
           \tDay's Range:\t\t%s - %s\n\
           \t52 Week Range:\t\t%s - %s\n\
           \tVolume:\t\t\t%#i\n\
           \tAvg. Volume:\t\t%s\n\
           \tMarket Cap:\t\t%#i\n\
           \tBeta (5Y Monthly):\t%s\n\
           \tPE Ratio (TTM):\t\t%s\n\
           \tEPS (TTM):\t\t%s\n\
           \tEarnings Date:\t\t%s - %s\n\
           \tForward Div & Yield:\t%s (%s)\n\
           \tEx-Dividend Date:\t%s\n\
           \t1Y Target Estimate:\t%s\n\
          \        " tkr
          (fst timestamp |> Date.to_string)
          (snd timestamp |> Date.t_to_string)
          prev_close open_price quote_price
          (fst bid |> na "%.02f")
          (snd bid |> na "%i")
          (fst ask |> na "%.02f")
          (snd ask |> na "%i")
          (fst day_range |> na "%.02f")
          (snd day_range |> na "%.02f")
          (fst week_range_52w |> na "%.02f")
          (snd week_range_52w |> na "%.02f")
          volume
          (avg_day_vol |> na "%#i")
          (market_cap |> int_of_float)
          (beta_5y_mly |> na "%.02f")
          (pe_ratio_ttm |> na "%.02f")
          (eps_ttm |> na "%.02f")
          (fst earnings_date |> na_date)
          (snd earnings_date |> na_date)
          (fst forward_div_yield |> na "%.02f")
          (snd forward_div_yield |> na "%.02f%%")
          (ex_date |> na_date)
          (targ_est_1y |> na "%.02f")
        |> String.map (function
             | '_' -> ','
             | char -> char)
end
