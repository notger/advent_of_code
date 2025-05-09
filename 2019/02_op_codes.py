puzzle = [int(x) for x in open('data/02.dat', 'rt').read().split(',')]


def parse(puzzle):
    p = puzzle[:]
    p[1], p[2] = 12, 2
    return p


def __mul__(u, v):
    return u * v


def __add__(u, v):
    return u + v


def run(puzzle):
    pos = 0

    ops = {
        1: __add__,
        2: __mul__,
    }

    while puzzle[pos] != 99:
        puzzle[puzzle[pos + 3]] = ops[puzzle[pos]](puzzle[puzzle[pos + 1]], puzzle[puzzle[pos + 2]])
        pos += 4

    return puzzle[0]


def search(puzzle):
    for noun in range(100):
        for verb in range(100):
            p = puzzle[:]
            p[1], p[2] = noun, verb
            if run(p) == 19690720:
                return 100 * noun + verb


print('Part 1:', run(parse(puzzle)))
print('Part 2:', search(parse(puzzle)))
