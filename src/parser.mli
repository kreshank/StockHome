open Stock
(** A parser that can process a text file (csv) of stock information and pack
    into an Ocaml-processable format. *)

module type ParserType = sig
  type t
  (** Representation type.*)

  val of_csv : string -> t
  (**Returns Parser.t (slice list map) when given a filename for a csv file.
     Reads the csv file given and returns an updated map based on the
     information present in the csv.*)

  val to_stock : string -> t -> Stock.t
  (** Given a ticker, returns a Stock representing the current information of
      the stock present in the parser.*)
end

module Parser : ParserType
