#!/usr/bin/python2.7
from glob import glob
import sys
from os import system, path
from time import clock

lib_name = sys.argv[1]
fname = sys.argv[2]
adapt_f = sys.argv[3]
max_err_trim  = sys.argv[4]
max_err_quant = sys.argv[5]
print >> sys.stderr, "running ", path.basename(lib_name), path.basename(fname)
stat_name = fname.replace(".fastq.gz", ".stat.txt").replace('.fastq','.stat.txt')
agg_name = fname.replace(".fastq.gz", ".agg").replace('.fastq','.agg')
oup_name = fname.replace(".fastq.gz", ".out").replace('.fastq','.out')
 
if system("time ./bin/trimSeq.py {0} {1} {2} {3} {4} 24".format(fname, stat_name, agg_name, adapt_f, max_err_trim)) !=0:
  sys.exit(1)
print >> sys.stderr, "running bitap-align"
if system("time ./bin/bitap-align {0} {1} {2} {3}".format(agg_name, lib_name, oup_name, max_err_quant)) != 0:
  sys.exit(1)
print >> sys.stderr, "finished"
