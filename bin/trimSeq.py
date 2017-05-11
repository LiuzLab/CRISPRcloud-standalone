#!/usr/bin/python2.7
from cutadapt.seqio import Sequence
from cutadapt.adapters import Adapter, FRONT, BACK
from cutadapt.scripts.cutadapt import AdapterCutter
from collections import Counter
import sys
import gzip

def readFastq(inp=sys.stdin):
    i = 0
    for line in inp:
        if i & 4 == 0: read_id = line.strip()
        if i % 4 == 1: read_seq = line.strip()
        if i % 4 == 3: yield Sequence(read_id, read_seq)
        i += 1

def trim(sampleFileName, ADAPT_FRONT="GTGGAAAGGACGAAACACC", max_err=0.1, max_length=24):
    adapter_front = [Adapter(ADAPT_FRONT, FRONT, max_err)]
    cutter_front = AdapterCutter(adapter_front, times=1)

    if not sampleFileName.lower().endswith('gz'):
        with open(sampleFileName, "r") as inp:
            return [ cutter_front(read).sequence[:20] for lineno, read in enumerate(readFastq(inp)) ]
    else:
        with gzip.open(sampleFileName, "r") as inp:
            return [ (cutter_front(read)).sequence[:20] for lineno, read in enumerate(readFastq(inp)) ]

def main():
  inp_name, stat_name, agg_name, adapt_front, max_err, max_length = sys.argv[1:]
  max_err = float(max_err)
  max_length = int(max_length)

  print >> sys.stderr, "Trimming {0}...".format(inp_name)
  trimed_data = trim(inp_name, adapt_front, max_err, max_length )
  cnt_len = Counter(map(lambda x : len(x), trimed_data))

  with open(stat_name, "w") as oup:
    print >> oup, "Total: ", len(trimed_data)
    for k in sorted(cnt_len):
      print >> oup, k, cnt_len[k]

  aggregated_data = Counter(trimed_data)

  print >> sys.stderr, "Writing aggregated reads data to {0}".format(agg_name)
  with open(agg_name,"w") as oup:
    print >> oup, "\n".join(["{0} {1}".format(k,v) for k,v in aggregated_data.items() if 0<len(k)<max_length])

if __name__ == "__main__":
  main()
