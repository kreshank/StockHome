(** Stock.mli - Stores stock information, tickers, current information *)

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

module Stock : StockType
