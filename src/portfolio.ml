(* Portfolio.ml - Intended to store portfolio data *)

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

  val opt_to_string : opt -> string
  (** [opt_to_string option] prints a readable string of [option]. *)

  val opt_of_string : string -> opt
  (** [opt_of_string str] returns [opt] based on the input [str]. *)

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

module Portfolio : PortfolioType = struct
  type opt =
    | Buy
    | Sell

  type transaction = {
    ticker : string;
    option : opt;
    price : float;
    quantity : float;
    time : date;
  }

  type t = {
    balance : float;
    stock_holding : float;
    bank_accounts : int list;
    followed_stocks : Stock.t list;
    history : transaction list;
  }

  exception Out_of_balance of string

  (** [opt_to_string option] prints a readable string of [option]. *)
  let opt_to_string x =
    match x with
    | Buy -> "buy"
    | Sell -> "sell"

  (** [opt_of_string str] returns [opt] based on the input [str]. *)
  let opt_of_string str =
    match str with
    | "buy" -> Buy
    | "sell" -> Sell
    | _ -> raise (Invalid_argument "Input not defined.")

  (** [new_portfolio ()] creates a new portfolio with initialized fields.*)
  let new_portfolio () =
    {
      balance = 0.0;
      stock_holding = 0.0;
      bank_accounts = [];
      followed_stocks = [];
      history = [];
    }

  (** [new_transaction stock option quantity time] creates a new transaction
      record with the given parameters.*)
  let new_transaction stock option quantity time : transaction =
    {
      ticker = Stock.ticker stock;
      option;
      price = Stock.price stock;
      quantity;
      time;
    }

  (** [get_balance portfolio] returns current [balance] of [portfolio]. *)
  let get_balance p = p.balance

  (** [get_stock_holdings portfolio] returns [stock_holding] of [portfolio]. *)
  let get_stock_holdings p = p.stock_holding

  (** [get_bank_accounts portfolio] returns [bank_accounts] of [portfolio]. *)
  let get_bank_accounts p = p.bank_accounts

  (** [get_followed_stocks portfolio] returns [followed_stocks] of [portfolio]. *)
  let get_followed_stocks p = p.followed_stocks

  (** [get_history portfolio] returns [followed_stocks] of [portfolio]. *)
  let get_history p = p.history

  (** Returns a human-readable string of information of a portfolio*)
  let to_string p =
    "\n" ^ " Balance: "
    ^ string_of_float (get_balance p)
    ^ "\n" ^ " Stock Holding: "
    ^ string_of_float (get_stock_holdings p)
    ^ "\n" ^ " Bank accounts: "
    ^ List.fold_left
        (fun a b -> a ^ string_of_int b ^ "; ")
        "" (get_bank_accounts p)
    ^ "\n" ^ " Followed Stocks: "
    ^ List.fold_left
        (fun a b -> a ^ Stock.name b ^ "; ")
        "" (get_followed_stocks p)
    ^ "\n"

  (** Add [stock] to the watchlist of the portfolio. Requires [stock] not in the
      watchlist. *)
  let follow stock p = { p with followed_stocks = stock :: p.followed_stocks }

  (** Remove a stock from the watchlist. Requires [stock] in the watchlist. *)
  let unfollow stock p =
    let updated = List.filter (fun x -> x <> stock) p.followed_stocks in
    { p with followed_stocks = updated }

  (** [update_balance portfolio amount] updates [balance] of [portfolio] by
      [amount]. If the updated balance is negative, it raises [Out_of_balance]
      exception. *)
  let update_balance amount p =
    if p.balance +. amount >= 0.0 then { p with balance = p.balance +. amount }
    else
      raise
        (Out_of_balance
           ("Out of balance: still need "
           ^ string_of_float (0.0 -. p.balance -. amount)))

  (** [update_stock_holding amount portfolio] updates [stock_holding] by
      [amount]. Private method.*)
  let update_stock_holding amount p =
    let updated = p.stock_holding +. amount in
    { p with stock_holding = updated }

  (** [add_bank_account bank_account portfolio] adds [bank_account] to the
      [portfolio]. *)
  let add_bank_account x p =
    let updated = x :: p.bank_accounts in
    { p with bank_accounts = updated }

  (** [update_history transaction portfolio] adds a transaction to the
      transaction history. [buy] is 1 if it is buy and 0 if it is sell. [amount]
      indicates the amount traded, [price] is the price when traded. *)
  let update_history transaction p =
    let updated = transaction :: p.history in
    { p with history = updated }

  (** [stock_transaction option stock quantity portfolio] trades [quantity]
      amount of [stock] by the type of option [option].*)
  let stock_transact option stock quantity p =
    let record = new_transaction stock option quantity (11, 11, 2023) in
    let amount = Stock.price stock *. quantity in
    match option with
    | Buy ->
        update_history record
          (update_stock_holding amount (update_balance (-1. *. amount) p))
    | Sell ->
        update_history record
          (update_stock_holding (-1. *. amount) (update_balance amount p))
end
