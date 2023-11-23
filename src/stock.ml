(** Stock.ml - Stores stock information, tickers, current information *)

open Date
open Slice

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

  val of_input : string -> string -> float -> date -> float -> int -> t
  (** [of_input ticker name price date market_cap volume] creates a stock based
      on input. Mainly used for testing purposes. Raises [Date.InvalidDate] if
      date is invalid.*)

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
        [InvalidDate] if unable to access the first two days before or on
        [?time].
      - [?handler=AVERAGE] case: return the average closing-price of the first
        day before and the first day after [?date].
      - [?handler=ERROR] case: raises [Date.InvalidDate] for all holidays and
        weekends. *)

  val time : t -> date
  (** Returns last time of access. *)

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
    time : date;
    market_cap : float;
    volume : int;
    historical : query;
  }
  (** Rep type *)

  (** Make Stock.t from inputs. *)
  let of_input (ticker : string) (name : string) (price : float) (time : date)
      (market_cap : float) (volume : int) : t =
    { ticker; name; price; time; market_cap; volume; historical = [] }

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

  (** [?handler=PREVIOUS] case: return the most recent non-adjusted closing day
      price of the stock. Raises [InvalidDate] if requesting date before stock
      creation date.*)
  let price_h_prev (time : date) (stk : t) : float =
    prev_helper time stk.historical |> Slice.close_price

  (** Returns a pair of [(first,second)] where [first] is the first [Slice.t]
      that is before, or equal to a given date. *)
  let rec lin_helper (time : date) (lst : query) : Slice.t * Slice.t =
    match lst with
    | [] -> raise Date.InvalidDate
    | [ x ] -> raise Date.InvalidDate
    | first :: second :: t ->
        if Date.compare (Slice.time first) time <= 0 then (first, second)
        else lin_helper time (second :: t)

  (** Performs result of euler step estimation of a day's prices, based off
      [second] closing price and [first] opening prices. *)
  let lin_euler (time : date) (first : Slice.t) (second : Slice.t) : float = 0.0

  (** [?handler=LINEAR] case: return a Euler-step estimation of the price of
      that stock on that date, based on surrounding days.*)
  let price_h_lin (time : date) (stk : t) : float =
    let first, second = lin_helper time stk.historical in
    if Date.compare (Slice.time first) time = 0 then Slice.close_price first
    else lin_euler time first second

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

  (** [?handler=AVERAGE] case: return the average price of the first closing
      price before and the first opening price after [?date].*)
  let price_h_avg (time : date) (stk : t) : float =
    match stk.historical with
    | [] -> raise Date.InvalidDate
    | front :: hist ->
        if Date.compare (front |> Slice.time) time = 0 then
          raise Date.InvalidDate
        else
          let before, after = avg_helper time hist front in
          (Slice.close_price before +. Slice.close_price after) /. 2.0

  (** [?handler=ERROR] case: throw [InvalidDate]. *)
  let price_h_err (time : date) (stk : t) : float = failwith "unim"

  (** [?handler=DEFAULT] case: defaults to [PREVIOUS]. *)
  let price_h_def (time : date) (stk : t) : float = price_h_prev time stk

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
      if handler = PREVIOUS then price_h_prev time stk
      else if handler = LINEAR then price_h_lin time stk
      else if handler = AVERAGE then price_h_avg time stk
      else if handler = ERROR then price_h_err time stk
      else price_h_def time stk
    else stk.price

  let time (stk : t) : date = stk.time
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
    stk.volume

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
    Printf.sprintf "%s (%s): $%.5f" stk.ticker (Date.to_string stk.time)
      stk.price

  (** Returns a string of a more in-depth summary of a given stock. *)
  let to_string_detailed (stk : t) : string =
    Printf.sprintf
      "\n\
       %s - %s (%s): \n\
       \tCurrent Price: $%.7f \n\
       \tVolume: %i \n\
       \tMarket Cap: $%.2f" stk.ticker stk.name (Date.to_string stk.time)
      stk.price stk.volume stk.market_cap
end
(* of Stock*)
