module type APIType = sig
  val historical : string list -> int
  (** [historical tickers] runs [scripts/scrape_historical.py] with arguments
      [tickers]. Writes data to file location: [data/temp/ticker_hist.csv]. *)

  val current : string -> int
  (** [current ticker] runs [scripts/scrape_current.py] with argument [ticker].
      This grabs the current data of the stock (with a timestamp) and writes to
      [data/temp/ticker_cur.csv]. *)
end

module API = struct
  let historical (tickers : string list) =
    let unique = List.sort_uniq String.compare tickers in
    let lst_str =
      List.fold_left
        (fun acc b -> acc ^ " " ^ String.lowercase_ascii b)
        "" unique
    in
    Sys.command
      (Printf.sprintf "python3 scripts/scrape_historical.py %s" lst_str)

  let current (ticker : string) =
    Sys.command (Printf.sprintf "python3 scripts/scrape_current.py %s" ticker)
end
