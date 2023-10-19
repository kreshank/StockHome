(** Stock.ml - Stores stock information, tickers, current information *)

open Datatypes

module type StockType = sig
  type t
  (** Representation type. *)

  val of_input : string -> string -> float -> date -> float -> float -> t
  (** [of_input ticker name price date market_cap volume] creates a stock based
      on input. Mainly used for testing purposes. *)

  val ticker : t -> string
  (** Returns ticker of a given stock. *)

  val name : t -> string
  (** Returns stock name of a given stock. *)

  val price : t -> float
  (** Returns last retrieved stock price of a given stock. *)

  val time : t -> date
  (** Returns last time of access. *)

  val market_cap : t -> float
  (** Returns market cap at last time of access. *)

  val volume : t -> float
  (** Returns volume at last time of access. *)

  exception OutOfInterval
  (** Raised when trying to access invalid time. *)

  val average_price : date -> date -> t -> float
  (** Returns average stock price over an interval. If out of range, should
      raise OOB exception. *)

  val of_string_simple : t -> string
  (** Returns a string of the at-a-glance human-readable version of a given
      stock. *)

  val of_string_detailed : t -> string
  (** Returns a string of a more in-depth summary of a given stock. *)
end

module Stock = struct
  type t = {
    ticker : string;
    name : string;
    price : float;
    time : date;
    market_cap : float;
    volume : float;
  }

  let of_input (ticker : string) (name : string) (price : float) (time : date)
      (market_cap : float) (volume : float) : t =
    { ticker; name; price; time; market_cap; volume }

  let ticker (stk : t) : string = stk.ticker
  let name (stk : t) : string = stk.name
  let price (stk : t) : float = stk.price
  let time (stk : t) : date = stk.time
  let market_cap (stk : t) : float = stk.market_cap
  let volume (stk : t) : float = stk.volume

  exception OutOfInterval

  let average_price (start : date) (endt : date) (stk : t) : float =
    failwith "Unimplemented"

  let of_string_simple (stk : t) : string =
    let rounded_price = Float.round (stk.price *. 100.) /. 100. in
    "\n" ^ stk.ticker ^ " - $" ^ string_of_float rounded_price ^ "\n"

  let of_string_detailed (stk : t) : string =
    let rounded_price = Float.round (stk.price *. 100.) /. 100. in
    let rounded_market_cap = Float.round stk.market_cap in
    let rounded_volume = Float.round stk.volume in
    "\n" ^ stk.ticker ^ " - " ^ stk.name ^ "\n" ^ "\tCurrent Price: $"
    ^ string_of_float rounded_price
    ^ "\n" ^ "\tMarket Cap: "
    ^ string_of_float rounded_market_cap
    ^ "\n" ^ "\tVolume: "
    ^ string_of_float rounded_volume
    ^ "\n"
end
(* of Stock*)
