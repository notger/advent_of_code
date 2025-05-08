grid = """MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX""".splitlines()
grid = open('data/04.dat').read().splitlines()

target = 'XMAS'

candidates = [(i, j, grid[i][j]) for i in range(len(grid)) for j in range(len(grid[0])) if grid[i][j] == target[0]]


# Generate search direction:
def search_vector(x, y, dir, N):
    points = [
        ( x + k * dir[0], y + k * dir[1]) for k in range(N)
        if x + k * dir[0] >= 0 and x + k * dir[0] < len(grid) and y + k * dir[1] >= 0 and y + k * dir[1] < len(grid[0])
    ]
    return points if len(points) == N else None


res = 0
while len(candidates) > 0:
    x, y, _ = candidates.pop()
    for dir in [(1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1)]:
        if vector := search_vector(x, y, dir, len(target)):
            if all(grid[i][j] == target[k] for k, (i, j) in enumerate(vector)):
                res += 1

print("Part 1: ", res)


# In part 2, things change and we will now use a dumbed down approach where we are checking for the corners
# of a grid surrounding every "A" we can find. Two adjacent sides have to be "M", the other sides have to be "S".
# So we will be looking for "A", start with one corner and get the next corners clockwise. The pattern has to be
# either "MSSM" or "SSMM" or "SMMS" or "MMSS".
corner_patterns = ["MSSM", "SSMM", "SMMS", "MMSS"]

res = 0
for i in range(len(grid)):
    for j in range(len(grid[0])):
        if grid[i][j] == 'A':
            corners = [(i - 1, j - 1), (i - 1, j + 1), (i + 1, j + 1), (i + 1, j - 1)]
            if all(i >= 0 and i < len(grid) and j >= 0 and j < len(grid[0]) for i, j in corners):
                corner_letters = ''.join([grid[i][j] for i, j in corners])
                if corner_letters in corner_patterns:
                    res += 1

print("Part 2: ", res)
