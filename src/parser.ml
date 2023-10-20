(** Parser.ml - Reads a file input of stock information *)

open Datatypes
open Stock

module type ParserType = sig
  type t
  (** Representation type.*)

  val of_csv : string -> t
  (**Returns Parser.t (slice list map) when given a filename for a csv file.
     Reads the csv file given and returns an updated map based on the
     information present in the csv.*)

  val to_stock : string -> t -> Stock.t
  (** Given a ticker, returns a Stock representing the current information of
      the stock present in the parser. Failswith "Ticker Not Found" if ticker is
      not in Parser*)
end

module String_map : Map.S with type key = string = Map.Make (struct
  type t = string

  let compare = String.compare
end)

module Parser = struct
  type slice = {
    open_price : float;
    curr_date : date;
    high : float;
    low : float;
    close : float;
    adj_float : float;
    volume : float;
    ticker : string;
  }

  type t = slice list String_map.t
  (**Data type t stores information that is provided by the csv and holds it in
     a record.*)

  (**Helper function for of_csv. Takes in a row from the csv and processes it
     into a slice, updating the map with it.*)
  let process_slice (line : string) (map : t) : t =
    let line_list = String.split_on_char ',' line in
    let date_list = String.split_on_char '-' (List.nth line_list 0) in
    let curr_slice =
      {
        open_price = float_of_string (List.nth line_list 1);
        curr_date =
          ( int_of_string (List.nth date_list 1),
            int_of_string (List.nth date_list 2),
            int_of_string (List.nth date_list 0) );
        high = float_of_string (List.nth line_list 2);
        low = float_of_string (List.nth line_list 3);
        close = float_of_string (List.nth line_list 4);
        adj_float = float_of_string (List.nth line_list 5);
        volume = float_of_string (List.nth line_list 6);
        ticker = List.nth line_list 7;
      }
    in
    String_map.update curr_slice.ticker
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

  let of_csv (file_name : string) : t =
    let map = String_map.empty in

    try
      let ic = open_in file_name in
      (* Skip the first line, columns headers *)
      let _ = input_line ic in
      recurse_csv ic map
    with e -> raise e

  let to_stock (ticker : string) (p : t) : Stock.t =
    let got_slice =
      List.hd
        (match String_map.find_opt ticker p with
        | Some s -> s
        | None -> failwith "Ticker Not Found")
    in

    Stock.of_input got_slice.ticker got_slice.ticker got_slice.open_price
      got_slice.curr_date 2. got_slice.volume
end
(* of Parser *)
