(** [Date] module contains all the utilities and checks that are used to
    represent date and time of day. Also calculates business days and holidays
    of any given year. *)

type date = int * int * int
(** Representation type of a date: [MM-DD-YYYY] format. *)

type time = int * int * int
(** Representation type of a time: [HH:MM:SS] format. *)

(** Type signature of the [Date] module. *)
module type DateType = sig
  exception InvalidDate
  (** Raised when attempting to input an invalid date, or a date before
      1/1/1900. *)

  val is_valid : date -> bool
  (** [is_valid date] returns a boolean of if a date is valid or not. Note that
      [date] before 1/1/1900 is considered invalid. *)

  val doy : date -> int
  (** [doy date] returns the day number of the year. Requires valid day input
      after 1/1/1900. *)

  val dow : date -> int
  (** [day date] returns the day of the week on that date. [0] represents
      Monday, [1] Tuesday, and so on. Requires a valid [date] input after
      1/1/1900. For example, [dow (01,01,1900)] is [0]. *)

  val diff : date -> date -> int
  (** [diff from to'] returns the integer number of days between these two
      dates. Requires [from] < [to']. Requires [from] and [to'] to be valid
      dates after 1/1/1900. *)

  val prev : date -> date
  (** Returns the previous valid date. *)

  val next : date -> date
  (** Returns the next valid date. *)

  val next_business : ?offset:int -> date -> date
  (** Returns the [n]th next valid business date, if [offset] optional field not
      provided, defaults to the next business day. Requires [offset] >= 1 and
      [date] to be valid date after 1/1/1900. *)

  val holiday_list : int -> (string * date) list
  (** [holiday_list yr] returns the list of stock-market recognized holidays in
      format [("holiday name", date)]. List is sorted from earliest to latest.
      Requires valid [yr] input. *)

  val to_string : date -> string
  (** Returns a string representation of the date in [MM-DD-YYYY]. *)

  val t_to_string : time -> string
  (** Returns a string representation of the time in [HH:MM:SS]. *)

  val of_string : string -> date
  (** Parses a string into a date. Raises [InvalidDate] if not valid date,
      raises [Invalid_argument] if not in correct [MM-DD-YYYY] format. *)

  val t_of_string : string -> time
  (** Parses a string into a time. Raises [Invalid_argument] if not in correct
      [HH:MM:SS] format. *)

  val compare : date -> date -> int
  (** [compare x y] returns [0] if [x] is equal to [y], a negative integer if
      [x] is less than [y], and a positive integer if [x] is greater than [y].*)
end
(* of [DateType]. *)

module Date : DateType
(** Implementation of [Date] module. *)
