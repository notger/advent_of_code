# Recursive, wrong version which finds the number of words if the words could change direction.
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


def search_for_next_letter(L: str, x: int, y: int):
    res = 0
    print(f"\n Searching for next letter from {L} at position {(x, y)}")
    if len(L) > 1:
        letter, rest = L[0], L[1:]
        if grid[x][y] == letter:
            print('letter found')
            for i in [x - 1, x, x + 1]:
                for k in [y - 1, y, y + 1]:
                    if i >= 0 and i < len(grid) and k >= 0 and k < len(grid[0]) and (i, k) != (x, y):
                        res += search_for_next_letter(rest, i, k)
    elif len(L) == 1:
        print(f'Down to the last letter, looking for {L} at {x, y}: {grid[x][y]}')
        return 1 if grid[x][y] == L[0] else 0

    return res

res = 0
for i in range(len(grid)):
    for k in range(len(grid[0])):
        res += search_for_next_letter('XMAS', i, k)

print(res)
