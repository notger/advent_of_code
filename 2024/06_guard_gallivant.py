import numpy as np
from torch.linalg import solve

grid = """....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...""".splitlines()
grid = open('data/06.dat').read().splitlines()

grid = [list(row) for row in grid]
starting_position = next((i, j) for i in range(len(grid)) for j in range(len(grid[0])) if grid[i][j] == '^')
obstacles = set((i, j) for i in range(len(grid)) for j in range(len(grid[0])) if grid[i][j] == '#')

directions = [(-1, 0), (0, 1), (1, 0), (0, -1)]

def turn(directions):
    directions = directions[1:] + [directions[0]]
    return directions

def solve_one(starting_position, directions, obstacles):
    position = starting_position
    visited = {(starting_position, directions[0])}
    while True:
        x, y = position
        dx, dy = directions[0]
        next_pos = (x + dx, y + dy)

        if next_pos in obstacles:
            directions = turn(directions)
        elif 0 <= next_pos[0] < len(grid) and 0 <= next_pos[1] < len(grid[0]):
            position = next_pos

            if (position, directions[0]) not in visited:
                visited.add((position, directions[0]))
            else:
                return visited, True

        else:
            return visited, False

visited, is_loop = solve_one(starting_position, directions, obstacles)
num_visited_positions = len(set(pos for pos, _ in visited))

print("Part 1: ", num_visited_positions, is_loop)

# Part 2
ctr = 0
for i in range(len(grid)):
    for j in range(len(grid[0])):
        if (i, j) not in obstacles:
            new_obstacles = obstacles | {(i, j)}
            _, is_loop = solve_one(starting_position, directions, new_obstacles)
            ctr += int(is_loop)

print("Part 2: ", ctr)
