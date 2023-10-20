(* Portfolio.mli - Intended to store portfolio data *)

open Stock
open Date

module type PortfolioType = sig
  type t

  val to_string : t -> string
  (* Returns a human-readable string of information of a portfolio*)

  val create_portfolio : int -> t
  (** Create a portfolio with [initial_bank_account].*)

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

  val add_history : t -> Stock.t -> bool -> float -> float -> date -> t
  (** [add_history portfolio stock buy amount price date] adds a transaction to
      the transaction history. [buy] is 1 if it is buy and 0 if it is sell.
      [amount] indicates the amount traded, [price] is the price when traded. *)
end

module Portfolio : PortfolioType
