(** Stock.mli - Stores stock information, tickers, current information *)

open Datatypes

module type StockType = sig
  type t
  (** Representation type. *)

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

module Stock : StockType
