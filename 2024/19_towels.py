import aocd
from tqdm import tqdm
from functools import cache

example = """r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb"""

data = aocd.get_data(year=2024, day=19)


def parse(inp):
    towels, patterns = inp.replace(" ", "").split("\n\n")
    return tuple(towels.split(',')), patterns.splitlines()


@cache
def fits_pattern(towels: tuple, pattern: str) -> int:
    if not pattern:
        return 1

    else:
        return sum(
            fits_pattern(towels, pattern[len(towel):])
            for towel in towels if pattern.startswith(towel)
        )


def solve(inp):
    towels, patterns = parse(inp)
    res = [fits_pattern(towels, pattern) for pattern in tqdm(patterns)]
    print("Part 1:", sum(1 for x in res if x > 0))
    print("Part 2:", sum(res))


solve(data)