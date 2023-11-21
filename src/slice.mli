open Date

module type SliceType = sig
  type t
  (* Representation type. *)

  val make :
    ticker:string ->
    ?open_price:float ->
    ?high:float ->
    ?low:float ->
    ?adj_close:float ->
    ?close_price:float ->
    ?volume:int ->
    time:date ->
    t

  val ticker : t -> string
  val open_price : t -> float
  val high : t -> float
  val low : t -> float
  val close_price : t -> float
  val adjclose : t -> float
  val volume : t -> int
  val time : t -> date
end

module Slice : SliceType
