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

module Date = struct
  exception InvalidDate

  let is_valid ((m, d, y) : date) : bool =
    let leap_offset yr =
      if yr mod 400 = 0 then 1
      else if yr mod 100 = 0 then 0
      else if yr mod 4 = 0 then 1
      else 0
    in
    if y < 0 then false
    else if m = 1 || m = 3 || m = 5 || m = 7 || m = 8 || m = 10 || m = 12 then
      1 <= d && d <= 31
    else if m = 4 || m = 6 || m = 9 || m = 11 then 1 <= d && d <= 30
    else if m = 2 then 1 <= d && d <= 28 + leap_offset y
    else false

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
