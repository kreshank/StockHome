(** Scraper.ml, intended for web-scraping Yahoo Finance for stock information,
    and writing it into a file*)

open Date

module type ScraperType = sig
  type t
  (** Representation type. *)

  val lookup_stock : string -> t
  (** Search for more detailed information. *)

  val update : t -> t
  (** Return most recent data of a stock item. *)

  exception UnavailableTime

  val price : date option -> t -> float
  (** Return the price of a stock. Can enter an optional argument *)
end

(** Scrapes Yahoo Finance using yfinance or Yahoo_fin open source python
    libraries. *)
module YFScraper = struct
  type t = unit

  let lookup_stock (ticker : string) : t = failwith "Unimplemented"
  let update (stk : t) : t = failwith "Unimplemented"

  exception UnavailableTime

  let price (date : date option) (stk : t) : float = failwith "Unimplemented"
end
