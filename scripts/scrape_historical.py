import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

import argparse
import yahoo_fin.stock_info as yf
import pandas as pd
from datetime import date
import time
import os

# Process command line args
parser = argparse.ArgumentParser("Historical Data Scraper")
parser.add_argument("tickers", metavar = "N", nargs="*", help="list of tickers")
args = parser.parse_args()


start = time.time()

# Each ticker gets own file and folder
today = date.today().strftime("%m-%d-%Y")
for ticker in args.tickers:
  prefix = "data/stock_info/" + ticker
  if not os.path.exists(prefix):
    os.makedirs(prefix)
  frame = yf.get_data(ticker, "01-01-1970", today)
  frame.to_csv(prefix + "/" + ticker + "_hist.csv")


end = time.time()

# Time sanity check
label = "\n\n[Historical] Time to read in " + str((args.tickers)) + " tickers: "
time_of_execution = str(end - start)

print (label + time_of_execution)