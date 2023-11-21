(** Stock.ml - Stores stock information, tickers, current information *)

open Date
open Slice

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

  val volume : ?time:date -> t -> int
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
  type query = Slice.t list
  (** TODO: Should decide whether I want to make this a list, or rather a map
     for better access times: Analysis below.
        - Price:  O(N)/O(1) --> O(logN)
        - Query:  O(N)
      *)

  type t = {
    ticker : string;
    name : string;
    price : float;
    time : date;
    market_cap : float;
    volume : int;
    historical : query;
  }

  let of_input (ticker : string) (name : string) (price : float) (time : date)
      (market_cap : float) (volume : int) : t =
    { ticker; name; price; time; market_cap; volume; historical = [] }

  let ticker (stk : t) : string = stk.ticker
  let name (stk : t) : string = stk.name
  (** TODO: what to do if time is valid, but we don't have a datapoint? get the
     most recent time? 
        - There are a few options here.
            (1) Toss out an error; date is not a true datapoint
                - This is a bad solution, but it is indeed an easy one
            (2) We can use the prices of the closest date
                - If we take this approach, it's important to return a pair
                  of [(date, price)], so we can check that this is indeed 
                  the date that we want to be grabbing. 
            (3) We can do extrapolation/interpolation by performing Euler step
                estimations or some other estimation methods (trend line
                analysis). 
                - This is a bit more involved, but this should also provide a 
                  more usable and useful input for algorithms
            (4) We raise an error and later on, we disallow users to look for 
                weekend times.
            (5) I create an optional argument and type, and let the user choose
                between all the options we can think of. This way, default will
                toss an error if it doesn't exist. *)
  let price ?(time = (-1, -1, -1)) (stk : t) : float =
    if Date.is_valid time then stk.price else stk.price

  let time (stk : t) : date = stk.time
  let market_cap (stk : t) : float = stk.market_cap
  let volume ?(time = (-1, -1, -1)) (stk : t) : int = stk.volume
  (** TODO: See above TODO regarding price. *)

  let historical (stk : t) : query = stk.historical
  let query (start : date) (endt : date) (stk : t) : query = 
    let in_range slice = 
      (Date.compare start (Slice.time slice) <= 0) 
      && (Date.compare (Slice.time slice) endt <= 0) 
    in 
    List.filter in_range stk.historical

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
