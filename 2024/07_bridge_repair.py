#from aocd import get_data


example = """190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20""".splitlines()

#data = get_data(year=2024, day=7).splitlines()
data = open('data/07.dat').read().splitlines()

def parse_line(line):
    target = int(line.split(":")[0])
    parts = list(map(int, line.split(":")[1].strip().split()))
    return target, parts


def check(target, parts, with_or=False):
    if len(parts) == 1:
        return target if parts[0] == target else 0

    candidates = [(parts[0], parts[1:])]

    while len(candidates) > 0:
        val, remaining = candidates.pop(0)
        if remaining == []:
            continue

        next_part = remaining[0]

        added = val + next_part
        multed = val * next_part
        if with_or:
            or_ed = int(str(val) + str(next_part))
        else:
            or_ed = target + 1

        if added == target or multed == target or or_ed == target:
            return target
        else:
            if added < target:
                candidates.append((added, remaining[1:]))
            if multed < target:
                candidates.append((multed, remaining[1:]))
            if or_ed < target:
                candidates.append((or_ed, remaining[1:]))

    return 0


def solve(data, with_or=False):
    return sum(check(target, parts, with_or=with_or) for target, parts in map(parse_line, data))


if solve(example) == 3749:
    print("Example part 1 passed")
    print("Part1: ", solve(data))
else:
    print("Example part 1 failed:")
    print(solve(example))


if solve(example, with_or=True) == 11387:
    print("Example part 2 passed")
    print("Part2: ", solve(data, with_or=True))
else:
    print("Example part 2 failed:")
    print(solve(example))
