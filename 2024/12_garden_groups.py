import aocd

example1 = """AAAA
BBCD
BBCC
EEEC"""

example2 = """OOOOO
OXOXO
OOOOO
OXOXO
OOOOO"""

example3 = """RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE"""

example4 = """EEEEE
EXXXX
EEEEE
EXXXX
EEEEE"""

example5 = """AAAAAA
AAABBA
AAABBA
ABBAAA
ABBAAA
AAAAAA"""


data = aocd.get_data(year=2024, day=12)


def get_neighbours(x, y, points):
    return [(x + dx, y + dy) for dx, dy in [(0, 1), (1, 0), (0, -1), (-1, 0)] if (x + dx, y + dy) in points and points[(x, y)] == points[(x + dx, y + dy)]]

points = {(x, y): c for x, line in enumerate(example1.splitlines()) for y, c in enumerate(line)}
assert get_neighbours(0, 0, points) == [(0, 1)]
assert sorted(get_neighbours(2, 0, points)) == [(1, 0), (2, 1)]


def parse(inp):
    # Go through the input and create sections. Each section is a set of points, where each point belongs to one section.
    seen = set()
    sections = []
    points = {(x, y): c for x, line in enumerate(inp.splitlines()) for y, c in enumerate(line)}

    for (x, y), c in points.items():
        if (x, y) in seen:
            continue

        section = {(x, y)}
        to_check_for_neighbours = [(x, y)]

        while to_check_for_neighbours:
            where = to_check_for_neighbours.pop(0)
            seen.add(where)

            for neighbour in get_neighbours(*where, points):
                if neighbour not in seen and neighbour not in section:
                    section.add(neighbour)
                    to_check_for_neighbours.append(neighbour)

        sections.append(section)

    return sections

#print(parse(example1))


def evaluate_section(section):
    # The value of a section is its area times its perimeter.
    # We get the area  from the amount of points in the section and the perimeter from checking each point
    # if it has a neighbour in the section and if so, deduct the amount of neighbours.
    perimeter = 0
    for x, y in section:
        perimeter += 4 - len([(x + dx, y + dy) for dx, dy in [(0, 1), (1, 0), (0, -1), (-1, 0)] if (x + dx, y + dy) in section])

    return len(section) * perimeter

assert evaluate_section({(0, 0), (0, 1), (1, 0), (1, 1)}) == 32
assert evaluate_section({(0, 0), (0, 1), (0, 2)}) == 24


def count_corners(x, y, points):
    L, R, U, D = (x - 1, y), (x + 1, y), (x, y + 1), (x, y - 1)
    LU, RU, RD, LD = (x - 1, y + 1), (x + 1, y + 1), (x + 1, y - 1), (x - 1, y - 1)

    corners = 0
    # External corner: Two neighbours which form an L-form are not in points.
    for n1, n2 in ((L, U), (U, R), (R, D), (D, L)):
        if n1 not in points and n2 not in points:
            corners += 1

    # Internal corner: Two  neighbours which form an L-form are in points, but the diagonal between them is not.
    for n1, n2, n3 in ((L, U, LU), (U, R, RU), (R, D, RD), (D, L, LD)):
        if n1 in points and n2 in points and n3 not in points:
            corners += 1

    return corners

assert count_corners(0, 0, {(0, 0), (0, 1), (1, 0), (1, 1)}) == 1
assert count_corners(0, 0, {(0, 0), (0, 1), (1, 0), (1, 1)}) == 1
assert count_corners(0, 0, {(0, 0)}) == 4
assert count_corners(1, 1, {(0, 1), (1, 0), (1, 1)}) == 2


def evaluate_section_bulk(section):
    perimeter = sum(count_corners(x, y, section) for x, y in section)
    return len(section) * perimeter


def solve1(inp):
    sections = parse(inp)
    return sum(evaluate_section(section) for section in sections)


def solve2(inp):
    sections = parse(inp)
    return sum(evaluate_section_bulk(section) for section in sections)


assert solve1(example1) == 140
assert solve1(example2) == 772
assert solve1(example3) == 1930

print("Part 1:", solve1(data))

assert solve2(example1) == 80
assert solve2(example2) == 436
assert solve2(example5) == 368
assert solve2(example4) == 236
assert solve2(example3) == 1206

print("Part 2:", solve2(data))
