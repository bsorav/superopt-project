import csv
import numpy as np
from collections import OrderedDict

def read_csv_data(fname, val_col='total-equiv-secs', skip_not_passing = False):
    if fname is None:
        return {}
    ret = {}
    name_col='name'
    with open(fname) as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            if row['eq-passed'] == '1':
                val = float(row[val_col])
            else:
                val = 0.0
                if skip_not_passing:
                    continue
            ret[row[name_col]] = val
    return ret

def zero_or_f(l, f):
    return f(l) if len(l) > 0 else 0

def avg(l):
    assert len(l) != 0
    return np.mean(l)

def std(l):
    assert len(l) != 0
    return np.std(l)

def read_data(fname, target_functions = None, only_passing = True):
    if fname is None:
        return []
    ret = []
    name_col='name'
    with open(fname) as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            if only_passing and row['eq-passed'] != '1':
                continue
            if target_functions is not None and row['name'] not in target_functions:
                continue

            entry = OrderedDict()
            entry['name'] = row['name']
            entry['passing'] = row['eq-passed'] == '1'
            entry['ALOC'] = row['dst-aloc']
            entry['# locals'] = row['src-allocation-stmts']
            entry['eqT'] = row['total-equiv-secs']
            entry['Nodes'] = row['cg-pcs']
            entry['Edges'] = row['cg-edges']
            entry['EXP'] = row['corrs-explored']
            entry['BT'] = row['num-backtrackings']
            entry['# q'] = row['num-smt-queries']
            entry['Avg. qT'] = row['avg-smt-query-time-secs']
            entry['Frac_q^i'] = 0 if int(row['num-smt-queries']) == 0 else round(int(row['num-smt-queries-interval'])/int(row['num-smt-queries']), 2)
            ret.append(entry)
    return ret

def gen_detailed_table(fname, target_functions=None, csv_name='tab_bzip2_short.csv'):
    if target_functions is not None:
        assert len(target_functions) > 0
    dl = read_data(fname, target_functions)
    assert len(dl) > 0
    hdr = dl[0].keys()
    with open(csv_name, 'w') as csvfile:
        tablewriter = csv.writer(csvfile)
        tablewriter.writerow(hdr) # header

        unpk = lambda d: [v for k,v in d.items()]
        for d in dl:
            tablewriter.writerow(unpk(d))
        return csv_name

def find_matching(l, n:str):
    for d in l:
        if d['name'] == n:
            return d
    else:
        return None

def latex_escape(s:str):
    return s.replace('_', '\\_')

def latex_tt(s:str):
    return "{\\tt "+latex_escape(s)+"}"

def gen_passing_latex_table(fnames):
    fdata = [read_data(f, None, False) for f in fnames]
    names = list(set(sum((list(map(lambda e: e['name'], fd)) for fd in fdata), [])))
    rows = {}
    for n in names:
        alocs = []
        times = []
        for d in fdata:
            matching_entry = find_matching(d, n)
            if matching_entry is None: # the run probably didn't finish, generate dummy value
                matching_entry = { 'ALOC': '0', 'passing': False }
            assert matching_entry is not None
            alocs.append(matching_entry['ALOC'] if matching_entry['ALOC'] != '0' else None)
            times.append(matching_entry['eqT'] if matching_entry['passing'] else None)
        rows[n] = (alocs, times)

    fname = 'tab_bzip2_full.tex'
    with open(fname, 'w') as fo:
        fo.write(" Name & \multicolumn{3}{c}{ALOC} & \multicolumn{3}{c}{Equivalence time (seconds)} \\\\\n")
        head = " & ".join(map(latex_tt, map(lambda s: s[6:-4], fnames)))
        fo.write(" & " + head + " & " + head + "\\\\\n")
        names = sorted(rows.keys())
        for name in names:
            aloc, time = rows[name]
            aloc_str = ' & '.join(map(lambda t: str(t) if t is not None else '-', aloc))
            times_str = ' & '.join(map(lambda t: str(round(float(t),1)) if t is not None else '\\xmark', time))
            fo.write(f"{latex_tt(name)}  & {aloc_str} & {times_str} \\\\\n")
        return fname

