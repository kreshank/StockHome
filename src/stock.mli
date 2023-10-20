(** Stock.mli - Stores stock information, tickers, current information *)

open Date

module type StockType = sig
  type t
  (** Representation type. *)

  exception OutOfInterval
  (** Raised when trying to access invalid time. *)

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

  val average_price : date -> date -> t -> float
  (** Returns average stock price over an interval. If out of range, should
      raise OOB exception. *)

  val to_string_simple : t -> string
  (** Returns a string of the at-a-glance human-readable version of a given
      stock. *)

  val to_string_detailed : t -> string
  (** Returns a string of a more in-depth summary of a given stock. *)
end

module Stock : StockType
