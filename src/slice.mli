(** [Slice] module holds a "slice" of time in the historical information for a
    stock. Is primarily used as a tool for processing historical data of a
    stock. *)

open Date

module type SliceType = sig
  (** Type signature of [Slice] module that contains all functions and values
      necessary to represent a datatype that can hold stock data. *)

  type t
  (** Representation type. *)

  val make :
    string ->
    ?open_price:float ->
    ?high:float ->
    ?low:float ->
    ?close_price:float ->
    ?adjclose:float ->
    ?volume:int ->
    date ->
    t
  (** Initializes and creates a stock Slice. The only required fields are
      [ticker] and [time], whereas the other fields [open_price], [high], [low],
      [adjclose], [close_price], and [volume] are optional arguments, set to
      [0.0] or [0] by default. *)

  val ticker : t -> string
  (** [ticker s] returns the ticker of [s]. *)

  val open_price : t -> float
  (** [open_price s] returns the open price of [s] (at time [time] of slice
      creation). *)

  val high : t -> float
  (** [high s] returns the highest price of [s] (at time [time] of slice
      creation). *)

  val low : t -> float
  (** [low s] returns the lowest price of [s] (at time [time] of slice
      creation). *)

  val close_price : t -> float
  (** [close_price s] returns the closing price of [s] (at time [time] of slice
      creation). *)

  val adjclose : t -> float
  (** [adjclose s] returns the adjusted closing price of [s] (at time [time] of
      slice creation). *)

  val volume : t -> int
  (** [volume s] returns the volume of [s] (at time [time] of slice creation). *)

  val time : t -> date
  (** [time s] returns the timestamp of the *)

  val to_string : t -> string
  (** [to_string s] returns a brief, single-line string representation, showing
      only ticker, date, and closing price. *)

  val to_string_detailed : t -> string
  (** [to_string_detailed s] returns a detailed string representation that
      displays all fields of a Slice. *)
end

module Slice : SliceType
(** Implementation of SliceType.*)
