import argparse
from common import gen_detailed_table, gen_passing_latex_table

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--dir', default='superopt-tests', help = "Directory which contains the run .csv files")
    args = parser.parse_args()

    target_functions = { 'recvDecodingTables', 'generateMTFValues', 'undoReversibleTransformation_fast' }
    short_tab =  gen_detailed_table(args.d + '/bzip2_O1-.csv', target_functions)
    print(short_tab)

    long_tab = gen_passing_latex_table([args.d + '/bzip2_O1-.csv', args.d + '/bzip2_O1.csv', args.d + '/bzip2_O2.csv'])
    print(long_tab)
