(** Parser.ml - Reads a file input of stock information *)

open Date
open Stock
open Slice

module type ParserType = sig
  type slice = Slice.t
  (** Type that represents a given stock's info at some time.*)

  type t
  (** Representation type.*)

  val of_csv : string -> t
  (**Returns Parser.t ([slice list map]) when given a filename for a csv file.
     Reads the csv file given and returns an updated map based on the
     information present in the csv.*)

  val to_stock : string -> t -> Stock.t option
  (** Given a ticker, returns a Stock representing the current information of
      the stock present in the parser. Returns [None] if ticker is not in Parser*)

  val slice_list : string -> t -> slice list option
  (** Given a ticker, return the slice list associated with the ticker. Returns
      [None] if ticker is not in Parser *)
end

module String_map : Map.S with type key = string = Map.Make (struct
  type t = string

  let compare = String.compare
end)

module Parser = struct
  type slice = Slice.t

  type t = slice list String_map.t
  (**Data type t stores information that is provided by the csv and holds it in
     a record.*)

  (**Helper function for of_csv. Takes in a row from the csv and processes it
     into a slice, updating the map with it.*)
  let process_slice (line : string) (map : t) : t =
    let line_list = String.split_on_char ',' line in
    let date_list = String.split_on_char '-' (List.nth line_list 0) in
    let curr_slice =
      Slice.make
        (List.nth line_list 7) (*Ticker*)
        ~open_price:(float_of_string (List.nth line_list 1))
        ~high:(float_of_string (List.nth line_list 2))
        ~low:(float_of_string (List.nth line_list 3))
        ~close_price:(float_of_string (List.nth line_list 4))
        ~adjclose:(float_of_string (List.nth line_list 5))
        ~volume:(int_of_string (List.nth line_list 6))
        ( int_of_string (List.nth date_list 1),
          int_of_string (List.nth date_list 2),
          int_of_string (List.nth date_list 0) )
      (*Date*)
    in

    String_map.update (Slice.ticker curr_slice)
      (fun lst ->
        match lst with
        | Some s -> Some (curr_slice :: s)
        | None -> Some [ curr_slice ])
      map

  (**Helper function for of_csv. Takes in an input channel and map and returns
     the updated map when the file is finished being read.*)
  let rec recurse_csv (input : in_channel) (map : t) =
    try
      let u_map = process_slice (input_line input) map in
      recurse_csv input u_map
    with End_of_file ->
      close_in input;
      map

  (**Returns Parser.t (slice list map) when given a filename for a csv file.
     Reads the csv file given and returns an updated map based on the
     information present in the csv.*)
  let of_csv (file_name : string) : t =
    let map = String_map.empty in

    try
      let ic = open_in file_name in
      (* Skip the first line, columns headers *)
      let _ = input_line ic in
      recurse_csv ic map
    with e -> raise e

  (** Given a ticker, returns a Stock representing the current information of
      the stock present in the parser. Returns [None] if ticker is not in Parser*)
  let to_stock (ticker : string) (p : t) : Stock.t option =
    let slice_list = String_map.find_opt ticker p in
    if slice_list = None then None
    else
      let got_slice = List.hd (Option.get slice_list) in
      Some
        (Stock.of_input (Slice.ticker got_slice) (Slice.ticker got_slice)
           (Slice.open_price got_slice)
           (Slice.time got_slice, (0, 0, 0))
           2. (Slice.volume got_slice))
  (*Why is Stock volume still float?*)

  (** Given a ticker, return the slice list associated with the ticker. Returns
      [None] if ticker is not in Parser *)
  let slice_list (ticker : string) (p : t) : slice list option =
    String_map.find_opt ticker p
end
(* of Parser *)
