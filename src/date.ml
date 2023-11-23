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

  (** Returns "mm-dd-yyyy" *)
  let to_string ((m, d, y) : date) : string =
    string_of_int m ^ "-" ^ string_of_int d ^ "-" ^ string_of_int y

  (** [compare a b] returns value < [0] if [a] < [b], value > [0] if [a] > [b],
      and value = [0] if [a] = [b].*)
  let compare ((m1, d1, y1) : date) ((m2, d2, y2) : date) : int =
    let y_cmp = compare y1 y2 in
    let m_cmp = compare m1 m2 in
    let d_cmp = compare d1 d2 in
    if y_cmp = 0 then if m_cmp = 0 then d_cmp else m_cmp else y_cmp

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

  (** Day Of Week. Requires valid date after 1/1/1900 as input. Returns [0] if
      is monday.*)
  let dow d = day_since_1900 d mod 7

  (** Get number of days between dates. *)
  let diff (from : date) (to' : date) : int =
    day_since_1900 to' - day_since_1900 from

  (** Get previous date. *)
  let prev ((m, d, y) : date) : date =
    let decr_day = (m, d - 1, y) in
    if is_valid decr_day then decr_day
    else if is_valid (m - 1, 31, y) then (m - 1, 31, y)
    else if is_valid (m - 1, 30, y) then (m - 1, 30, y)
    else if is_valid (m - 1, 29, y) then (m - 1, 29, y)
    else if is_valid (m - 1, 28, y) then (m - 1, 28, y)
    else (12, 31, y - 1)

  (** Get next date. *)
  let next ((m, d, y) : date) : date =
    let incr_day = (m, d + 1, y) in
    if is_valid incr_day then incr_day
    else
      let incr_month = (m + 1, 1, y) in
      if is_valid incr_month then incr_month else (1, 1, y + 1)

  (** Holiday type. *)
  type holiday =
    | Fixed of int * int (* m,d *)
    | Floating of int * int * int (* m,d,# *)

  (** Days that NASDAQ and NYSE are closed, excluding Good Friday. *)
  let holidays =
    [
      ("New Years Day", Fixed (1, 1));
      ("Martin Luther King Day", Floating (1, 0, 3));
      ("Presidents Day", Floating (2, 0, 3));
      ("Memorial Day", Floating (5, 0, 5));
      ("Juneteenth", Fixed (6, 19));
      ("Independence Day", Fixed (7, 4));
      ("Labor Day", Floating (9, 0, 1));
      ("Thanksgiving", Floating (11, 3, 4));
      ("Christmas Day", Fixed (12, 25));
    ]

  (** [easter yr] returns the year of Easter during [yr], according to Gauss's
      Easter algorithm. *)
  let easter yr =
    let a = yr mod 19 in
    let b = yr mod 4 in
    let c = yr mod 7 in
    let p = yr / 100 in
    let q = (13 + (8 * p)) / 25 in
    let m = (15 - q + p - (p / 4)) mod 30 in
    let n = (4 + p - (p / 4)) mod 7 in
    let d = ((19 * a) + m) mod 30 in
    let e = (n + (2 * b) + (4 * c) + (6 * d)) mod 7 in
    let days = 22 + d + e in
    if d = 29 && e = 6 then (04, 19, yr)
    else if d = 28 && e = 6 then (04, 18, yr)
    else if days > 31 then (04, days - 31, yr)
    else (03, days, yr)

  (** [calc_holiday yr (h_name, holiday)] returns a pair [(h_name, holidate)]
      where [holidate] is the exact date that a certain holiday during a
      provided [yr].*)
  let calc_holiday yr = function
    | s, Fixed (m, d) -> (s, (m, d, yr))
    | s, Floating (m, day_of_week, nth) ->
        let day_of_first = dow (m, 1, yr) in
        let first = 1 + ((day_of_week - day_of_first + 7) mod 7) in
        let day = first + (7 * (nth - 1)) in
        if is_valid (m, day, yr) then (s, (m, day, yr))
        else (s, (m, day - 7, yr))

  (** [holiday_list yr] returns the list of stock-market recognized holidays in
      format [("holiday name", date)]. List is sorted from earliest to latest.
      Requires valid [yr] input. *)
  let holiday_list yr : (string * date) list =
    let hlist = List.map (calc_holiday yr) holidays in
    let hlist_unsorted =
      ("Good Friday", easter yr |> prev |> prev)
      :: hlist (* Easter is never observed, but Good Friday is. *)
    in
    List.sort (fun (_, a) (_, b) -> compare a b) hlist_unsorted

  (** Return date of next business date. *)
  let rec next_business ?(offset = 1) ((m, d, y) as time : date) : date =
    let observation_date = function
      | _, ((mm, dd, yyyy) as dte) ->
          let dw = dow dte in
          if dw = 5 then prev dte else if dw = 6 then next dte else dte
    in
    let days_off =
      List.map observation_date (holiday_list y @ holiday_list (y + 1))
    in
    let candidate =
      if dow time = 4 then time |> next |> next |> next
      else if dow time = 5 then time |> next |> next
      else if dow time = 6 then time |> next
      else time |> next
    in
    if List.mem candidate days_off then next_business ~offset candidate
    else if offset = 1 then candidate
    else next_business ~offset:(offset - 1) candidate

  let of_string (inp : string) : date =
    let splitted = String.split_on_char '-' inp in
    match splitted with
    | [ m; d; y ] ->
        let pot = (int_of_string m, int_of_string d, int_of_string y) in
        if is_valid pot then pot else raise InvalidDate
    | _ -> invalid_arg "Wrong date format"
end
(* of Date.ml *)
