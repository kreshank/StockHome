(* Portfolio.mli - Intended to store portfolio data *)

(* Message to who's making stock.ml: This should be from the stock module but
   I'll just leave it here since stock is not implemented yet*)
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

val create_portfolio : float -> int -> portfolio
(** Create a portfolio with [initial_balance] and [initial_bank_account]*)

val add_stock : portfolio -> stock -> portfolio
(** Add [stock] to the watchlist of the portfolio*)

val update_balance : portfolio -> float -> portfolio
(** Update balance by [amount]. Print out a message to indicate the updated
    balance. If [amount] is negative and its absolute value exceeds current
    balance, produce a message "Out of balance: [balance + amount] needed"*)

val update_bant_account : portfolio -> int -> portfolio
(** Update the current bank account. *)

val remove_stock : portfolio -> string -> portfolio
(** Remove a stock from the watchlist. Required: the stock is in the watchlist. *)
