(** API.mli - Any API information *)

module type APIType = sig
  val historical : string list -> int
  (** [historical tickers] runs [scripts/scrape_historical.py] with arguments
      [tickers]. Writes data to file location:
      [data/stock_info/ticker/ticker_hist.csv]. Will create a folder if doesn't
      exist. *)

  val current : string -> int
  (** [current ticker] runs [scripts/scrape_current.py] with argument [ticker].
      This grabs the current data of the stock (with a timestamp) and writes to
      [data/stock_info/ticker/ticker_cur.csv]. Will create a folder if doesn't
      exist. *)
end

module API : APIType
