(** Datatypes.ml - holds useful global definition of types. *)

type date =
  | NumDate of int * int * int
  | StrDate of string * int * int

let is_valid (d : date) : bool = failwith "Unimplemented"
let to_string (d : date) : string = failwith "Unimplemented"
