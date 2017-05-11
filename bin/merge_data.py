#!/usr/bin/python2
from glob import glob
from collections import Counter, defaultdict
import errno
import os
def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

groups = defaultdict( str )
sample = defaultdict( str )
reps = defaultdict(int)
with open('data/label.txt', 'r') as inp:
    for line in inp:
        k, v1, v2 = line.strip().split()
        sample_id = v1 + v2
        sample[sample_id] = k
        groups[sample_id] = v1
        reps[sample_id] = v2
tot_reads = defaultdict(int)
trim_reads = defaultdict(int)
map_reads = defaultdict(int)
counts = defaultdict( Counter )

libs = None
for agg_fname in glob("reads/*.agg"):
    out_fname = agg_fname.replace(".agg",".out")
    stat_fname = agg_fname.replace(".agg",".stat.txt")
    prefix = agg_fname.replace("reads/","").replace(".agg","")
    with open(out_fname, "r") as inp:
        tmp = [(x.split()[0],int(x.split()[-1])) for x in inp.read().strip().split('\n')]
        counts[prefix] += Counter(dict(tmp))

        if libs is None:
            libs = [i[0] for i in tmp][:-1]
        else:
            assert libs == [i[0] for i in tmp][:-1]
    with open(stat_fname, 'r') as inp:
        tot_reads[prefix] += int(inp.readline().strip().split()[-1])

    with open(agg_fname, 'r') as inp:
        trim_reads[prefix] += sum([int(x.strip().split()[-1]) for x in inp ])

for p in counts:
    map_reads[p] += counts[p]["Total:"]
    del counts[p]["Total:"]

mkdir_p("data")

with open("data/summary.txt", "w") as oup:
    print >> oup, ",".join(["sample.id", "group", "rep", "tot_reads", "trimmed_reads", \
            "mapped_reads"])
    for sid in sorted(sample):
        # print sample[sid]
        csid = sample[sid]
        print >> oup, ",".join( [ sid, groups[sid], str(reps[sid]) ] + \
                map(str,[tot_reads[csid], trim_reads[csid], map_reads[csid]]) )


with open("data/mapping.txt", "w") as oup:
    print >> oup, ",".join(["sRNA"]+sorted(sample))
    for s in libs:
        print >> oup, ",".join(map(str,[s]+[counts[c][s] for c in [ sample[i] for i in sorted(sample)]]))
