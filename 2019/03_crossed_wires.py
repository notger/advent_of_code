def parse(inp):
    return [[(elem[0], int(elem[1:])) for elem in line.split(',')] for line in inp]


example = parse("""R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83""".split('\n'))

puzzle = parse(open('data/03.dat', 'rt').read().split('\n'))

directions = {
    'U': (1, 0),
    'R': (0, 1),
    'D': (-1, 0),
    'L': (0, -1)
}


def get_next(cur, dir):
    return (cur[0] + directions[dir][0], cur[1] + directions[dir][1])


def crossed_wires(wires):
    lowest_distance = 1e6

    cur, steps = (0, 0), 0
    board = {cur}
    timings1, timings2 = {}, {}

    for dir, L in wires[0]:
        for k in range(L):
            steps += 1
            cur = get_next(cur, dir)
            board.add(cur)
            if cur not in timings1:
                timings1[cur] = steps

    cur, steps = (0, 0), 0
    for dir, L in wires[1]:
        for k in range(L):
            steps += 1
            cur = get_next(cur, dir)
            if (cur in board):
                if cur not in timings2:
                    timings2[cur] = steps
                if (dist:=min(lowest_distance, sum(abs(x) for x in cur))) < lowest_distance:
                    lowest_distance = dist

    return lowest_distance, min([timings1[p] + timings2[p] for p in timings2])


print('Example:', crossed_wires(example))
print('Puzzle:', crossed_wires(puzzle))
