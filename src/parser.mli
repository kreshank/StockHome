open Stock
(** A parser that can process a text file (csv) of stock information and pack
    into an Ocaml-processable format. *)

module type ParserType = sig
  type slice
  (** Type that represents a given stock's info at some time.*)

  type t
  (** Representation type.*)

  val of_csv : string -> t
  (**Returns Parser.t (slice list map) when given a filename for a csv file.
     Reads the csv file given and returns an updated map based on the
     information present in the csv.*)

  val to_stock : string -> t -> Stock.t option
  (** Given a ticker, returns a Stock representing the current information of
      the stock present in the parser. Returns [None] if ticker is not in
      Parser.*)

  val slice_list : string -> t -> slice list option
  (** Given a ticker, return the slice list associated with the ticker. Returns
      [None] if ticker is not in Parser. *)
end

module Parser : ParserType
