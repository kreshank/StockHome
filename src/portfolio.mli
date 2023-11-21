(* Portfolio.mli - Intended to store portfolio data *)

open Stock
open Date

module type PortfolioType = sig
  type t

  type opt =
    | Buy
    | Sell  (** Stock options . *)

  type transaction = {
    ticker : string;
    option : opt;
    price : float;
    quantity : float;
    time : date;
  }
  (** The type of a transaction. Includes formation (ticker, option, price,
      quantity, time). *)

  exception Out_of_balance of string
  (** [Out_of_balance] is raised when [portfolio] attempts to spend amount of
      money that is greater than its current balance. *)

  val new_portfolio : unit -> t
  (** [new_portfolio ()] creates a new portfolio with initialized fields.*)

  val get_balance : t -> float
  (** [get_balance portfolio] returns current [balance] of [portfolio]. *)

  val get_stock_holdings : t -> float
  (** [get_stock_holdings portfolio] returns [stock_holding] of [portfolio]. *)

  val get_bank_accounts : t -> int list
  (** [get_bank_accounts portfolio] returns [bank_accounts] of [portfolio]. *)

  val get_followed_stocks : t -> Stock.t list
  (** [get_followed_stocks portfolio] returns [followed_stocks] of [portfolio]. *)

  val get_history : t -> transaction list
  (** [get_history portfolio] returns [followed_stocks] of [portfolio]. *)

  val to_string : t -> string
  (** Returns a human-readable string of information of a portfolio*)

  val follow : Stock.t -> t -> t
  (** Add [stock] to the watchlist of the portfolio*)

  val unfollow : Stock.t -> t -> t
  (** Remove a stock from the watchlist. Required: the stock is in the
      watchlist. *)

  val update_balance : float -> t -> t
  (** [update_balance amount portfolio] updates [balance] of [portfolio] by
      [amount]. If the updated balance is negative, it raises [Out_of_balance]
      exception. *)

  val update_stock_holding : float -> t -> t
  (** [update_stock_holding amount portfolio] updates [stock_holding] by
      [amount]. Private method.*)

  val add_bank_account : int -> t -> t
  (** [add_bank_account bank_account portfolio] adds [bank_account] to the
      [portfolio]. *)

  val update_history : transaction -> t -> t
  (** [add_history stock buy amount price date portfolio] adds a transaction to
      the transaction history. [buy] is 1 if it is buy and 0 if it is sell.
      [amount] indicates the amount traded, [price] is the price when traded. *)

  val stock_transact : opt -> Stock.t -> float -> t -> t
  (** [stock_transaction option stock quantity portfolio] trades [quantity]
      amount of [stock] by the type of option [option]. *)
end

module Portfolio : PortfolioType
