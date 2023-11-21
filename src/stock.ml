(** Stock.ml - Stores stock information, tickers, current information *)

open Date

module type StockType = sig
  type t
  (** Representation type. *)

  exception OutOfInterval
  (** Raised when trying to access invalid time. *)

  val of_input : string -> string -> float -> date -> float -> float -> t
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

  val volume : t -> float
  (** Returns volume at last time of access. *)

  val average_price : date -> date -> t -> float
  (** [average_price start_date end_date stock] returns average closing stock
      price over that interval. Raise [InvalidDate] if either date is invalid.
      Raise [OutOfInterval] if that memory date is unretrievable. *)

  val to_string_simple : t -> string
  (** Returns a string of the at-a-glance human-readable version of a given
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
    volume : float;
  }

  let of_input (ticker : string) (name : string) (price : float) (time : date)
      (market_cap : float) (volume : float) : t =
    { ticker; name; price; time; market_cap; volume }

  let ticker (stk : t) : string = stk.ticker
  let name (stk : t) : string = stk.name
  let price ?(time = (0, 0, 0)) (stk : t) : float = stk.price
  let time (stk : t) : date = stk.time
  let market_cap (stk : t) : float = stk.market_cap
  let volume (stk : t) : float = stk.volume

  exception OutOfInterval

  let average_price (start : date) (endt : date) (stk : t) : float =
    failwith "Unimplemented"

  let to_string_simple (stk : t) : string =
    let rounded_price = Float.round (stk.price *. 100.) /. 100. in
    "\n" ^ stk.ticker ^ " - $" ^ string_of_float rounded_price ^ "\n"

  let to_string_detailed (stk : t) : string =
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
