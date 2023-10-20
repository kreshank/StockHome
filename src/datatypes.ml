(** Datatypes.ml - holds useful global definition of types. *)

type date = int * int * int
(*yr-month-day*)

let is_valid (d : date) : bool = failwith "Unimplemented"
let to_string (d : date) : string = failwith "Unimplemented"

let compare (d1 : date) (d2 : date) : int =
  match (d1, d2) with
  | (a1, _, _), (a2, _, _) -> (
      if a1 > a2 then 1
      else if a2 > a1 then -1
      else
        match (d1, d2) with
        | (_, b1, _), (_, b2, _) -> (
            if b1 > b2 then 1
            else if b2 > b1 then -1
            else
              match (d1, d2) with
              | (_, _, c1), (_, _, c2) ->
                  if c1 > c2 then 1 else if c2 > c1 then -1 else 0))
