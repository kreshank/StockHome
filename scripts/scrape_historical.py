import argparse
import yahoo_fin.stock_info as yf
import pandas as pd
from datetime import date
import time

# Process command line args
parser = argparse.ArgumentParser("Test script")
parser.add_argument("tickers", metavar = "N", nargs="*", help="list of tickers")
args = parser.parse_args()


start = time.time()

# Each ticker gets own file
today = date.today().strftime("%m-%d-%Y")
for ticker in args.tickers:
  frame = (yf.get_data(ticker, "01-01-1970", today))
  frame.to_csv("data/temp/" + ticker + "_hist.csv")


end = time.time()

# Time sanity check
label = "\n\nTime to read in " + str(len(args.tickers)) + " tickers: "
time_of_execution = str(end - start)

print (label + time_of_execution)