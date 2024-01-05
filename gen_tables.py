import argparse
from common import gen_detailed_table, gen_passing_latex_table

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', type=str, default='out.csv')
    parser.add_argument('filename', type=str)

    args = parser.parse_args()

    short_tab =  gen_detailed_table(args.filename, csv_name=args.o)
    print(short_tab)
