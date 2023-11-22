(** A module that conatins functionality regarding the saving and writing of
    portfolios. Used to ensure data can be saved when the program is closed. *)

open Portfolio

module type SaveWriteType = sig
  val save : Portfolio.t -> unit
  (** Given a [Portfolio.t], writes to data/savedata.txt the information stored
      within the portfolio. Overwrites any existing data.*)

  val load : unit -> Portfolio.t
  (** Can be called to return a [Portfolio.t] that contains information stored
      within [data/savedata.txt]. If no data is present, returns an empty
      portfolio.*)

  val clear : unit -> unit
  (** Can be called to clear the saved data within [data/savedata.txt],
      Essentially removes the save.*)
end

let save_BA (input : Portfolio.t) : string =
  if Portfolio.get_bank_accounts input = [] then "empty\n"
  else
    let bank_accounts =
      List.fold_left
        (fun acc x -> string_of_int x ^ " " ^ acc)
        ""
        (Portfolio.get_bank_accounts input)
    in

    String.sub bank_accounts 0 (String.length bank_accounts - 1) ^ "\n"

let load_BA (input : string) (port : Portfolio.t) : Portfolio.t =
  if input = "empty" then port
  else
    let line =
      List.rev
        (String.split_on_char ' ' input |> List.map (fun x -> int_of_string x))
    in
    List.fold_left (fun acc x -> Portfolio.add_bank_account x acc) port line

(*____________________________________________________________________________*)

module SaveWrite : SaveWriteType = struct
  (** Can be called to clear the saved data within [data/savedata.txt],
      Essentially removes the save.*)
  let clear () =
    let oc = open_out "data/savedata.txt" in
    Printf.fprintf oc "%s\n" "0.0";
    Printf.fprintf oc "%s\n" "0.0";
    output_string oc "empty\n";

    flush oc;
    close_out oc

  (** Given a [Portfolio.t], writes to [data/savedata.txt] the information
      stored within the portfolio. Overwrites any existing data.*)
  let save (input : Portfolio.t) : unit =
    clear ();

    let oc = open_out "data/savedata.txt" in
    let balance = Printf.sprintf "%f\n" (Portfolio.get_balance input) in
    let holdings = Printf.sprintf "%f\n" (Portfolio.get_stock_holdings input) in
    let bank_accounts = save_BA input in

    output_string oc balance;
    output_string oc holdings;
    output_string oc bank_accounts;
    output_string oc "end";

    flush oc;
    close_out oc

  (** Can be called to return a [Portfolio.t] that contains information stored
      within [data/savedata.txt]. If no data is present, returns an empty
      portfolio.*)
  let load () : Portfolio.t =
    let ic = open_in "data/savedata.txt" in
    let port = Portfolio.new_portfolio () in

    try
      let line_one = float_of_string (input_line ic) in
      let line_two = float_of_string (input_line ic) in
      let line_three = input_line ic in

      let port =
        close_in ic;
        port
        |> Portfolio.update_balance line_one
        |> Portfolio.update_stock_holding line_two
        |> load_BA line_three
      in
      port
    with End_of_file ->
      print_string "closed";
      close_in ic;
      port
end
(* of Save_write *)
