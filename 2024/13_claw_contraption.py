from aocd import get_data
import re
import numpy as np

example = """Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279""".splitlines()

dat = get_data(year=2024, day=13).splitlines()


def parse(data):
    blocks = []
    block = []
    for line in data:
        if len(line) == 0:
            blocks.append(block[:])
            block = []
        else:
            block.append(line)
    blocks.append(block)

    for k, block in enumerate(blocks):
        A = [int(x) for x in re.findall(r'\d+', block[0])]
        B = [int(x) for x in re.findall(r'\d+', block[1])]
        target = np.asarray([int(x) for x in re.findall(r'\d+', block[2])])
        M = np.asarray([[A[0], B[0]], [A[1], B[1]]])
        blocks[k] = (M, target)

    return blocks

def solve(data, offset=0):
    res = 0
    for k, (M, target) in enumerate(parse(data)):
        target += offset
        presses = np.dot(np.linalg.inv(M), target)
        if presses is not None:
            A, B = [round(x) for x in presses]
            test = np.dot(M, [A, B])

            if abs(test[0] - target[0]) < 1 and abs(test[1] - target[1]) < 1:
                res += 3 * A + B

    return res

if solve(example) == 480:
    print("Part 1: ", solve(dat))
    print("Part 2: ", solve(dat, offset=10000000000000))
