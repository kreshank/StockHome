import argparse
import yahoo_fin.stock_info as yf
import time
import datetime
import os

# Process command line args
parser = argparse.ArgumentParser("Stats Valuation Scraper")
parser.add_argument("ticker", metavar = "T", nargs=1, help="input ticker")
args = parser.parse_args()


start = time.time()

# Each ticker gets own file and folder

tkr = args.ticker[0]
prefix = "data/stock_info/" + tkr
if not os.path.exists(prefix):
  os.makedirs(prefix)

frame = yf.get_stats_valuation(tkr)

column_header = list(frame.columns)
column_header[0] = "Date"
column_header[1] = column_header[1][12:22]

frame = frame.rename(columns=dict(zip(list(frame.columns), column_header)))

frame.transpose().to_csv(prefix + "/" + tkr + "_stats_val.csv")

end = time.time()

# Time sanity check
label = "\n\n[Current] Time to read and write: "
time_of_execution = str(end - start)

print (label + time_of_execution)