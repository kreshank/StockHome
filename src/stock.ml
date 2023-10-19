(** Stock.ml - Stores stock information, tickers, current information *)

open Datatypes

module type StockType = sig
  type t
  (** Representation type. *)

  val of_string : t -> string
  (** Returns a string of a human-readable version of a stock. *)

  val current_price : t -> float
  (** Returns current stock price at a *)

  exception OutOfInterval

  val average_price : date -> date -> t -> float
  (** Returns average stock price over an interval. If out of range, should
      raise OOB exception. *)
end

module Stock = struct
  type t = unit

  let of_string (stk : t) : string = failwith "Unimplemented"
  let current_price (stk : t) : float = failwith "Unimplemented"

  exception OutOfInterval

  let average_price (start : date) (endt : date) (stk : t) : float =
    failwith "Unimplemented"
end
(* of Stock*)
