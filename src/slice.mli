open Date

module type SliceType = sig
  type t
  (** Representation type. *)

  val make :
    string ->
    ?open_price:float ->
    ?high:float ->
    ?low:float ->
    ?adjclose:float ->
    ?close_price:float ->
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
end

module Slice : SliceType
