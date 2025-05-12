import aocd
from tqdm import tqdm
from collections import defaultdict


example = """###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############"""



def parse(inp):
    start, end, walls = None, None, set()
    for y, line in enumerate(inp.splitlines()):
        for x, c in enumerate(line):
            if c == 'S':
                start = (x, y)
            elif c == 'E':
                end = (x, y)
            elif c == '#':
                walls.add((x, y))
            else:
                pass

    return start, end, walls


def find_path_to_goal(start, end, walls) -> dict:
    # We assume that there is only one path to the goal.
    visited = {start}
    path = [start]

    while path[-1] != end:
        x, y = path[-1]
        neighbours = [(x + dx, y + dy) for dx, dy in [(0, 1), (1, 0), (0, -1), (-1, 0)]]
        neighbours = [n for n in neighbours if n not in visited and n not in walls]

        if not neighbours:
            raise ValueError('No possible path detected!')

        if len(neighbours) > 1:
            # There should be only one neighbour!
            raise ValueError(f'More than one possible path detected: {neighbours} <- {path} and {visited}')

        # Choose the first neighbour
        path.append(neighbours[0])
        visited.add(neighbours[0])

    return {p: k for k, p in enumerate(path)}


def get_cheat_value(point: tuple, path: defaultdict, walls: set, min_saving: int = 100, jump_width: int = 2) -> list[tuple]:
    # For a given point, we want to check whether we can skip through a wall and how much it would save us.
    x, y = point

    # Create a list of possible points to jump to based on the manhattan distance:
    possible_targets = [
        (xt, yt) for xt, yt in path if abs(xt - x) + abs(yt - y) <= jump_width
    ]

    # Possible jump coordinates are those where the jump target is on the path and an intermediary step is a wall.
    # There can be up to two jumps leading off the path.
    return [
        (point, (xt, yt), path[(xt, yt)] - path[point] - abs(xt - x) - abs(yt - y))
        for xt, yt in possible_targets
        if path[(xt, yt)] - path[point] - abs(xt - x) - abs(yt - y) >= min_saving
    ]

start, end, walls = parse(example)
path = find_path_to_goal(start, end, walls)
assert get_cheat_value((8, 7), path, walls, min_saving=1) == [((8, 7), (8, 9), 38)]


def solve(inp, min_saving=100, jump_width=2, debug=False):
    start, end, walls = parse(inp)
    path = find_path_to_goal(start, end, walls)

    jumps = []
    savings = defaultdict(int)
    for point in tqdm(path):
        jumps_from_here = get_cheat_value(point, path, walls, min_saving=min_saving, jump_width=jump_width)
        jumps.extend(jumps_from_here)
        for _, _, saving in jumps_from_here:
            savings[saving] += 1

    if debug:
        print(savings)

    print('Jump width:', jump_width, '->', sum(v for k, v in savings.items() if k >= min_saving))


#solve(example)
solve(aocd.get_data(year=2024, day=20))
#solve(example, min_saving=50, jump_width=20, debug=True)
solve(aocd.get_data(year=2024, day=20), jump_width=20)
