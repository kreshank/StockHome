(* Portfolio.mli - Intended to store portfolio data *)

(* Message to who's making stock.ml: This should be from the stock module but
   I'll just leave it here since stock is not implemented yet*)

open Stock
open Date

module type PortfolioType = sig
  type t

  val of_string : t -> string
  (* Returns a human-readable string of information of a portfolio*)

  val create_portfolio : float -> int -> t
  (** Create a portfolio with [initial_balance] and [initial_bank_account]*)

  val add_stock : t -> Stock.t -> t
  (** Add [stock] to the watchlist of the portfolio*)

  val update_balance : t -> float -> t
  (** Update balance by [amount]. Print out a message to indicate the updated
      balance. If [amount] is negative and its absolute value exceeds current
      balance, produce a message "Out of balance: [balance + amount] needed"*)

  val update_bank_account : t -> int -> t
  (** Update the current bank account. *)

  val remove_stock : t -> Stock.t -> t
  (** Remove a stock from the watchlist. Required: the stock is in the
      watchlist. *)

  val add_history : t -> Stock.t -> bool -> float -> date -> t
end
