(** Data.ml - Holds Date functions. *)

type date = int * int * int
(* Representation type of a date: MM-DD-YYYY format. *)

module type DateType = sig
  exception InvalidDate
  (** Raised when attempting to input an invalid date, a date . *)

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

  val next : date -> date
  (** Returns the next valid date. *)

  val next_business : ?offset:int -> date -> date
  (** Returns the [n]th next valid business date, if [offset] optional field not
      provided, defaults to the next business day. Requires [offset] >= 1 and
      [date] to be valid date after 1/1/1900. *)

  val to_string : date -> string
  (** Returns a string representation of the date in MM-DD-YYYY. *)

  val of_string : string -> date
  (** Parses a string into a date. Raises [InvalidDate] if not valid date,
      raises [Invalid_argument] if not in correct MM-DD-YYYY format. *)

  val compare : date -> date -> int
  (** [compare x y] returns [0] if [x] is equal to [y], a negative integer if
      [x] is less than [y], and a positive integer if [x] is greater than [y].*)
end

module Date = struct
  exception InvalidDate

  (** Returns 1 if is leap year, 0 otherwise. *)
  let leap_offset yr =
    if yr mod 400 = 0 then 1
    else if yr mod 100 = 0 then 0
    else if yr mod 4 = 0 then 1
    else 0

  (** Check if date is valid. *)
  let is_valid ((m, d, y) : date) : bool =
    if y < 1900 then false
    else if m = 1 || m = 3 || m = 5 || m = 7 || m = 8 || m = 10 || m = 12 then
      1 <= d && d <= 31
    else if m = 4 || m = 6 || m = 9 || m = 11 then 1 <= d && d <= 30
    else if m = 2 then 1 <= d && d <= 28 + leap_offset y
    else false

  (** Return days in a year. *)
  let days_in_yr yr : int = 365 + leap_offset yr

  (** Day Of Year. Requires valid date after 1/1/1900 as input. *)
  let doy ((m, d, y) : date) : int =
    let offset = leap_offset y + d in
    if m = 1 then d
    else if m = 2 then 31 + d
    else if m = 3 then 59 + offset
    else if m = 4 then 90 + offset
    else if m = 5 then 120 + offset
    else if m = 6 then 151 + offset
    else if m = 7 then 181 + offset
    else if m = 8 then 212 + offset
    else if m = 9 then 243 + offset
    else if m = 10 then 273 + offset
    else if m = 11 then 304 + offset
    else 334 + offset

  (** Returns days since 1/1/1900, not including that date. Requires a day on or
      after 1/1/1900. *)
  let day_since_1900 ((m, d, y) : date) : int =
    let rec go_to_yr (m, d, y) cur_year acc =
      if cur_year < y then
        go_to_yr (m, d, y) (cur_year + 1) (acc + days_in_yr cur_year)
      else acc + doy (m, d, y)
    in
    go_to_yr (m, d, y) 1900 0 - 1

  (** Day Of Week. Requires valid date after 1/1/1900 as input. *)
  let dow d = day_since_1900 d mod 7

  let diff (from : date) (to' : date) : int =
    day_since_1900 to' - day_since_1900 from

  let next ((m, d, y) : date) : date =
    let incr_day = (m, d + 1, y) in
    if is_valid incr_day then incr_day
    else
      let incr_month = (m + 1, 1, y) in
      if is_valid incr_month then incr_month else (1, 1, y + 1)

  let next_business ?(offset = 1) ((m, d, y) : date) : date = failwith "unimpl"

  let to_string ((m, d, y) : date) : string =
    string_of_int m ^ "-" ^ string_of_int d ^ "-" ^ string_of_int y

  let of_string (inp : string) : date =
    let splitted = String.split_on_char '-' inp in
    match splitted with
    | [ m; d; y ] ->
        let pot = (int_of_string m, int_of_string d, int_of_string y) in
        if is_valid pot then pot else raise InvalidDate
    | _ -> invalid_arg "Wrong date format"

  let compare ((m1, d1, y1) : date) ((m2, d2, y2) : date) : int =
    let y_cmp = compare y1 y2 in
    let m_cmp = compare m1 m2 in
    let d_cmp = compare d1 d2 in
    if y_cmp = 0 then if m_cmp = 0 then d_cmp else m_cmp else y_cmp
end
(* of Date.ml *)
