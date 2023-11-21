(** Data.ml - Holds Date functions. *)

type date = int * int * int
(* Representation type of a date: MM-DD-YYYY format. *)

module type DateType = sig
  exception InvalidDate
  (** Raised when attempting to input an invalid date. *)

  val is_valid : date -> bool
  (** [is_valid date] returns a boolean of if a date is valid or not. *)

  val to_string : date -> string
  (** Returns a string representation of the date in MM-DD-YYYY. *)

  val of_string : string -> date
  (** Parses a string into a date. Raises [InvalidDate] if not valid date,
      raises [Invalid_argument] if not in correct MM-DD-YYYY format. *)

  val compare : date -> date -> int
  (** [compare x y] returns [0] if [x] is equal to [y], a negative integer if
      [x] is less than [y], and a positive integer if [x] is greater than [y].*)
end

module Date : DateType
