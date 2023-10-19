(* Portfolio.ml - Intended to store portfolio data *)
type stock = { symbol : string; price : float; quantity : int }

type portfolio = {
  balance : float;
  bank_account : float;
  followed_stocks : stock list;
}

let create_portfolio initial_balance initial_bank_account =
  {
    balance = initial_balance;
    bank_account = initial_bank_account;
    followed_stocks = [];
  }

let add_stock portfolio symbol price quantity =
  let stock = { symbol; price; quantity } in
  { portfolio with followed_stocks = stock :: portfolio.followed_stocks }

let update_balance portfolio amount =
  if portfolio.balance +. amount >= 0.0 then (
    print_string
      ("Balance updated: " ^ string_of_float (portfolio.balance +. amount));
    { portfolio with balance = portfolio.balance +. amount })
  else (
    print_string
      ("Still need: " ^ string_of_float (0.0 -. portfolio.balance -. amount));
    portfolio)

let update_bank_account portfolio amount =
  { portfolio with bank_account = portfolio.bank_account +. amount }

let remove_stock portfolio symbol =
  let updated_stocks =
    List.filter (fun stock -> stock.symbol <> symbol) portfolio.followed_stocks
  in
  { portfolio with followed_stocks = updated_stocks }
