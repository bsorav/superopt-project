import argparse
import matplotlib.pyplot as plt
import numpy as np

from common import read_csv_data, avg

plt.rcParams.update({'font.size': 13})

g_silent = False
g_dir = '.'

def keys_from_data(data):
    keys = filter(lambda k: data[k] != 0, data.keys())
    keys = sorted(keys, key=lambda k: data[k])
    return keys

def compute_bt_avg(keys, clang_fname, gcc_fname=None, icc_fname=None):
    clang_data = read_csv_data(clang_fname, val_col='num-backtrackings', skip_not_passing=True)
    gcc_data = read_csv_data(gcc_fname, val_col='num-backtrackings', skip_not_passing=True)
    icc_data = read_csv_data(icc_fname, val_col='num-backtrackings', skip_not_passing=True)
    clang_vals = [clang_data[k] for k in keys if k in clang_data]
    l = [ avg(clang_vals) ]
    if len(gcc_data):
        gcc_vals = [gcc_data[k] for k in keys if k in gcc_data]
        l.append(avg(gcc_vals))
    if len(icc_data):
        icc_vals = [icc_data[k] for k in keys if k in icc_data]
        l.append(avg(icc_vals))
    return avg(l)

def main_lt():
    clang_fname = g_dir + "/lt_clang.csv"
    gcc_fname =   g_dir + "/lt_gcc.csv"
    icc_fname =   g_dir + "/lt_icc.csv"

    clang_data = read_csv_data(clang_fname)
    gcc_data = read_csv_data(gcc_fname)
    icc_data = read_csv_data(icc_fname)

    assert len(clang_data) == len(gcc_data)
    assert len(clang_data) == len(icc_data)

    clang_data_s = read_csv_data(g_dir + "/lt_clang_s.csv")
    gcc_data_s =   read_csv_data(g_dir + "/lt_gcc_s.csv")
    icc_data_s =   read_csv_data(g_dir + "/lt_icc_s.csv")

    assert len(clang_data_s) == len(gcc_data_s)
    assert len(clang_data_s) == len(icc_data_s)

    assert len(clang_data) == len(clang_data_s)

    keys = keys_from_data(clang_data)
    
    clang_vals = [clang_data[k] for k in keys]
    gcc_vals   = [gcc_data[k]   for k in keys]
    icc_vals   = [icc_data[k]   for k in keys]

    clang_vals_s = [clang_data_s[k] for k in keys]
    gcc_vals_s   = [gcc_data_s[k]   for k in keys]
    icc_vals_s   = [icc_data_s[k]   for k in keys]

    factor_clang = [a/b for a,b in zip(clang_vals_s,clang_vals) if b != 0]
    factor_gcc = [a/b for a,b in zip(gcc_vals_s,gcc_vals) if b != 0]
    factor_icc = [a/b for a,b in zip(icc_vals_s,icc_vals) if b != 0]

    factor_clang_avg = sum(factor_clang)/len(factor_clang)
    factor_gcc_avg = sum(factor_gcc)/len(factor_gcc)
    factor_icc_avg = sum(factor_icc)/len(factor_icc)

    clang_passes = len(list(filter(lambda v: v != 0, clang_vals)))
    gcc_passes = len(list(filter(lambda v: v != 0, gcc_vals)))
    icc_passes = len(list(filter(lambda v: v != 0, icc_vals)))
    print("----------------------------------------------------")
    print("localmem-tests")
    print("----------------------------------------------------")
    print(f"N = {len(keys)}")
    print(f"clang passes = {clang_passes}")
    print(f"gcc passes = {gcc_passes}")
    print(f"icc passes = {icc_passes}")
    print(f"Total passes = {clang_passes+gcc_passes+icc_passes}")

    print(f"speed-up factor_clang_avg = {factor_clang_avg}")
    print(f"speed-up factor_gcc_avg = {factor_gcc_avg}")
    print(f"speed-up factor_icc_avg = {factor_icc_avg}")

    bt_avg = compute_bt_avg(keys, clang_fname, gcc_fname, icc_fname)
    print(f"bt average = {bt_avg}")
    print("----------------------------------------------------")
    print("")

    #print(f"clang_vals = {clang_vals}")
    #print(f"gcc_vals = {gcc_vals}")
    #print(f"icc_vals = {icc_vals}")

    fig, ax = plt.subplots()
    x = np.arange(len(keys))
    width = 0.25  # the width of the bars

    rects1 = ax.bar(x - width, clang_vals, width, log=True, label='CLANG')
    rects2 = ax.bar(x        , gcc_vals,   width, log=True, label='GCC')
    rects3 = ax.bar(x + width, icc_vals,   width, log=True, label='ICC')

    rects1_s = ax.bar(x - width, clang_vals_s, width, log=True, label='CLANG', fill=False)
    rects2_s = ax.bar(x        , gcc_vals_s,   width, log=True, label='GCC',   fill=False)
    rects3_s = ax.bar(x + width, icc_vals_s,   width, log=True, label='ICC',   fill=False)

    # Add some text for labels, title and custom x-axis tick labels, etc.
    ax.set_ylabel('EQ time in secs')
    yl, yh = ax.get_ylim()
    ax.set_ylim(1, yh)
    #ax.set_title('EQ times by benchmark and compiler')
    ax.set_xticks(x, keys, rotation=45)
    ax.legend(handles=[rects1,rects2,rects3])
    fig.tight_layout()
    plt.savefig("graph_lt.pdf", format='pdf')
    if not g_silent:
        plt.show()

def main_tsvc():
    clang_fname_locals =   g_dir + "/tsvc_l.csv"
    clang_fname_locals_s = g_dir + "/tsvc_l_s.csv"
    clang_fname_globals =  g_dir + "/tsvc_g.csv"
    clang_data =   read_csv_data(clang_fname_locals)
    clang_data_s = read_csv_data(clang_fname_locals_s)
    clang_data_g = read_csv_data(clang_fname_globals)

    keys = keys_from_data(clang_data)

    clang_vals = [clang_data[k] for k in keys]
    clang_vals_s = [clang_data_s[k] for k in keys]
    clang_vals_g = [clang_data_g[k] for k in keys]

    factor_g = [a/b for a,b in zip(clang_vals,clang_vals_g) if b != 0]
    factor_s = [a/b for a,b in zip(clang_vals_s,clang_vals) if b != 0]

    factor_g_avg = sum(factor_g)/len(factor_g)
    factor_s_avg = sum(factor_s)/len(factor_s)

    print("----------------------------------------------------")
    print("TSVC")
    print("----------------------------------------------------")
    print(f"N = {len(keys)}")
    print(f"speed-up factor_g_avg = {factor_g_avg}")
    print(f"speed-up factor_s_avg = {factor_s_avg}")

    bt_avg_locals = compute_bt_avg(keys, clang_fname_locals)
    print(f"bt average (locals) = {bt_avg_locals}")

    bt_avg_globals = compute_bt_avg(keys, clang_fname_globals)
    print(f"bt average (globals) = {bt_avg_globals}")
    #print(f"clang_vals = {clang_vals}")
    print("----------------------------------------------------")
    print("")

    fig, ax = plt.subplots()
    x = np.arange(len(keys))  # the label locations
    width = 0.30  # the width of the bars

    rects = ax.bar(x, clang_vals, width, log=True, label='with locals')
    rects_s = ax.bar(x, clang_vals_s, width, log=True, label='locals-slow-encoding', fill=False)
    rects_g = ax.bar(x + width, clang_vals_g, width, log=True, label='with globals')

    # Add some text for labels, title and custom x-axis tick labels, etc.
    ax.set_ylabel('EQ time in secs')
    yl, yh = ax.get_ylim()
    ax.set_ylim(1, yh)
    #ax.set_title('EQ times by benchmark and compiler')
    ax.set_xticks(x, keys, rotation=45)
    ax.legend(handles=[rects,rects_g])
    fig.tight_layout()
    plt.savefig("graph_tsvc.pdf", format='pdf')
    if not g_silent:
        plt.show()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--dir', default='superopt-tests', help = "Directory which contains the run .csv files")
    parser.add_argument('-s', '--silent', default=False, action='store_true', help = "Silent: Do not show plot in GUI")
    args = parser.parse_args()

    g_silent = args.silent
    g_dir = args.dir

    main_lt()
    main_tsvc()
