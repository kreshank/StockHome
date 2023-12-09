(** API.mli - Contains all code relevant to the API. *)

module type APIType = sig
  val historical : string list -> int
  (** [historical tickers] runs [scripts/scrape_historical.py] with arguments
      [tickers]. Writes data to file location:
      [data/stock_info/ticker/ticker_hist.csv]. Will create folder if they don't
      exist. *)

  val current : string -> int
  (** [current ticker] runs [scripts/scrape_current.py] with argument [ticker].
      This grabs the current data of the stock (with a timestamp) and writes to
      [data/stock_info/ticker/ticker_cur.csv]. Will create folders if they don't
      exist. *)

  val financials : string -> int
  (** __CURRENTLY, YAHOO_FIN API DOESN'T WORK FOR THIS. PLEASE DO NOT CALL__

      [financials ticker] runs [scripts/scrape_financials.py] with argument
      [ticker]. This grabs all the financial information. This is essentially a
      list of [balance_sheet ticker], [income_statement ticker], and
      [cash_flow ticker] put together. Data is written to
      [data/stock_info/ticker/ticker_finance.csv]. Will create folders as
      necessary. *)

  val balance_sheet : string -> int
  (** __CURRENTLY, YAHOO_FIN API DOESN'T WORK FOR THIS. PLEASE DO NOT CALL__

      [balance_sheet ticker] runs [scripts/scrape_balance.py] with argument
      [ticker]. This grabs the balance sheet data and writes to
      [data/stock_info/ticker/ticker_bal.csv]. Will create folders if they don't
      exist. *)

  val income : string -> int
  (** __CURRENTLY, YAHOO_FIN API DOESN'T WORK FOR THIS. PLEASE DO NOT CALL__

      [income ticker] runs [scripts/scrape_income.py] with argument [ticker].
      Writes incomes statement to [data/stock_info/ticker/ticker_income.csv].
      Will create folders if they don't exist. *)

  val cash_flow : string -> int
  (** __CURRENTLY, YAHOO_FIN API DOESN'T WORK FOR THIS. PLEASE DO NOT CALL__

      [cash_flow ticker] runs [scripts/scrape_cash.py] with argument [ticker].
      Writes cash flow information to [data/stock_info/ticker/ticker_cash.csv].
      Will create folders if they don't exist. *)

  val stats : string -> int
  (** [stats ticker] runs [scripts/scrape_stats.py] with argument [ticker]. This
      gathers data off the statistics page for the ticker and writes to a file
      [data/stcok_info/ticker/ticker_stats.csv]. Will create *)

  val stats_valuation : string -> int
  (** [stats_valuation ticker] runs [scripts/scrape_stats_val.py] with argument
      [ticker]. This gathers "valuation measure" data off the statistics page
      for the ticker and writes to a file. *)
end

module API : APIType
