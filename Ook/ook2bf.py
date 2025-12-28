#!/usr/bin/env python3
import sys
import re

MAP = {
    "Ook. Ook?": ">",
    "Ook? Ook.": "<",
    "Ook. Ook.": "+",
    "Ook! Ook!": "-",
    "Ook! Ook.": ".",
    "Ook. Ook!": ",",
    "Ook! Ook?": "[",
    "Ook? Ook!": "]",
}

# Regex to match valid Ook tokens (pairwise)
TOKENS = re.compile(
    r"(Ook[.!?]\s+Ook[.!?])",
    re.MULTILINE
)

def translate(src):
    for match in TOKENS.finditer(src):
        token = match.group(1)
        if token in MAP:
            sys.stdout.write(MAP[token])
        else:
            # Unknown pair — ignore safely
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
        print("usage: ook2bf.py [file.ook]", file=sys.stderr)
        sys.exit(1)

    translate(src)

if __name__ == "__main__":
    main()

