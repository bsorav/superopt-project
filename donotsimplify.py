
# vals = [("subsign", 3),
#         ("suboverflow", 3),
#         ("subzero", 3)]

# three types of comments
# comments like carry, adjust, direction, add, sub, and etc are 0 argument comments
# primary operation comments like oper2, oper3, etc can be replaced by their first argument
# in the vir we will ignore their first argument (not recurse on it)

flags = ["carry",
         "adjust",
         "direction",
         "overflow",
         "sign",
         "zero",
         "parity",
         "eq",
         "ne",
         "ult",
         "slt",
         "ugt",
         "sgt",
         "ule",
         "sle",
         "uge",
         "sge"]

opers = [
         "add",
         "sub",
         "and",
         "or",
         "xor",
         "avg",
         "max",
         "min",
         "andnot",
         "bextr",
         "bzhi",
         "shift_left",
         "shift_right",
         "shift_right_arith",
         "rotate_left",
         "rotate_right",
         "test",
         "mul_high",
         "mul_low",
         "imul_high",
         "imul_low",
         "float_mul",
         "packss",
         "packus",
         "div_quotient",
         "div_remainder",
         "idiv_quotient",
         "idiv_remainder",
         "float_div",
         "floatcmp",
         "pblend",
         "pdep",
         "pext",
         "pextr",
         "pinsr",
         "psadbw",
         "pmovmskb",
         "pmovzx",
         "punpck",
         "phadd",
         "bt",
         "blsi",
         "blsmask",
         "blsr",
         "bsx",
         "zcnt",
         "lahf",
         "conv_ftoi",
         "conv_itof",
         "conv_ftof",
         "fst",
         "popcnt",
]


primary = [("op1", 3),
           ("op2", 4),
           ("op3", 5),
           ("op5", 7),
           ("getflag", 3),
           ("setflags", 8),
           ("setflag_float", 4),
           ("setflag1", 3),
           ("setflag2", 4),
           ("setflag3", 5),
           ("setflag4", 6),
           ("getrm", 2),
           ("parith", 4),
           ("vector_packed_float", 4),
           ("vector_scalar_float", 4),
           ("readmem", 3),
           ("writemem", 4)]

vals = []

for oper, na in primary:
    vals.append((oper, na))
for oper in opers:
    vals.append((oper, 0))
for oper in flags:
    vals.append((oper, 0))
# for oper in oper2:
#     vals.append((oper, 0))
# for oper in oper3:
#     vals.append((oper, 0))

# helpers = [("getflag", 3),
#            ("setflags", 8),
#            ("setflag", 3)]



# vals = [("flagunchanged", 1),
        
#         ("setflags", 8),
#         ("getcarry", 2),
#         ("getadjust", 2),
#         ("getdirection", 2),
#         ("getoverflow", 2),
#         ("getsign", 2),
#         ("getzero", 2),
#         ("getparity", 2),
        
#         ("seteq", 2),
#         ("setne", 2),
#         ("setult", 2),
#         ("setslt", 3),
#         ("setugt", 3),
#         ("setsgt", 4),
#         ("setule", 3),
#         ("setsle", 4),
#         ("setuge", 2),
#         ("setsge", 3),
        
#         # ("geteq", 2),
#         # ("getne", 2),
#         # ("getult", 2),
#         # ("getslt", 2),
#         # ("getugt", 2),
#         # ("getsgt", 2),
#         # ("getule", 2),
#         # ("getsle", 2),
#         # ("getuge", 2),
#         # ("getsge", 2),
        
#         ("logicsign", 2),
#         ("logiczero", 2),
#         ("logicparity", 2),

#         ("packss", 3),
#         ("packus", 3),
        
#         ("bsret", 2),
#         ("bszero", 2),

#         ("bextres", 3),
#         ("bextzero", 3),
        
#         ("blsires", 2),
#         ("blsicf", 2),
#         ("blsisign", 2),
#         ("blsizero", 2),
        
#         ("blsmskres", 2),
#         ("blsmskcf", 2),
#         ("blsmsksign", 2),
        
#         ("blsrres", 2),
#         ("blsrcf", 2),
#         ("blsrsign", 2),
#         ("blsrzero", 2),

#         ("bzhires", 3),
#         ("bzhicf", 3),
#         ("bzhisign", 3),
#         ("bzhizero", 3),
        
#         ("floatcmpparity", 3),
#         ("floatcmpzero", 3),
#         ("floatcmpcarry", 3),
#         ("floatcmpne", 3),
#         ("floatcmpugt", 3),
#         ("floatcmpule", 3),
#         ("floatcmpuge", 3),
        
#         ("readmem", 2),
#         # ("writemem", 3),
        
#         ("subdiffreg", 3),
#         ("subcarry", 3),
#         ("subadjust", 3),
#         ("suboverflow", 3),
#         ("subsign", 3),
#         ("subzero", 3),
#         ("subparity", 3),
        
#         ("addsumreg", 3),
#         ("addcarry", 3),
#         ("addadjust", 3),
#         ("addoverflow", 3),
#         ("addsign", 3),
#         ("addzero", 3),
#         ("addparity", 3),
        
#         ("shiftres", 3),
#         ("shiftcfbit", 3),
#         ("shiftafbit", 3),
#         ("shiftofbit", 3),
#         ("shiftsfbit", 3),
#         ("shiftzfbit", 3),
#         ("shiftpfbit", 3),
        
#         ("rotateres", 3),
#         ("rotatecfbit", 3),
#         ("rotateofbit", 3),
        
#         ("mulhigh", 3),
#         ("mullow", 3),
#         ("mulnotzero", 3),
        
#         ("divquotient", 3),
#         ("divremainder", 3),
#         ("testzfbit", 3),
#         ("testcfbit", 3)]

# let smt_donotsimplify_using_solver_suboverflow vc = smt_mk_donotsimplify_using_solver_suboverflow vc.ctx
def parse1():
    filename = "./fbgen/ml/smtsolver.ml"
    lines = open(filename).readlines()
    findstr = "let smt_donotsimplify_using_solver_"
    done = False
    new_lines = []
    for line in lines:
        if line.startswith(findstr):
            if done:
                continue
            else:
                for v, ac in vals:
                    new_lines.append(findstr + v +
                                     " vc = smt_mk_donotsimplify_using_solver_" +
                                     v +" vc.ctx\n")
                done = True
        else:
            new_lines.append(line)
    open("./fbgen/ml/smtsolver.ml", 'w').writelines(new_lines)
    
# Expr smt_mk_donotsimplify_using_solver_suboverflow(Context vc, Expr a, Expr arg1, Expr arg2);
def parse2():
    filename = "./fbgen/ml/libsmt.idl"
    lines = open(filename).readlines()
    findstr = "Expr smt_mk_donotsimplify_using_solver_"
    done = False
    new_lines = []
    for line in lines:
        if line.startswith(findstr):
            if done:
                continue
            else:
                for v, ac in vals:
                    if ac == 0:
                        st = findstr + v + "(Context vc);\n"
                    else :
                        st = findstr + v + "(Context vc, Expr a"
                        for i in range(1, ac):
                            st += ", Expr arg" + str(i)
                        st += ");\n"
                    new_lines.append(st)
                done = True
        else:
            new_lines.append(line)
    open("./fbgen/ml/libsmt.idl", 'w').writelines(new_lines)

# let smt_mk_donotsimplify_using_solver_suboverflow ctx a arg1 arg2 =
#   let ret = smt_mk_donotsimplify_using_solver_suboverflow ctx a arg1 arg2 in
#   ret
def parse3():
    filename = "./fbgen/ml/smt.ml"
    text = open(filename).read()
    findstart = "let smt_mk_donotsimplify_using_solver_"
    findend = "let smt_mk_select"

    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
        if ac == 0:
            new_text += "let smt_mk_donotsimplify_using_solver_" + v + " ctx =\n"
            new_text += "  let ret = smt_mk_donotsimplify_using_solver_" + v + " ctx "
            new_text += "in\n"
            new_text += "  ret\n\n"
        else:
            new_text += "let smt_mk_donotsimplify_using_solver_" + v + " ctx a "
            for i in range(1, ac):
                new_text += "arg" + str(i) + " "
            new_text += "=\n"
            new_text += "  let ret = smt_mk_donotsimplify_using_solver_" + v + " ctx a "
            for i in range(1, ac):
                new_text += "arg" + str(i) + " "
            new_text += "in\n"
            new_text += "  ret\n\n"
                
    new_text += text[idx2:]
    open("./fbgen/ml/smt.ml", 'w').write(new_text)

# expr_ref mk_donotsimplify_using_solver_suboverflow(expr_ref orig, expr_ref cmp_arg1, expr_ref cmp_arg2, expr_id_t suggested_id = 0);
def parse4():
    filename = "./superopt/include/expr/context.h"
    text = open(filename).read()
    findstart = "  expr_ref mk_donotsimplify_using_solver_"
    findend = """//expr_ref mk_function_argument_ptr(expr_ref a, memlabel_t const &ml, expr_ref mem, expr_id_t suggested_id = 0);"""
    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
        if ac == 0:
            new_text += "  expr_ref mk_donotsimplify_using_solver_" + v + "(expr_id_t suggested_id = 0);\n"
        else:
            new_text += "  expr_ref mk_donotsimplify_using_solver_" + v + "(expr_ref orig"
            for i in range(1, ac):
                new_text += ", expr_ref cmp_arg" + str(i)
            new_text += ", expr_id_t suggested_id = 0);\n"
    new_text += text[idx2:]
    open("./superopt/include/expr/context.h", 'w').write(new_text)

#     OP_DONOTSIMPLIFY_USING_SOLVER_SUBOVERFLOW,
def parse5():
    filename = "./superopt/include/expr/expr.h"
    text = open(filename).read()
    findstart = "    OP_DONOTSIMPLIFY_USING_SOLVER_"
    findend = """    OP_MEMMASK,"""
    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
        new_text += findstart + v.upper() + ",\n"
    new_text += text[idx2:]
    open("./superopt/include/expr/expr.h", 'w').write(new_text)


# extern "C" expr* smt_mk_donotsimplify_using_solver_suboverflow(context* ctx, expr* a, expr *arg1, expr *arg2)
# {
#   expr_ref const &aref = active_exprs.at(a);
#   expr_ref const &arg1ref = active_exprs.at(arg1);
#   expr_ref const &arg2ref = active_exprs.at(arg2);
#   expr_ref ret = ctx->mk_donotsimplify_using_solver_suboverflow(aref, arg1ref, arg2ref);
#   active_exprs.insert(make_pair(ret.get(), ret));
#   return ret.get();
# }
def parse6():
    filename = "./superopt/lib/expr/expr_c_api.cpp"
    text = open(filename).read()
    findstart = "extern \"C\" expr* smt_mk_donotsimplify_using_solver"
    findend = "extern \"C\" expr* smt_mk_select"
    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
        if ac == 0:
            new_text += "extern \"C\" expr* smt_mk_donotsimplify_using_solver_" + v + "(context* ctx"
            new_text += """)
{\n"""
            new_text += "  expr_ref ret = ctx->mk_donotsimplify_using_solver_" + v + "("
            
        else:
            new_text += "extern \"C\" expr* smt_mk_donotsimplify_using_solver_" + v + "(context* ctx, expr* a"
            for i in range(1, ac):
                new_text += ", expr *arg" + str(i)
            new_text += """)
{
  expr_ref const &aref = active_exprs.at(a);\n"""
            for i in range(1, ac):
                new_text += """  expr_ref const &arg""" + str(i) + """ref = active_exprs.at(arg""" + str(i) + """);\n"""
            new_text += "  expr_ref ret = ctx->mk_donotsimplify_using_solver_" + v + "(aref"
            for i in range(1, ac):
                new_text += ", arg" + str(i) + "ref"
        new_text += """);
  active_exprs.insert(make_pair(ret.get(), ret));
  return ret.get();
}

"""
    new_text += text[idx2:]
    open("./superopt/lib/expr/expr_c_api.cpp", 'w').write(new_text)
    
#     add_entry("donotsimplify_using_solver_suboverflow", expr::OP_DONOTSIMPLIFY_USING_SOLVER_SUBOVERFLOW);
def parse7():
    filename = "./superopt/lib/expr/expr.cpp"
    text = open(filename).read()
    findstart = """    add_entry("donotsimplify_using_solver_"""
    findend = """    add_entry("memmask", expr::OP_MEMMASK);"""
    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
        new_text += """    add_entry("donotsimplify_using_solver_"""
        new_text += v
        new_text += """", expr::OP_DONOTSIMPLIFY_USING_SOLVER_"""
        new_text += v.upper()
        new_text += ");\n"
    new_text += text[idx2:]
    open("./superopt/lib/expr/expr.cpp", 'w').write(new_text)

# expr_ref context::mk_donotsimplify_using_solver_suboverflow(expr_ref a, expr_ref arg1, expr_ref arg2, expr_id_t suggested_id)
# {
#   return create_new_expr(expr::OP_DONOTSIMPLIFY_USING_SOLVER_SUBOVERFLOW, make_args(a, arg1, arg2), suggested_id);
# }
def parse8():
    filename = "./superopt/lib/expr/expr.cpp"
    text = open(filename).read()
    findstart = """expr_ref context::mk_donotsimplify_using_solver_"""
    findend = """/*expr_ref context::mk_function_argument_ptr(expr_ref a, memlabel_t const &ml, expr_ref mem, expr_id_t suggested_id)
{
  return mk_app(expr::OP_FUNCTION_ARGUMENT_PTR, make_args(a, this->mk_memlabel_const(ml), mem));
}
"""
    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
        new_text += """expr_ref context::mk_donotsimplify_using_solver_""" + v + "("
        if ac != 0:
            new_text += "expr_ref a"
        for i in range(1, ac):
                new_text += ", expr_ref arg" + str(i)
        if ac != 0:
            new_text += ", "
        new_text += """expr_id_t suggested_id)
{
  return create_new_expr(expr::OP_DONOTSIMPLIFY_USING_SOLVER_"""
        new_text += v.upper()
        new_text += ", make_args("
        if ac != 0:
            new_text += "a"
        for i in range(1, ac):
                new_text += ", arg" + str(i)
        new_text += """), suggested_id);
}

"""
    new_text += text[idx2:]
    open("./superopt/lib/expr/expr.cpp", 'w').write(new_text)

#   case expr::OP_DONOTSIMPLIFY_USING_SOLVER_SUBOVERFLOW:
def parse9():
    filename = "./superopt/lib/expr/expr_to_z3_expr.cpp"
    text = open(filename).read()
    findstart = """  case expr::OP_DONOTSIMPLIFY_USING_SOLVER_"""
    findend = """  {"""
    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
        new_text += """  case expr::OP_DONOTSIMPLIFY_USING_SOLVER_""" + v.upper() + ":\n"
    new_text += text[idx2:]
    open("./superopt/lib/expr/expr_to_z3_expr.cpp", 'w').write(new_text)

#   case expr::OP_DONOTSIMPLIFY_USING_SOLVER_SUBOVERFLOW:
def parse10():
    filename = "./superopt/lib/expr/eval.cpp"
    text = open(filename).read()
    findstart = """  case expr::OP_DONOTSIMPLIFY_USING_SOLVER_"""
    findend = """case expr::OP_MEMMASK:"""
    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
        if ac != 0:
            new_text += """  case expr::OP_DONOTSIMPLIFY_USING_SOLVER_""" + v.upper() + ":\n"
    new_text += """
    {
    pair<expr_eval_status_t, expr_ref> cval0 = m_map.at(e->get_args().at(0)->get_id());
      ret = cval0.first;
      const_val = cval0.second;
      break;
    }

"""
    for v, ac in vals:
        if ac == 0:
            new_text += """  case expr::OP_DONOTSIMPLIFY_USING_SOLVER_""" + v.upper() + ":\n"
    new_text += """
    {
      break;
    }
    """    
    new_text += text[idx2:]
    
    open("./superopt/lib/expr/eval.cpp", 'w').write(new_text)

#   case expr::OP_DONOTSIMPLIFY_USING_SOLVER_SUBOVERFLOW:
#     assert(args.size() == 3);
#     return args.at(0)->get_sort();
def parse11():
    filename = "./superopt/lib/expr/context.cpp"
    text = open(filename).read()
    findstart = """  case expr::OP_DONOTSIMPLIFY_USING_SOLVER_"""
    findend = """case expr::OP_MEMMASK:"""
    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
        new_text += """  case expr::OP_DONOTSIMPLIFY_USING_SOLVER_""" + v.upper() + ":\n"
        if ac == 0:
            new_text += "    assert(args.size() == " + str(ac) +  ");\n"
            new_text += "    return mk_donotsimplify_label_sort();\n"            
        else:
            new_text += "    assert(args.size() == " + str(ac) +  ");\n"
            new_text += "    return args.at(0)->get_sort();\n"
    new_text += text[idx2:]
    open("./superopt/lib/expr/context.cpp", 'w').write(new_text)

# expr::expr_op_is_donotsimplify_using_solver(expr::operation_kind op)
def parse12():
    filename = "./superopt/lib/expr/expr.cpp"
    text = open(filename).read()
    fp = """expr::expr_op_is_donotsimplify_using_solver(expr::operation_kind op)"""
    idx0 = text.find(fp)
    findstart = "(op == OP_DONOTSIMPLIFY_USING_SOLVER_"
    findend = """         || (op == OP_MEMMASK)"""
    idx1 = text.find(findstart, idx0)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    i = 0
    for v, ac in vals:
        if i == 0:
            new_text += "(op == OP_DONOTSIMPLIFY_USING_SOLVER_" + v.upper() + ")\n"
        else:
            new_text += "         || (op == OP_DONOTSIMPLIFY_USING_SOLVER_" + v.upper() + ")\n"
        i += 1
    new_text += text[idx2:]
    open("./superopt/lib/expr/expr.cpp", 'w').write(new_text)

# expr::expr_op_can_be_replaced_by_first_arg(expr::operation_kind op)
def parse13():
    filename = "./superopt/lib/expr/expr.cpp"
    text = open(filename).read()
    fp = """expr::expr_op_can_be_replaced_by_first_arg(expr::operation_kind op)"""
    idx0 = text.find(fp)
    findstart = "(op == OP_DONOTSIMPLIFY_USING_SOLVER_"
    findend = """;"""
    idx1 = text.find(findstart, idx0)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    i = 0
    for v, ac in vals:
        if ac == 0:
            continue
        if i == 0:
            new_text += "(op == OP_DONOTSIMPLIFY_USING_SOLVER_" + v.upper() + ")\n"
        else:
            new_text += "    || (op == OP_DONOTSIMPLIFY_USING_SOLVER_" + v.upper() + ")\n"
        i += 1
    new_text += text[idx2:]
    open("./superopt/lib/expr/expr.cpp", 'w').write(new_text)

def parse14():
    filename = "./superopt/lib/expr/expr.cpp"
    text = open(filename).read()
    fp = """expr::get_donotsimpify_op_label_string(expr::operation_kind op)"""
    idx0 = text.find(fp)
    findstart = "case expr::OP_DONOTSIMPLIFY_USING_SOLVER_"
    findend = """default"""
    idx1 = text.find(findstart, idx0)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v in opers:
        new_text += "  case expr::OP_DONOTSIMPLIFY_USING_SOLVER_" + v.upper() + ":\n"
        new_text += "    return \"" + v + "\";\n"
    new_text += text[idx2:]
    open(filename, 'w').write(new_text)

def parse15():
    filename = "./superopt/lib/expr/expr.cpp"
    text = open(filename).read()
    fp = """expr::get_donotsimpify_flag_label_string(expr::operation_kind op)"""
    idx0 = text.find(fp)
    findstart = "case expr::OP_DONOTSIMPLIFY_USING_SOLVER_"
    findend = """default"""
    idx1 = text.find(findstart, idx0)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v in flags:
        new_text += "  case expr::OP_DONOTSIMPLIFY_USING_SOLVER_" + v.upper() + ":\n"
        new_text += "    return \"" + v + "\";\n"
    new_text += text[idx2:]
    open(filename, 'w').write(new_text)
    
parse1()
parse2()
parse3()
parse4()
parse5()
parse6()
parse7()
parse8()
parse9()
parse10()
parse11()
parse12()
parse13()
parse14()
parse15()
