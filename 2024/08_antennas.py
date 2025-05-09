import numpy as np
from collections import defaultdict
import matplotlib.pyplot as plt

example = """............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............"""


def parse_antennas(inp):
    antennas = defaultdict(set)
    for i, row in enumerate(inp.split('\n')):
        for j, cell in enumerate(row):
            if cell != '.':
                antennas[cell].add((i, j))

    return antennas, i, j


def calculate_antinodes(antennas, max_x, max_y):
    antinodes = defaultdict(set)

    for frequency, antennas in antennas.items():
        for first in antennas:
            for second in antennas:
                if first == second:
                    continue

                x1, y1 = first
                x2, y2 = second
                dx , dy = x2 - x1, y2 - y1

                potential_antinodes = [(x1 - dx, y1 - dy), (x2 + dx, y2 + dy)]

                for x, y in potential_antinodes:
                    if 0 <= x <= max_x and 0 <= y <= max_y:
                        antinodes[frequency].add((x,y))

    return antinodes


def calculate_antinodes2(antennas, max_x, max_y):
    antinodes = defaultdict(set)

    for frequency, antennas in antennas.items():
        for first in antennas:
            for second in antennas:
                if first == second:
                    continue

                x1, y1 = first
                x2, y2 = second
                dx , dy = x2 - x1, y2 - y1

                k = 0
                while True:
                    potential_antinodes = [(x2 - k * dx, y2 - k * dy), (x1 + k * dx, y1 + k * dy)]

                    oob_counter = 0
                    for x, y in potential_antinodes:
                        if 0 <= x <= max_x and 0 <= y <= max_y:
                            antinodes[frequency].add((x,y))
                        else:
                            oob_counter += 1

                    if oob_counter == 2:
                        break

                    k += 1

    return antinodes


def convert_to_matrix(positions, antinodes, max_x, max_y):
    matrix = np.zeros((max_y + 1, max_x + 1), dtype=int)
    for pos in positions:
        matrix[pos[1], pos[0]] += 1

    print(antinodes)

    for an in set(antinodes):
        matrix[an[1], an[0]] += 2

    return matrix


#antennas, max_x, max_y = parse_antennas(example)
#antinodes = calculate_antinodes(*parse_antennas(example))

#print(sum(len(antinodes) for antinodes in antinodes.values()))

#M = convert_to_matrix(
#    [x for l in antennas.values() for x in l],
#    [x for l in antinodes.values() for x in l],
#    max_x, max_y
#)
#plt.matshow(M.T)
#plt.show()

def solve1(inp):
    antennas, max_x, max_y = parse_antennas(inp)
    antinodes = calculate_antinodes(antennas, max_x, max_y)

    return len(set([x for l in antinodes.values() for x in l]))


def solve2(inp):
    antennas, max_x, max_y = parse_antennas(inp)
    antinodes = calculate_antinodes2(antennas, max_x, max_y)

    return len(set([x for l in antinodes.values() for x in l]))

print(solve1(example))
print(solve1(open('data/08.dat').read()))

print(solve2(example))
print(solve2(open('data/08.dat').read()))
