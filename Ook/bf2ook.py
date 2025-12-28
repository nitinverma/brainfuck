#!/usr/bin/env python3
import sys

MAP = {
    '>': "Ook. Ook?",
    '<': "Ook? Ook.",
    '+': "Ook. Ook.",
    '-': "Ook! Ook!",
    '.': "Ook! Ook.",
    ',': "Ook. Ook!",
    '[': "Ook! Ook?",
    ']': "Ook? Ook!",
}

def translate(src):
    for ch in src:
        if ch in MAP:
            print(MAP[ch])
        elif ch in '\n\r\t ':
            pass
        else:
            # ignore comments / other chars
            pass

def main():
    if len(sys.argv) == 1:
        # read from stdin
        src = sys.stdin.read()
    elif len(sys.argv) == 2:
        # read from file
        with open(sys.argv[1]) as f:
            src = f.read()
    else:
        print("usage: bf2ook.py [file.bf]", file=sys.stderr)
        sys.exit(1)

    translate(src)

if __name__ == "__main__":
    main()

