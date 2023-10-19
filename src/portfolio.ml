(* Portfolio.ml - Intended to store portfolio data *)
type stock = {
  symbol : string;
  price : float;
  quantity : int;
}

type portfolio = {
  balance : float;
  bank_account : int;
  followed_stocks : stock list;
}

(** Create a portfolio with [initial_balance] and [initial_bank_account]*)
let create_portfolio initial_balance initial_bank_account =
  failwith "Unimplemented"

(** Add [stock] to the watchlist of the portfolio*)
let add_stock portfolio stock = failwith "Unimplemented"

(** Update balance by [amount]. Print out a message to indicate the updated
    balance. If [amount] is negative and its absolute value exceeds current
    balance, produce a message "Out of balance: [balance + amount] needed"*)
let update_balance portfolio amount = failwith "Unimplemented"

(** Update the current bank account. *)
let update_bant_account portfolio x = failwith "Unimplemented"

(** Remove a stock from the watchlist. Required: the stock is in the watchlist. *)
let remove_stock portfolio symbol = failwith "Unimplemented"
