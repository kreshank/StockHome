(* Portfolio.ml - Intended to store portfolio data *)
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
