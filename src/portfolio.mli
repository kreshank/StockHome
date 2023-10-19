(* Portfolio.mli - Intended to store portfolio data *)

(* This should be from the stockdata module but I'll just leave it here since
   sotckdata is not implemented yet*)
type stock = { symbol : string; price : float; quantity : int }

type portfolio = {
  balance : float;
  account : int;
  followed_stocks : stock list;
}

val create_portfolio : float -> int -> portfolio
(** Create a portfolio *)

val add_stock : portfolio -> stock -> portfolio
(** Add a stock to the watchlist of the portfolio*)

val update_balance : portfolio -> float -> portfolio
(** Update balance by [n] amount. Print out a message to indicate the updated
    balance. If [n] is negative and its absolute value exceeds current 
    balance, produce a message "Out of balance: [balance + n] needed"*)

val update_bant_account : portfolio -> int -> portfolio
(** Update the current bank account. *)

val remove_stock : portfolio -> stock -> portfolio
(** Remove a stock from the watchlist. *)
