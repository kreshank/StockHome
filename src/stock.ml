(** Stock.ml - Stores stock information, tickers, current information *)

open Date
open Slice
open Daysum
open Api

module type StockType = sig
  type query = Slice.t list

  type cfg =
    | DEFAULT
    | PREVIOUS
    | LINEAR
    | AVERAGE
    | ERROR

  type t
  (** Representation type. *)

  exception UnretrievableStock of string

  val of_input : string -> string -> float -> date * time -> float -> int -> t
  (** [of_input ticker name price date market_cap volume] creates a stock based
      on input. Mainly used for testing purposes. Raises [Date.InvalidDate] if
      date is invalid.*)

  val make : string -> t
  (** [make ticker] returns a new stock type, loading both historical and
      current data fresh for the first time. *)

  val update : t -> t
  (** [update stk] returns a stock with ONLY the current data updated. i.e.,
      historical data will not be changed in any way. If there was error
      grabbing stock info, will return an unmodified [stk]. *)

  val ticker : t -> string
  (** Returns ticker of a given stock. *)

  val name : t -> string
  (** Returns stock name of a given stock. *)

  val price : ?time:date -> ?handler:cfg -> t -> float
  (** [price ?time ?handler stk] returns the closing (or most recent) price of
      the stock at inputted time. [?time] defaults to the most recently accessed
      time of this stock. [?handler] defaults to [PREVIOUS] style. [?handler]
      specifies how to proceed in the case that that [?time] falls on a weekend
      or holiday, when the market is not open. If [?time] optional field is
      provided, it must be a valid [date]. Always raises [Date.InvalidDate] when
      requesting date before stock creation date.
      - If [?time] is a day that the stock market is open, then
        [price ?time stk = price ?time ?handler stk] and will return the price
        at that date.
      - If [?time] is a day in the future, not yet retrievable, then
        [Date.InvalidDate] is thrown.
      - If [?time] is a holiday or weekend, return value is dependent on
        [?handler] setting:
      - [?handler=PREVIOUS] case: return the non-adjusted closing price of the
        stock of the first day before or on [?time].
      - [?handler=LINEAR] case: return a Euler-step estimation of the closing
        price of that stock on [?time], based on previous two days. Raises
        [Date.InvalidDate] if unable to access the first two days before or on
        [?time].
      - [?handler=AVERAGE] case: return the average closing-price of the first
        day before and the first day after [?date].
      - [?handler=ERROR] case: raises [Date.InvalidDate] for all holidays and
        weekends. *)

  val time : t -> date * time
  (** Returns last time of access. *)

  val cur_data : t -> DaySum.t option
  (** Returns current data summary. *)

  val market_cap : t -> float
  (** Returns market cap at last time of access. *)

  val volume : ?time:date -> ?handler:cfg -> t -> int
  (** [volume ?time ?handler stk] returns the volume of the stock at inputted
      time. [?time] defaults to the most recently accessed time of this stock.
      [?handler] defaults to [PREVIOUS] style. [?handler] specifies how to
      proceed in the case that that [?time] falls on a weekend or holiday, when
      the market is not open. If [?time] optional field is provided, it must be
      a valid [date]. Always raises [Date.InvalidDate] when requesting date
      before stock creation date.
      - If [?time] is a day that the stock market is open, then
        [volume ?time stk = volume ?time ?handler stk] and will return the
        volume at that date.
      - If [?time] is a day in the future, not yet retrievable, then
        [Date.InvalidDate] is thrown.
      - If [?time] is a holiday or weekend, return value is dependent on
        [?handler] setting:
      - [?handler=PREVIOUS] case: return the stock volume of the first day
        before or on [?time].
      - [?handler=LINEAR] case: return a Euler-step estimation of the volume of
        that stock on [?time], based on previous two days. Raises
        [Date.InvalidDate] if unable to access the first two days before or on
        [?time].
      - [?handler=AVERAGE] case: return the average volume of the first day
        before and the first day after [?date].
      - [?handler=ERROR] case: raises [Date.InvalidDate] for all holidays and
        weekends. *)

  val historical : t -> query
  (** [historical stk] returns the list of historical information of given
      stock. *)

  val query : date -> date -> t -> query
  (** [query start endt stk] returns the list of historical information between
      [start] and [endt] inclusive. *)

  val average_price : query -> t -> float
  (** [average_price range stk] returns average closing stock price over an
      inputted range. *)

  val to_string : t -> string
  (** [to_string s] returns a single-line brief string representation of a given
      stock. *)

  val to_string_detailed : t -> string
  (** Returns a string of a more in-depth summary of a given stock. *)
end

module Stock = struct
  type query = Slice.t list

  (* TODO: Should decide whether I want to make this a list, or rather a map for
     better access times: Analysis below. - Price: O(N)/O(1) --> O(logN) -
     Query: O(N) *)

  type cfg =
    | DEFAULT
    | PREVIOUS
    | LINEAR
    | AVERAGE
    | ERROR

  type t = {
    ticker : string;
    name : string;
    price : float;
    time : date * time;
    cur_data : DaySum.t option;
    market_cap : float;
    volume : int;
    historical : query;
  }
  (** Rep type *)

  exception UnretrievableStock of string

  (** Make Stock.t from inputs. *)
  let of_input (ticker : string) (name : string) (price : float)
      (time : date * time) (market_cap : float) (volume : int) : t =
    {
      ticker = String.uppercase_ascii ticker;
      name;
      price;
      time;
      cur_data = None;
      market_cap;
      volume;
      historical = [];
    }

  (** [update stk] returns a stock with ONLY the current data updated. i.e.,
      historical data will not be changed in any way. If there was error
      grabbing stock info, will return an unmodified [stk]. *)
  let update (stk : t) : t =
    let tkr_lower = String.lowercase_ascii stk.ticker in
    if try API.current tkr_lower = 0 with e -> raise e then
      let cur_data =
        DaySum.load_from
          (Printf.sprintf "data/stock_info/%s/%s_cur.csv" tkr_lower tkr_lower)
      in

      {
        stk with
        ticker = String.uppercase_ascii stk.ticker;
        time = DaySum.timestamp cur_data;
        price = DaySum.quote_price cur_data;
        cur_data = Some cur_data;
        market_cap = DaySum.market_cap cur_data;
        volume = DaySum.volume cur_data;
      }
    else stk

  (** Read a line into a slice. If improper format, we skip the line. *)
  let parse_line str : Slice.t option =
    let splitted = Str.(split (regexp ",") str) in
    match splitted with
    | [ dt; op; hi; lo; cl; adcl; vol; ticker ] -> (
        let temp = Str.(split (regexp "-") dt) in
        let date =
          match temp with
          | [ y; m; d ] -> (int_of_string m, int_of_string m, int_of_string y)
          | _ -> raise (UnretrievableStock "Historical is misformatted")
        in
        try
          let open_price = float_of_string op in
          let high = float_of_string hi in
          let low = float_of_string lo in
          let close_price = float_of_string cl in
          let adjclose = float_of_string adcl in
          let volume = int_of_string vol in
          Some
            (Slice.make ticker ~open_price ~high ~low ~close_price ~adjclose
               ~volume date)
        with e -> None)
    | _ -> raise (UnretrievableStock "Historical is misformatted.")

  (** Loads history from a given file *)
  let load_hist file_addr =
    let ic = open_in file_addr in
    (* ignore csv labels *)
    let _ = input_line ic in
    let rec create_hist acc =
      try
        let res = parse_line (input_line ic) in
        match res with
        | None -> create_hist acc
        | Some res -> create_hist (res :: acc)
      with End_of_file ->
        close_in ic;
        acc
    in
    create_hist []

  (** [make ticker] returns a new stock type, loading both historical and
      current data fresh for the first time. *)
  let make (ticker : string) : t =
    let tkr_lower = String.lowercase_ascii ticker in
    let tkr_upper = String.uppercase_ascii ticker in
    if
      (tkr_lower
      <> Str.(global_replace (regexp {|[\$\^\\\.\*\+\?\{\}-]+|}) "" tkr_lower))
      || tkr_lower = ""
    then
      raise
        (UnretrievableStock
           (Printf.sprintf "\"%s\" is not a valid ticker." tkr_upper))
    else if try API.historical [ tkr_lower ] = 0 with e -> raise e then
      try
        let historical =
          load_hist
            (Printf.sprintf "data/stock_info/%s/%s_hist.csv" tkr_lower tkr_lower)
        in
        let temp =
          {
            ticker = tkr_upper;
            name = tkr_upper;
            time = ((1, 1, 2020), (0, 0, 0));
            price = 0.;
            cur_data = None;
            market_cap = 0.;
            volume = 0;
            historical;
          }
        in
        update temp
      with e -> raise e
    else
      raise
        (UnretrievableStock
           (Printf.sprintf "%s is not a valid ticker." tkr_upper))

  (** Return ticker. *)
  let ticker (stk : t) : string = stk.ticker

  (** Return name. *)
  let name (stk : t) : string = stk.name

  (** Returns first [Slice.t] that is before, or equal to a given date. *)
  let rec prev_helper (time : date) (lst : query) : Slice.t =
    match lst with
    | [] -> raise Date.InvalidDate
    | h :: t ->
        if Date.compare (Slice.time h) time <= 0 then h else prev_helper time t

  (** [?handler=PREVIOUS] case: returns [field_of stk] where [stk] is the first
      day before or on [?time]. Raises [Date.InvalidDate] if requesting date
      before stock creation date.*)
  let get_h_prev (field_of : Slice.t -> 'a) (time : date) (stk : t) : 'a =
    prev_helper time stk.historical |> field_of

  (** Returns a pair of [(first,second)] where [first] is the first [Slice.t]
      that is before, or equal to a given date. *)
  let rec lin_helper (time : date) (lst : query) : Slice.t * Slice.t =
    match lst with
    | [] -> raise Date.InvalidDate
    | [ x ] -> raise Date.InvalidDate
    | first :: second :: t ->
        if Date.compare (Slice.time first) time <= 0 then (first, second)
        else lin_helper time (second :: t)

  (** Performs result of euler step estimation for [field_of stk], based off
      [second] closing price and [first] opening prices. [first] is the
      [Slice.t] before or equal to a date. *)
  let lin_euler (field_of : Slice.t -> 'a) (time : date) (first : Slice.t)
      (second : Slice.t) : 'a =
    (field_of first -. field_of second)
    *. float_of_int (Date.diff (Slice.time second) (Slice.time first))
  (* TODO: Can improve this to be a regression of sorts *)

  (** [?handler=LINEAR] case: return a Euler-step estimation of [field_of stk]
      of that stock on that date, based on surrounding days.*)
  let get_h_lin (field_of : Slice.t -> 'a) (time : date) (stk : t) : 'a =
    let first, second = lin_helper time stk.historical in
    if Date.compare (Slice.time first) time = 0 then field_of first
    else lin_euler field_of time first second

  (** Returns a pair of [(before, after)] where [before] is the first [Slice.t]
      that is before, or equal to a given date and [after] is the first
      [Slice.t] that is after, or equal to a given date. Raises
      [Date.InvalidDate] if either cannot be retrieved. *)
  let rec avg_helper time (lst : query) (last : Slice.t) : Slice.t * Slice.t =
    match lst with
    | [] -> raise Date.InvalidDate
    | h :: t ->
        let cmp = Date.compare (Slice.time h) time in
        if cmp = 0 then (h, h)
        else if cmp > 0 then avg_helper time t h
        else (h, last)

  (** [?handler=AVERAGE] case: return the average of [field_of before] and
      [field_of after], where [before] and [after] are the first days before and
      after [?date].*)
  let get_h_avg (field_of : Slice.t -> 'a) (time : date) (stk : t) : 'a =
    match stk.historical with
    | [] -> raise Date.InvalidDate
    | front :: hist ->
        if Date.compare (front |> Slice.time) time = 0 then
          raise Date.InvalidDate
        else
          let before, after = avg_helper time hist front in
          (field_of before +. field_of after) /. 2.0

  (** Returns a slice of the queried time, if found, otherwise raise
      [Date.InvalidDate]. *)
  let rec err_helper (time : date) (lst : query) : Slice.t =
    match lst with
    | [] -> raise Date.InvalidDate
    | h :: t ->
        let cmp = Date.compare (Slice.time h) time in
        if cmp = 0 then h
        else if cmp < 0 then raise Date.InvalidDate
        else err_helper time t

  (** [?handler=ERROR] case: raises [Date.InvalidDate] for all holidays and
      weekends. *)
  let get_h_err (field_of : Slice.t -> 'a) (time : date) (stk : t) : 'a =
    err_helper time stk.historical |> field_of

  (** [?handler=DEFAULT] case: defaults to [PREVIOUS]. *)
  let get_h_def (field_of : Slice.t -> 'a) (time : date) (stk : t) : 'a =
    get_h_prev field_of time stk

  (** [price ?time ?handler stk] returns the closing (or most recent) price of
      the stock at inputted time. [?time] defaults to the most recently accessed
      time of this stock. [?handler] defaults to [PREVIOUS] style. [?handler]
      specifies how to proceed in the case that that [?time] falls on a weekend
      or holiday, when the market is not open. If [?time] optional field is
      provided, it must be a valid [date]. Always raises [Date.InvalidDate] when
      requesting date before stock creation date.
      - If [?time] is a day that the stock market is open, then
        [price ?time stk = price ?time ?handler stk] and will return the price
        at that date.
      - If [?time] is a day in the future, not yet retrievable, then
        [Date.InvalidDate] is thrown.
      - If [?time] is a holiday or weekend, return value is dependent on
        [?handler] setting:
      - [?handler=PREVIOUS] case: return the non-adjusted closing price of the
        stock of the first day before or on [?time].
      - [?handler=LINEAR] case: return a Euler-step estimation of the closing
        price of that stock on [?time], based on previous two days. Raises
        [InvalidDate] if unable to access the first two days before or on
        [?time].
      - [?handler=AVERAGE] case: return the average closing-price of the first
        day before and the first day after [?date].
      - [?handler=ERROR] case: raises [Date.InvalidDate] for all holidays and
        weekends. *)
  let price ?(time = (-1, -1, -1)) ?(handler = DEFAULT) (stk : t) : float =
    if Date.is_valid time then
      if handler = PREVIOUS then get_h_prev Slice.close_price time stk
      else if handler = LINEAR then get_h_lin Slice.close_price time stk
      else if handler = AVERAGE then get_h_avg Slice.close_price time stk
      else if handler = ERROR then get_h_err Slice.close_price time stk
      else get_h_def Slice.close_price time stk
    else stk.price

  let time (stk : t) : date * time = stk.time
  let cur_data (stk : t) : DaySum.t option = stk.cur_data
  let market_cap (stk : t) : float = stk.market_cap

  (** [volume ?time ?handler stk] returns the volume of the stock at inputted
      time. [?time] defaults to the most recently accessed time of this stock.
      [?handler] defaults to [PREVIOUS] style. [?handler] specifies how to
      proceed in the case that that [?time] falls on a weekend or holiday, when
      the market is not open. If [?time] optional field is provided, it must be
      a valid [date]. Always raises [Date.InvalidDate] when requesting date
      before stock creation date.
      - If [?time] is a day that the stock market is open, then
        [volume ?time stk = volume ?time ?handler stk] and will return the
        volume at that date.
      - If [?time] is a day in the future, not yet retrievable, then
        [Date.InvalidDate] is thrown.
      - If [?time] is a holiday or weekend, return value is dependent on
        [?handler] setting:
      - [?handler=PREVIOUS] case: return the stock volume of the first day
        before or on [?time].
      - [?handler=LINEAR] case: return a Euler-step estimation of the volume of
        that stock on [?time], based on previous two days. Raises
        [Date.InvalidDate] if unable to access the first two days before or on
        [?time].
      - [?handler=AVERAGE] case: return the average volume of the first day
        before and the first day after [?date].
      - [?handler=ERROR] case: raises [Date.InvalidDate] for all holidays and
        weekends. *)
  let volume ?(time = (-1, -1, -1)) ?(handler = DEFAULT) (stk : t) : int =
    if Date.is_valid time then
      let volume_float stk = Slice.volume stk |> float_of_int in
      if handler = PREVIOUS then get_h_prev Slice.volume time stk
      else if handler = LINEAR then
        int_of_float (get_h_lin volume_float time stk)
      else if handler = AVERAGE then
        int_of_float (get_h_avg volume_float time stk)
      else if handler = ERROR then get_h_err Slice.volume time stk
      else get_h_def Slice.volume time stk
    else stk.volume

  (** [historical stk] returns the list of historical information of given
      stock. *)
  let historical (stk : t) : query = stk.historical

  (** [query start endt stk] returns the list of historical information between
      [start] and [endt] inclusive. *)
  let query (start : date) (endt : date) (stk : t) : query =
    let in_range slice =
      Date.compare start (Slice.time slice) <= 0
      && Date.compare (Slice.time slice) endt <= 0
    in
    List.filter in_range stk.historical

  (** [average_price range stk] returns average closing stock price over an
      inputted range. *)
  let average_price (lst : query) (stk : t) : float =
    let sum =
      List.fold_left (fun acc a -> acc +. Slice.close_price a) 0.0 lst
    in
    sum /. float_of_int (List.length lst)

  (** [to_string s] returns a single-line brief string representation of a given
      stock. *)
  let to_string (stk : t) : string =
    Printf.sprintf "%s (%s, %s): $%.5f" stk.ticker
      (fst stk.time |> Date.to_string)
      (snd stk.time |> Date.t_to_string)
      stk.price

  (** Returns a string of a more in-depth summary of a given stock. *)
  let to_string_detailed (stk : t) : string =
    Printf.sprintf
      "\n\
       %s - %s (%s, %s): \n\
       \tCurrent Price: $%#.7f \n\
       \tVolume: %#i \n\
       \tMarket Cap: $%#i" stk.ticker stk.name
      (fst stk.time |> Date.to_string)
      (snd stk.time |> Date.t_to_string)
      stk.price stk.volume
      (stk.market_cap |> int_of_float)
    |> String.map (function
         | '_' -> ','
         | char -> char)
end
(* of Stock*)
