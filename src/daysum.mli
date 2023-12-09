open Date

(** DaySum is a module that contains the values from parsing a file
    [data/stock/ticker/ticker_cur.csv]. Contains a loader, to_string, and
    getters for all relevant values. *)

module type DaySumType = sig
  type t
  (** Representation type *)

  exception MalformedFile

  val load_from : string -> t
  (** [load_from file_addr] processes a file_addr into a day summary value.
      Requires the file to exist. Raises [MalformedFile] is file is in the
      incorrect format. *)

  val ticker : t -> string
  (** [ticker ds] returns the ticker val associated with [ds]. *)

  val timestamp : t -> date * time
  (** [timestamp ds] returns the timestamp and retrieval time of [ds] data. *)

  val targ_est_1y : t -> float option
  (** [targ_est_1y ds] returns Yahoo Finance's 1 year price estimate of the
      stock associated with [ds]. *)

  val week_range_52w : t -> float option * float option
  (** [week_range_52w ds] returns price range [(min, max)] over last 52 weeks of
      the stock associated with [ds]. *)

  val ask : t -> float option * int option
  (** [ask ds] returns the ask [(price, quantity)] where [price] is the lowest a
      stockholder is willing to sell this stock at a particular [quantity]. *)

  val avg_day_vol : t -> int option
  (** [avg_day_vol] returns the average day volume of the stock associated with
      [ds]. *)

  val beta_5y_mly : t -> float option
  (** [beta_5y_mly ds] returns the beta (5y monthly) of the stock associated
      with [ds]. *)

  val bid : t -> float option * int option
  (** [bid ds] returns the bid [(price, quantity)] where [price] is the highest
      a stockholder is willing to buy this stock at a particular [quantity]. *)

  val day_range : t -> float option * float option
  (** [day_range ds] returns the price range of this stock, over today
      [(min, max)]. *)

  val eps_ttm : t -> float option
  (** [eps_ttm ds] returns the Trailing Twelve Month earnings per share for this
      stock. *)

  val earnings_date : t -> date option * date option
  (** [earning_date] returns the earnings date [(start, end)] of this stock. *)

  val ex_date : t -> date option
  (** [ex_date ds] returns the ex-dividend date for the stock of this stock. *)

  val forward_div_yield : t -> float option * float option
  (** [forward_div_yield] returns the forward dividend and yield percentage in
      format [(dividend_price, yield)], where yield is in percentage. *)

  val market_cap : t -> float
  (** [market_cap ds] returns market cap of the stock. *)

  val open_price : t -> float
  (** [open_price ds] returns the open_price of this stock at time of retrieval. *)

  val pe_ratio_ttm : t -> float option
  (** [pe_ratio_ttm ds] returns the trailing twelve month PE ratio of the stock. *)

  val prev_close : t -> float
  (** [prev_close ds] returns the most recent closing price of this stock at
      time of retrieval. *)

  val quote_price : t -> float
  (** [quote_price ds] returns the quote price; the most recent price which the
      stock as been traded. *)

  val volume : t -> int
  (** [volume ds] returns current day trade volume. *)

  val to_string : t -> string
  (** [to_string ds] returns a string format of the data. *)
end

module DaySum : DaySumType
