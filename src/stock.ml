(** Stock.ml - Stores stock information, tickers, current information *)

open Date

module type StockType = sig
  type t
  (** Representation type. *)

  exception OutOfInterval
  (** Raised when trying to access invalid time. *)

  val of_input : string -> string -> float -> date -> float -> int -> t
  (** [of_input ticker name price date market_cap volume] creates a stock based
      on input. Mainly used for testing purposes. Raises [InvalidDate] if date
      is invalid.*)

  val ticker : t -> string
  (** Returns ticker of a given stock. *)

  val name : t -> string
  (** Returns stock name of a given stock. *)

  val price : ?time:date -> t -> float
  (** Returns last retrieved stock price at a given time. If left blank, then
      defaults to the price at most recent time of access. *)

  val time : t -> date
  (** Returns last time of access. *)

  val market_cap : t -> float
  (** Returns market cap at last time of access. *)

  val volume : t -> int
  (** Returns volume at last time of access. *)

  val average_price : date -> date -> t -> float
  (** [average_price start_date end_date stock] returns average closing stock
      price over that interval. Raise [InvalidDate] if either date is invalid.
      Raise [OutOfInterval] if that memory date is unretrievable. *)

  val to_string : t -> string
  (** [to_string s] returns a single-line brief string representation of a given
      stock. *)

  val to_string_detailed : t -> string
  (** Returns a string of a more in-depth summary of a given stock. *)
end

module Stock = struct
  type t = {
    ticker : string;
    name : string;
    price : float;
    time : date;
    market_cap : float;
    volume : int;
  }

  let of_input (ticker : string) (name : string) (price : float) (time : date)
      (market_cap : float) (volume : int) : t =
    { ticker; name; price; time; market_cap; volume }

  let ticker (stk : t) : string = stk.ticker
  let name (stk : t) : string = stk.name
  let price ?(time = (0, 0, 0)) (stk : t) : float = stk.price
  let time (stk : t) : date = stk.time
  let market_cap (stk : t) : float = stk.market_cap
  let volume (stk : t) : int = stk.volume

  exception OutOfInterval

  let average_price (start : date) (endt : date) (stk : t) : float =
    failwith "Unimplemented"

  let to_string (stk : t) : string =
    Printf.sprintf "%s (%s): $%.5f" stk.ticker (Date.to_string stk.time)
      stk.price

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
