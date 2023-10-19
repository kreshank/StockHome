(** A parser that can process a text file (csv) of stock information and pack
    into an Ocaml-processable format. *)
module type ParserType = sig
  type t
  (** Representation type.*)

  val of_csv : string -> t
  (** Read valid tickers from CSV location*)
end

module Parser : ParserType
