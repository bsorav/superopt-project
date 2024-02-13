import sys

freq_dic = {}

def isint(x):
    x = x.strip()
    try:
        y = int(x)
    except ValueError:
        return False
    return True

def getint(x):
    x = x.strip()
    return int(x)

def subchunk_dag(lines, doprint, reg):
    n = len(lines)
    depends = []
    for i in range(n):
        l = lines[i]
        sp = l.find(' ')
        x = getint(l[:sp])
        assert(x == i + 1)
        bs = l.find('(')
        # print(l[:bs])
        # ignore the first argument of donotsimplify
        # basically shortens the critical paths
        if l.find("donotsimplify") != -1 and l.find("()") == -1:
            flag = True
            bsp = bs
            bs = l.find(',', bs)
            bs2 = l.find(')', bsp)
            if bs == -1:
                bs = bs2
            bs = min(bs, bs2)
            # print(l)
            # print(l[bsp+1:bs])
            pi = int(l[bsp+1:bs].strip())
        if bs == -1 or l.find("()") != -1:
            depends.append([])
            continue
        else:
            be = l.find(')', bs)
        if l[bs+1:be].strip() == "":
            vals = []
        else:
            vals = list(map(lambda x: int(x.strip())-1, l[bs+1:be].split(',')))
        depends.append(vals)
        
    traversed = [False for i in range(n)]
    st = n-1
    stack = [st]
    # setvals = set()
    cnt = 0
    if doprint:
        print(reg)
    while len(stack) != 0:
        x = stack[-1]
        stack.pop(-1)
        traversed[x] = True
        if doprint:
            print(lines[x])
        cnt += 1
        # setvals.add(x)
        for c in depends[x]:
            if not traversed[c]:
                stack.append(c)
    return cnt
        
def subchunk_critical_paths(lines, doprint, reg):
    n = len(lines)
    # depends = []
    levels = [0 for i in range(n)]
    tree = [i for i in range(n)]
    for i in range(n):
        # depends.append([])
        flag = False
        l = lines[i]
        sp = l.find(' ')
        x = getint(l[:sp])
        assert(x == i + 1)
        bs = l.find('(')
        # print(l[:bs])
        # ignore the first argument of donotsimplify
        # basically shortens the critical paths
        if l.find("donotsimplify") != -1:
            flag = True
            bsp = bs
            bs = l.find(',', bs)
            bs2 = l.find(')', bsp)
            if bs == -1:
                bs = bs2
            bs = min(bs, bs2)
            # print(l)
            # print(l[bsp+1:bs])
            pi = int(l[bsp+1:bs].strip())
        if bs == -1:
            continue
        else:
            be = l.find(')', bs)
        # print(l[bs+1:be])
        if l[bs+1:be].strip() == "":
            vals = []
        else:
            vals = list(map(lambda x: int(x.strip())-1, l[bs+1:be].split(',')))
        ls = list(map(lambda x: levels[x]+1, vals))
        if len(ls) == 0:
            levels[i] = 0
        else:
            levels[i] = max(ls)
            idx = ls.index(levels[i])
            tree[i] = vals[idx]
            if flag:
                levels[pi-1] = levels[i]
                tree[pi-1] = tree[i]

    # maybe add index here as well
    # ml = max(levels)
    # idx = levels.index(ml)
    idx = len(levels)-1
    if doprint:
        print("level", levels[-1], "reg:", reg)
        while tree[idx] != idx:
            print(lines[idx])
            idx = tree[idx]
        print(lines[idx])

    return levels[-1]

def chunk_critical_paths(s, doprint):
    lines = s.split('\n')
    count = 0
    cnts = []
    ln = 0
    pl = 0
    paths = []
    names = []
    # idxs = []
    for l in lines:
        sp = l.find(' ')
        if isint(l[:sp]):
            x = getint(l[:sp])
            if x == 1:
                pl = ln
        else:
            if pl != 0:
                ml = subchunk_dag(lines[pl:ln], doprint, lines[pl-1])
                paths.append(ml)
                names.append(lines[pl-1])
                # idxs.append(idx)
            pl = 0
        ln += 1
    mp = max(paths)
    idx = paths.index(mp)
    return mp, names[idx]

def parsechunk(s):
    lines = s.split('\n')
    count = 0
    cnts = []
    for l in lines:
        sp = l.find(' ')
        if isint(l[:sp]):
            count += 1
            if l.find("donotsimplify") != -1:
                cnts.append(count)
                count = 0
    if count != 0:
        cnts.append(count)

    cnts.sort()
    cnts.reverse()
    return cnts

if len(sys.argv) == 1:
    f = open("src_sym_exec_db").read()
else:
    f = open(sys.argv[1]).read()    

i1 = f.find("=insn")

idx = 0

mmax = 0

while i1 != -1:
    k = f.find(".i0", i1)
    l = f.find(" ", k+5)
    le = f.find("\n", k+5)
    insn = f[k+5:l]
    insnfull = f[k+5:le]
    i2 = f.find("=tfg", i1)
    i3 = f.find("=state_end", i2)
    chunk = f[i2:i3]
    mp, id1  = chunk_critical_paths(chunk, False)
    # cnts = parsechunk(chunk)
    if mp in freq_dic:
        freq_dic[mp].append((insn, id1))
    else:
        freq_dic[mp] = [(insn, id1)]
    mmax = max(mmax, mp)
    i1 = f.find("=insn", i3)

arr = []

for i in range(mmax+1):
    arr.append(set())
    if not i in freq_dic:
        continue
    for ins in freq_dic[i]:
        arr[i].add(ins)

for i in range(mmax+1):
    if (len(arr[i]) == 0):
        continue
    print(i, ":", arr[i])
    print()
