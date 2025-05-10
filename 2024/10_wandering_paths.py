
example = """89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"""

example2 = """..90..9
...1.98
...2..7
6543456
765.987
876....
987...."""


def parse(inp):
    heights = {}
    for x, line in enumerate(inp.strip().split("\n")):
        for y, c in enumerate(line):
            if c != ".":
                heights[(x, y)] = int(c)

    return heights


def solve(inp):
    heights = parse(inp)

    trail_starts = [coords for coords, height in heights.items() if height == 0]
    trail_ends = [coords for coords, height in heights.items() if height == 9]

    def manhattan_distance(start, end):
        return abs(start[0] - end[0]) + abs(start[1] - end[1])


    # We can do this in two ways:
    # Way 1: We check for each trail whether we can reach a given end.
    # Way 2: We check for each trail which end points we can reach.
    # Way 1 is more efficient if there are many trails which lead to the same end points.
    # Way 2 is more efficient otherwise.
    def find_path_pairwise(heights, start, end):
        # Determines if there is a path from start to end where the height difference is at most 1 for each step:
        if manhattan_distance(start, end) > 9:
            return 0

        candidates = [(*start, 0)]

        rating = 0

        while candidates:
            x, y, h = candidates.pop(0)

            for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
                new_x, new_y = x + dx, y + dy
                if h == 8 and (new_x, new_y) == end:
                    rating += 1

                if (
                        (new_x, new_y) in heights
                        and (heights[(new_x, new_y)] - h) == 1
                        and manhattan_distance((new_x, new_y), end) <= 9 - (h + 1)
                ):
                    candidates.append((new_x, new_y, heights[(new_x, new_y)]))

        return rating

    #print([sum([find_path_pairwise(heights, start, end) for start in trail_starts]) for end in trail_ends])
    print()
    print('Part 1:', sum([find_path_pairwise(heights, start, end) > 0 for start in trail_starts for end in trail_ends]))
    print('Part 2:', sum([find_path_pairwise(heights, start, end) for start in trail_starts for end in trail_ends]))

solve(example)
solve(open('data/10.dat').read())
