(** A module that conatins functionality regarding the saving and writing of
    portfolios. Used to ensure data can be saved when the program is closed. *)

open Portfolio

module type SaveWriteType = sig
  val save : Portfolio.t -> unit
  (** Given a [Portfolio.t], writes to src/savedata.txt the information stored
      within the portfolio. Overwrites any existing data.*)

  val load : unit -> Portfolio.t
  (** Can be called to return a [Portfolio.t] that contains information stored
      within [src/savedata.txt]. If no data is present, returns an empty
      portfolio.*)

  val clear : unit -> unit
  (** Can be called to clear the saved data within [src/savedata.txt],
      Essentially removes the save.*)
end

(*____________________________________________________________________________*)

module SaveWrite : SaveWriteType = struct
  (** Can be called to clear the saved data within [src/savedata.txt],
      Essentially removes the save.*)
  let clear () =
    let oc = open_out_bin "src/savedata.txt" in
    Printf.fprintf oc "%f" ~-.1.0;
    close_out oc

  (** Given a [Portfolio.t], writes to src/savedata.txt the information stored
      within the portfolio. Overwrites any existing data.*)
  let save (input : Portfolio.t) : unit =
    clear ();
    if input = Portfolio.new_portfolio () then ()
    else
      let oc = open_out_bin "src/savedata.txt" in
      output_value oc (Portfolio.get_balance input);
      output_string oc "\n";
      output_value oc (Portfolio.get_stock_holdings input);
      close_out oc

  (** Can be called to return a [Portfolio.t] that contains information stored
      within [src/savedata.txt]. If no data is present, returns an empty
      portfolio.*)
  let load () : Portfolio.t =
    let ic = open_in_bin "src/savedata.txt" in
    let line_one = float_of_string (input_line ic) in
    if line_one = ~-.1.0 then Portfolio.new_portfolio ()
    else
      let line_two = float_of_string (input_line ic) in
      Portfolio.new_portfolio ()
      |> Portfolio.update_balance line_one
      |> Portfolio.update_stock_holding line_two
end
(* of Save_write *)
