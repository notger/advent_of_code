example = """987654321111111
811111111111119
234234234234278
818181911112111""".splitlines()

puzzle = open('data/03.dat', 'rt').read().splitlines()


def find_joltage(line: str, digits: int=2) -> int:
    res = ""

    while digits > 0:
        digit = max(line[:-digits+1]) if digits > 1 else max(line)
        line = line[line.index(digit)+1:]
        res += digit
        digits -= 1

    return int(res)

assert find_joltage(example[0]) == 98
assert find_joltage(example[1]) == 89
assert find_joltage(example[2]) == 78
assert find_joltage(example[3]) == 92

assert find_joltage(example[0], digits=12) == 987654321111
assert find_joltage(example[1], digits=12) == 811111111119
assert find_joltage(example[2], digits=12) == 434234234278
assert find_joltage(example[3], digits=12) == 888911112111

def solve(inp: list[str], digits: int=2) -> int:
    return sum(find_joltage(line, digits=digits) for line in inp)

assert solve(example) == 357
assert solve(example, digits=12) == 3121910778619

print(solve(puzzle))
print(solve(puzzle, digits=12))
