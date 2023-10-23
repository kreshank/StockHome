(* Portfolio.ml - Intended to store portfolio data *)

open Stock
open Date

module type PortfolioType = sig
  type t

  val to_string : t -> string
  (* Returns a human-readable string of information of a portfolio*)

  val create_portfolio : int -> t
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

  val add_history : t -> Stock.t -> bool -> float -> float -> date -> t
  (** [add_history portfolio stock buy amount price date] adds a transaction to
      the transaction history. [buy] is 1 if it is buy and 0 if it is sell.
      [amount] indicates the amount traded, [price] is the price when traded. *)
end

module Portfolio : PortfolioType = struct
  type t = {
    balance : float;
    bank_account : int;
    followed_stocks : Stock.t list;
    transaction_history : int list;
  }

  (* Returns a human-readable string of information of a portfolio*)
  let to_string portfolio =
    "\n" ^ "Balance: "
    ^ string_of_float portfolio.balance
    ^ ". Bank account: "
    ^ string_of_int portfolio.bank_account
    ^ ". Followed Stocks: "
    ^ List.fold_left
        (fun a b -> a ^ " " ^ Stock.name b)
        " " portfolio.followed_stocks
    ^ List.fold_left
        (fun a b -> a ^ Stock.to_string_detailed b)
        " " portfolio.followed_stocks

  (** Create a portfolio with [initial_balance] and [initial_bank_account]*)
  let create_portfolio initial_bank_account =
    {
      balance = 0.0;
      bank_account = initial_bank_account;
      followed_stocks = [];
      transaction_history = [];
    }

  (** Add [stock] to the watchlist of the portfolio*)
  let add_stock portfolio stock =
    { portfolio with followed_stocks = stock :: portfolio.followed_stocks }

  (** Update balance by [amount]. Print out a message to indicate the updated
      balance. If [amount] is negative and its absolute value exceeds current
      balance, produce a message "Out of balance: [balance + amount] needed"*)
  let update_balance portfolio amount =
    if portfolio.balance +. amount >= 0.0 then (
      print_string
        ("Balance updated: " ^ string_of_float (portfolio.balance +. amount));
      { portfolio with balance = portfolio.balance +. amount })
    else (
      print_string
        ("Still need: " ^ string_of_float (0.0 -. portfolio.balance -. amount));
      portfolio)

  (** Update the current bank account. *)
  let update_bank_account portfolio x = { portfolio with bank_account = x }

  (** Remove a stock from the watchlist. Required: the stock is in the
      watchlist. *)
  let remove_stock portfolio stock =
    let updated_stocks =
      List.filter (fun x -> x <> stock) portfolio.followed_stocks
    in
    { portfolio with followed_stocks = updated_stocks }

  (** [add_history portfolio stock buy amount price date] adds a transaction to
      the transaction history. [buy] is 1 if it is buy and 0 if it is sell.
      [amount] indicates the amount traded, [price] is the price when traded. *)
  let add_history portfolio stock buy amount price data =
    failwith "Unimplemented"
end
