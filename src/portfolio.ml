(** Portfolio.ml - Module that stores stock data as well as any other forms of
    information relevant to the user *)

open Stock
open Date
open Unix

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

  val get_bought_stocks : t -> (string * float) list
  (** [get_bought_stocks portfolio] returns [bought_stocks] of [portfolio]. *)

  val get_history : t -> transaction list
  (** [get_history portfolio] returns [followed_stocks] of [portfolio]. *)

  val to_string : t -> string
  (** Returns a human-readable string of information of a portfolio*)

  val stock_detail : t -> string
  (** Returns a human-readable string of information of the stocks of a
      portfolio*)

  val follow : string -> t -> t * Stock.t
  (** [follow tkr p] returns [(new_port, stock)]. Searches follow list for
      [tkr]. If [stock] corresponding to [ticker] is already in the follow list,
      will simply update the entry with most recent informatino. If [stock]
      isn't in follow list, will generate and insert in follow list. *)

  val follow_lazy : Stock.t -> t -> t
  (**Follows the ticker without updating the stock with current information.
     Used to make save/write faster*)

  val update_stocks : t -> t * float list
  (** [update_stocks portfolio] returns a pair of
      [(updated_portfolio, delta_price)]. Updates portfolio and logs changes
      between new states of each [stock] and old state of each [stock]. *)

  val isempty : t -> bool
  (**Checks if a portfolio is empty.*)

  val unfollow : Stock.t -> t -> t
  (** Remove a stock from the watchlist. Required: the stock is in the
      watchlist. *)

  val update_balance : float -> t -> t
  (** [update_balance amount portfolio] updates [balance] of [portfolio] by
      [amount]. If the updated balance is negative, it raises [Out_of_balance]
      exception. *)

  val update_stock_holding : float -> t -> t
  (** [update_stock_holding amount portfolio] updates [stock_holding] by
      [amount].*)

  val add_bank_account : int -> t -> t
  (** [add_bank_account bank_account portfolio] adds [bank_account] to the
      [portfolio]. *)

  val update_bought_stocks : string -> float -> t -> t
  (** [update_bought_stocks ticker quantity portfolio] updates [bought_stocks].
      If [ticker] is not in [bought_stocks], it will be added into the list. If
      [ticker] is already in [bought_stocks], its [quantity] will change
      accordingly. The updated [quantity] should always be not less than 0, and
      the list is sorted based off [ticker].*)

  val update_history : transaction -> t -> t
  (** [add_history stock buy amount price date portfolio] adds a transaction to
      the transaction history. [buy] is 1 if it is buy and 0 if it is sell.
      [amount] indicates the amount traded, [price] is the price when traded. *)

  val stock_transact : opt -> Stock.t -> float -> t -> t
  (** [stock_transaction option stock quantity portfolio] trades [quantity]
      amount of [stock] by the type of option [option]. Raises error if: the
      portfolio is out of balance, or out of stock holdings*)

  val ticker_transact : string -> string -> string -> t -> t
  (** [ticker_transact opt_str ticker quantity portfolio] trades [quantity]
      amount of [stock] of ticker [ticker] by the type of option [opt_str].
      Requires: no input should be empty. *)
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
    bought_stocks : (string * float) list;
    followed_stocks : Stock.t list;
    history : transaction list;
  }
  (** We enforce that followed_stocks is always sorted by ticker. *)

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
    | _ -> raise (Invalid_argument "Option should only be buy/sell")

  (** [new_portfolio ()] creates a new portfolio with initialized fields.*)
  let new_portfolio () =
    {
      balance = 0.0;
      stock_holding = 0.0;
      bank_accounts = [];
      bought_stocks = [];
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

  (** [get_bought_stocks portfolio] returns [bought_stocks] of [portfolio]. *)
  let get_bought_stocks p = p.bought_stocks

  (** [get_history portfolio] returns [followed_stocks] of [portfolio]. *)
  let get_history p = p.history

  (** Returns a human-readable string of information of a portfolio*)
  let to_string p =
    " Balance: "
    ^ string_of_float (get_balance p)
    ^ "\n" ^ " Stock holding: "
    ^ string_of_float (get_stock_holdings p)
    ^ "\n" ^ " Bank accounts: "
    ^ List.fold_left
        (fun a b -> a ^ string_of_int b ^ "; ")
        "" (get_bank_accounts p)
    ^ "\n" ^ " Stocks bought: "
    ^ List.fold_left
        (fun c (a, b) -> c ^ a ^ ": " ^ string_of_float b ^ "; ")
        "" (get_bought_stocks p)
    ^ "\n" ^ " Followed stocks: "
    ^ List.fold_left
        (fun a b -> if a = "" then Stock.name b else Stock.name b ^ ", " ^ a)
        "" (get_followed_stocks p)
    ^ "\n"

  (** Returns a human-readable string of information of a portfolio*)
  let stock_detail p =
    List.fold_left
      (fun acc x ->
        if acc = "" then Stock.to_string x else Stock.to_string x ^ "\n" ^ acc)
      "" (get_followed_stocks p)
    ^ "\n"

  (** [follow tkr p] returns [(follow_list, stock)]. Searches follow list for
      [tkr]. If [stock] corresponding to [ticker] is already in the follow list,
      will simply update the entry with most recent information. If [stock]
      isn't in follow list, will generate and insert in follow list. *)
  let follow tkr p =
    let rec new_watch followed_stocks =
      match followed_stocks with
      | [] ->
          let inserted = Stock.make tkr in
          ([ inserted ], inserted)
      | h :: t ->
          let cmp = String.compare (Stock.ticker h) tkr in

          if cmp = 0 then
            let inserted = Stock.update h in
            (inserted :: t, inserted)
          else if cmp > 0 then
            let res = new_watch t in
            (h :: fst res, snd res)
          else
            let inserted = Stock.make tkr in
            (inserted :: h :: t, inserted)
    in
    let followed_stocks, inserted = new_watch p.followed_stocks in
    ({ p with followed_stocks }, inserted)

  (**Follows the ticker without updating the stock with current information.
     Used to make save/write faster*)
  let follow_lazy tkr p =
    { p with followed_stocks = p.followed_stocks @ [ tkr ] }

  (** [update_stocks portfolio] returns a pair of
      [(updated_portfolio, delta_price)]. Updates portfolio and logs changes
      between new states of each [stock] and old state of each [stock]. *)
  let update_stocks p =
    let stocks = p.followed_stocks in
    let generate (oldport, diff) x =
      let newport, upd_stock = follow (Stock.ticker x) oldport in
      (newport, (Stock.price upd_stock -. Stock.price x) :: diff)
    in
    let new_p, diff_list = List.fold_left generate (p, []) stocks in
    (new_p, List.rev diff_list)

  (**Checks if a portfolio is empty.*)
  let isempty p = p.followed_stocks = []

  (** Remove a stock from the watchlist. Requires [stock] in the watchlist. *)
  let unfollow stock p =
    let updated = List.filter (fun x -> x <> stock) p.followed_stocks in
    { p with followed_stocks = updated }

  (** [update_balance portfolio amount] updates [balance] of [portfolio] by
      [amount]. If the updated balance is negative, it raises [Out_of_balance]
      exception. *)
  let update_balance amount p =
    if p.balance +. amount >= 0.0 then { p with balance = p.balance +. amount }
    else raise (Out_of_balance "Out of balance.")

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

  (** [update_bought_stocks ticker quantity portfolio] updates [bought_stocks].
      If [ticker] is not in [bought_stocks], it will be added sinto the list,
      and the list will sort based off [ticker]. If [ticker] is already in
      [bought_stocks], its [quantity] will change accordingly, but it cannot be
      less than 0. Requires: [ticker] must be all caps.*)
  let update_bought_stocks ticker quantity p =
    let bought_stocks = get_bought_stocks p in
    match List.assoc_opt ticker bought_stocks with
    | Some old_quantity ->
        let new_quantity = old_quantity +. quantity in
        if new_quantity < 0.0 then
          invalid_arg "You tried to sell more stocks than you currently own."
        else
          let updated_stocks =
            List.map
              (fun (k, v) -> if k = ticker then (k, new_quantity) else (k, v))
              bought_stocks
          in
          { p with bought_stocks = updated_stocks }
    | None ->
        let new_quantity = quantity in
        if new_quantity < 0.0 then
          invalid_arg "You tried to sell more stocks than you currently own."
        else
          let new_stocks = (ticker, new_quantity) :: bought_stocks in
          let sorted_stocks =
            List.sort (fun (k1, _) (k2, _) -> String.compare k1 k2) new_stocks
          in
          { p with bought_stocks = sorted_stocks }

  (** [update_history transaction portfolio] adds a transaction to the
      transaction history. [buy] is 1 if it is buy and 0 if it is sell. [amount]
      indicates the amount traded, [price] is the price when traded. *)
  let update_history transaction p =
    let updated = transaction :: p.history in
    { p with history = updated }

  (* [get_current_date ()] returns the system date in format (MM, DD, YYYY)*)
  let get_current_date () =
    let current_time = time () in
    let tm = localtime current_time in
    let month =
      tm.tm_mon + 1 (* Adding 1 to match conventional month numbers *)
    in
    let day = tm.tm_mday in
    let year = tm.tm_year + 1900 (* Year is the number of years since 1900 *) in
    (month, day, year)

  (** [stock_transact option stock quantity portfolio] trades [quantity] amount
      of [stock] by the type of option [option].*)
  let stock_transact option stock quantity p =
    let record = new_transaction stock option quantity (get_current_date ()) in
    let amount = Stock.price stock *. quantity in
    match option with
    | Buy ->
        p
        |> update_balance (-1. *. amount)
        |> update_bought_stocks (Stock.ticker stock) quantity
        |> update_stock_holding amount
        |> update_history record
    | Sell ->
        p |> update_balance amount
        |> update_bought_stocks (Stock.ticker stock) (-1. *. quantity)
        |> update_stock_holding (-1. *. amount)
        |> update_history record

  (** [ticker_transact opt_str ticker quantity portfolio] trades [quantity]
      amount of [stock] of ticker [ticker] by the type of option [opt_str].
      Requires: no input should be empty. *)
  let ticker_transact opt_str ticker quantity p =
    if opt_str = "" || ticker = "" || quantity = "" then
      raise (Invalid_argument "Input should not be empty.");
    let stock = Stock.make ticker in
    let opt = opt_of_string (String.lowercase_ascii opt_str) in
    (* ^ changed*)
    let amt = float_of_string quantity in
    stock_transact opt stock amt p
end
