import numpy as np
from collections import defaultdict
import matplotlib.pyplot as plt

example = """p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3"""

MAX_X = 11
MAX_Y = 7

dat = open('data/14.dat', 'rt').read()

def parse(inp):
    paths = []
    for line in inp.splitlines():
        p, v = [x.split('=')[1] for x in line.split()]
        p = tuple(int(x) for x in p.split(','))
        v = tuple(int(x) for x in v.split(','))
        paths.append((p, v))

    return paths

def convert_paths_to_numpy(paths):
    p0 = np.zeros((len(paths), 2), dtype=int)
    v = np.zeros((len(paths), 2), dtype=int)

    for i, (p, v_) in enumerate(paths):
        p0[i] = p
        v[i] = v_

    return p0, v

def positions_in_step(p0, v, step, max_x=MAX_X, max_y=MAX_Y):
    pos = p0 + step * v
    np.mod(pos, [max_x, max_y], out=pos)
    return pos

def count_quadrants(positions, max_x=MAX_X, max_y=MAX_Y):
    ctr = defaultdict(int)
    for pos in positions:
        rel_pos = pos - [max_x // 2, max_y // 2]
        if 0 not in rel_pos:
            quadrant = np.sign(rel_pos)
            ctr[tuple(quadrant)] += 1

    return np.asarray(list(ctr.values()))

def solve1(inp, max_x=MAX_X, max_y=MAX_Y):
    p0, v = convert_paths_to_numpy(parse(inp))
    pos = positions_in_step(p0, v, step=100, max_x=max_x, max_y=max_y)
    quadrants = count_quadrants(pos, max_x, max_y)
    print(np.prod(quadrants))

def convert_to_matrix(positions, max_x=MAX_X, max_y=MAX_Y):
    matrix = np.zeros((max_y, max_x), dtype=int)
    for pos in positions:
        matrix[pos[1], pos[0]] += 1

    return matrix

def solve2(inp, max_x=MAX_X, max_y=MAX_Y, num_steps=100):
    # Candidate with patterns are 12 and 35:
    p0, v = convert_paths_to_numpy(parse(inp))

    for k in range(num_steps):
        p = positions_in_step(p0, v, step=k, max_x=max_x, max_y=max_y)

        # This here is one condition, which I don't know why it works.
        # Why is the assumption that no robots are stacked true?
        # I guess that is just a lucky break as that is how the input is created.
        # In order to run the following condition, you have to add M = convert_to_matrix(p, max_x, max_y)
        # to the code above.
        #if M.max() == 1:
        #    plt.matshow(M)
        #    plt.title(k)
        #    plt.show()

        # But another condition makes sense: Every horizontal pattern repeats with every max_y lines
        # and every vertical pattern repeats with every max_x columns. So if at any given step k,
        # k is divisible by the respective frequency, then we have a candidate.
        # Before checking for divisibility, however, we have to subtract the respective
        # offset. In this case 12 for the horizontal pattern and 35 for the vertical pattern.
        if (k - 12) % max_y == 0 and (k - 35) % max_x == 0:
            M = convert_to_matrix(p, max_x, max_y)
            print(f'Solution for part 2: {k}')
            plt.matshow(M)
            plt.title(k)
            plt.show()


solve1(example)
solve1(dat, max_x=101, max_y=103)

solve2(dat, max_x=101, max_y=103, num_steps=10000)
