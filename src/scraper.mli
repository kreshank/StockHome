(** Scraper.mli, intended for web-scraping and processing Yahoo Finance for
    stock information *)

open Datatypes
open Stock

(** The signature of a web-scraper that looks-up information *)
module type ScraperType = sig
  type t
  (** Representation type. *)

  val lookup_stock : string -> t
  (** Search for more detailed information. *)

  val update : t -> t
  (** Return most recent data of a stock item. *)

  exception UnavailableTime

  val price : date option -> t -> float
  (** Return the price of a stock. Can enter an optional argument, if it's None,
      return current price, if Some s, then we attempt to search for the price
      on that date. Raises exception UnavailableTime, if in future or stock
      didn't exist. *)
end

module YFScraper : ScraperType
