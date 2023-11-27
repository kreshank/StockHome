import argparse
import yahoo_fin.stock_info as yf
import pandas as pd
import datetime
import time
import os

# Process command line args
parser = argparse.ArgumentParser("Current Data Scraper")
parser.add_argument("ticker", metavar = "T", nargs=1, help="input ticker")
args = parser.parse_args()


start = time.time()

# Each ticker gets own file and folder

tkr = args.ticker[0]
prefix = "data/stock_info/" + tkr
if not os.path.exists(prefix):
  os.makedirs(prefix)

frame = yf.get_quote_table(tkr, False)
frame.loc[-1] = ["Timestamp", datetime.datetime.now().strftime("%m-%d-%Y, %H:%M:%S")]
frame.index = frame.index + 1
frame.sort_index(inplace = True)
frame.to_csv(prefix + "/" + tkr + "_cur.csv", index=False)

end = time.time()

# Time sanity check
label = "\n\n[Current] Time to read and write: "
time_of_execution = str(end - start)

print (label + time_of_execution)