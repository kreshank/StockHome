(** Savewrite.mli - A module that contains functionality regarding the saving
    and writing of portfolios. Used to ensure data can be saved when the program
    is closed. *)

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

module SaveWrite : SaveWriteType
