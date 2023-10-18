(** Parser.ml - Reads a file input of stock information *)

module type ParserType = sig
  type t
  (** Representation type.*)

  val of_csv : string -> t
  (** Read valid tickers from CSV location*)
end

module Parser = struct
  type t = unit

  let of_csv (src : string) : t = failwith "Unimplemented"
end
(* of Parser *)
