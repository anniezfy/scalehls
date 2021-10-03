#!/usr/bin/env python


import argparse
import shutil
import sys
import io
import scalehls
from mlir.ir import *


def main():
    parser = argparse.ArgumentParser(prog='py-scalehls')
    parser.add_argument('input',
                        metavar="input",
                        help='Input file')
    parser.add_argument('-o', dest='output',
                        metavar="output",
                        help='Output file')

    opts = parser.parse_args()

    ctx = Context()
    ctx.allow_unregistered_dialects = True
    fin = open(opts.input, 'r')
    mod = Module.parse(fin.read(), ctx)
    fin.close()

    buf = io.StringIO()
    scalehls.emit_hlscpp(mod, buf)
    buf.seek(0)
    if opts.output:
        fout = open(opts.output, 'w+')
        shutil.copyfileobj(buf, fout)
        fout.close()
    else:
        print(buf.read())


if __name__ == '__main__':
    main()