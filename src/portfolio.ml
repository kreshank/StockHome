(* Portfolio.ml - Intended to store portfolio data *)

open Stock

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
end

module Portfolio : PortfolioType = struct
  type t = {
    balance : float;
    bank_account : int;
    followed_stocks : Stock.t list;
  }

  (* Returns a human-readable string of information of a portfolio*)
  let of_string portfolio =
    "Balance: "
    ^ string_of_float portfolio.balance
    ^ ". Bank account: "
    ^ string_of_int portfolio.bank_account

  (** Create a portfolio with [initial_balance] and [initial_bank_account]*)
  let create_portfolio initial_balance initial_bank_account =
    {
      balance = initial_balance;
      bank_account = initial_bank_account;
      followed_stocks = [];
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
end
