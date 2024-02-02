
vals = [("flagunchanged", 1),
        ("setflags", 8),
        ("getcarry", 1),
        ("getadjust", 1),
        ("getdirection", 1),
        ("getoverflow", 1),
        ("getsign", 1),
        ("getzero", 1),
        ("getparity", 1),
        ("subdiffreg", 3),
        ("subcarry", 3),
        ("subadjust", 3),
        ("suboverflow", 3),
        ("subsign", 3),
        ("subzero", 3),
        ("subparity", 3),
        ("addsumreg", 3),
        ("addcarry", 3),
        ("addadjust", 3),
        ("addoverflow", 3),
        ("addsign", 3),
        ("addzero", 3),
        ("addparity", 3),
        ("shiftres", 3),
        ("shiftcfbit", 3),
        ("shiftafbit", 3),
        ("shiftofbit", 3),
        ("shiftsfbit", 3),
        ("shiftzfbit", 3),
        ("shiftpfbit", 3),
        ("rotateres", 3),
        ("rotatecfbit", 3),
        ("rotateofbit", 3),
        ("mulhigh", 3),
        ("mullow", 3),
        ("divquotient", 3),
        ("divremainder", 3),
        ("testzfbit", 3),
        ("testcfbit", 3)]

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
    findend = """
  
  //expr_ref mk_function_argument_ptr(expr_ref a, memlabel_t const &ml, expr_ref mem, expr_id_t suggested_id = 0);
  expr_ref mk_return_value_ptr(expr_ref a, memlabel_t const &ml, expr_ref mem, expr_id_t suggested_id = 0);"""
    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
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
    findend = """    
    add_entry("memmask", expr::OP_MEMMASK);"""
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
    findend = """
/*expr_ref context::mk_function_argument_ptr(expr_ref a, memlabel_t const &ml, expr_ref mem, expr_id_t suggested_id)
{
  return mk_app(expr::OP_FUNCTION_ARGUMENT_PTR, make_args(a, this->mk_memlabel_const(ml), mem));
}
"""
    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
        new_text += """expr_ref context::mk_donotsimplify_using_solver_""" + v
        new_text += "(expr_ref a"
        for i in range(1, ac):
                new_text += ", expr_ref arg" + str(i)
        new_text += """, expr_id_t suggested_id)
{
  return create_new_expr(expr::OP_DONOTSIMPLIFY_USING_SOLVER_"""
        new_text += v.upper()
        new_text += ", make_args(a"
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
    findend = """  {
    ASSERT(e->get_args().size() == 3);
    expr_ref arg = e->get_args().at(0);
"""
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
    findend = """{
    pair<expr_eval_status_t, expr_ref> cval0 = m_map.at(e->get_args().at(0)->get_id());"""
    idx1 = text.find(findstart)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    for v, ac in vals:
        new_text += """  case expr::OP_DONOTSIMPLIFY_USING_SOLVER_""" + v.upper() + ":\n"
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
    findend = """;
}

bool
expr::expr_op_is_bvcmp(expr::operation_kind op)"""
    idx1 = text.find(findstart, idx0)
    idx2 = text.find(findend, idx1)
    new_text = text[:idx1]
    i = 0
    for v, ac in vals:
        if i == 0:
            new_text += "(op == OP_DONOTSIMPLIFY_USING_SOLVER_" + v.upper() + ")\n"
        else:
            new_text += "    || (op == OP_DONOTSIMPLIFY_USING_SOLVER_" + v.upper() + ")\n"
    new_text += text[idx2:]
    open("./superopt/lib/expr/expr.cpp", 'w').write(new_text)
    
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
