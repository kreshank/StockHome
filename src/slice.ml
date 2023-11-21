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

module Slice = struct
  type t = {
    ticker : string;
    open_price : float;
    high : float;
    low : float;
    close_price : float;
    adjclose : float;
    volume : int;
    time : date;
  }
  (* Representation type. *)

  let make ticker ?(open_price = 0.) ?(high = 0.) ?(low = 0.) ?(adjclose = 0.)
      ?(close_price = 0.) ?(volume = 0) time =
    { ticker; open_price; high; low; adjclose; close_price; volume; time }

  let ticker s = s.ticker
  let open_price s = s.open_price
  let high s = s.high
  let low s = s.low
  let close_price s = s.close_price
  let adjclose s = s.adjclose
  let volume s = s.volume
  let time s = s.time
end
