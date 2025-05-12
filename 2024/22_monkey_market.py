from aocd import get_data
from functools import cache
from collections import defaultdict

example = """1
10
100
2024"""

puzzle = get_data(year=2024, day=22)

def parse(inp):
    return [int(x) for x in inp.splitlines()]


@cache
def generate_secret_numbers(start: int, num: int) -> list[int]:
    res = [start]
    for k in range(num):
        res.append(next_secret_number(res[-1]))

    return res


@cache
def next_secret_number(n: int) -> int:
    s1 = (n ^ (n * 64)) % 16777216
    s2 = (s1 ^ (s1 // 32)) % 16777216
    s3 = (s2 ^ (s2 * 2048)) % 16777216
    return s3


assert len(generate_secret_numbers(123, 10)) == 11
assert generate_secret_numbers(123, 10)[-1] == 5908254


def prices_per_sequence(secret_numbers: list[int]) -> dict:
    prices = [price - 10 * (price // 10) for price in secret_numbers]
    differences = [prices[k] - prices[k - 1] for k in range(1, len(prices))]
    res = dict()

    for k in range(3, len(differences)):
        sequence = tuple(differences[k - 3:k + 1])
        if sequence not in res and sum(sequence) > 0:
            res[sequence] = prices[k + 1]

    return res


def solve(inp):
    inp = parse(inp)
    part1 = 0
    part2 = defaultdict(int)
    for k in inp:
        secret_numbers = generate_secret_numbers(k, 2000)
        part1 += secret_numbers[-1]

        for k, v in prices_per_sequence(secret_numbers).items():
            part2[k] += v

    print('Part 1:', part1)
    print('Part 2:', max(part2.values()))


solve(puzzle)
