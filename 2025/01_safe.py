from functools import cache


lines = [l.strip('\n') for l in open('data/01.dat', 'rt').readlines()]
example = """L68
L30
R48
L5
R60
L55
L1
L99
R14
L82
""".splitlines()


@cache
def turn(start: int, code: str) -> tuple[int, int, int]:
    target, zero_hits, cross_overs = 0, 0, 0
    if len(code) > 3:
        full_turns = int(code[1:len(code) - 2])
        rest = int(code[len(code) - 2:])
    else:
        full_turns = 0
        rest = int(code[1:])
    
    sign = 1 if code[0] == 'R' else -1

    cross_overs += full_turns

    target = start + sign * rest

    if target > 100:
        target -= 100
        cross_overs += 1
    
    elif target == 100:
        target = 0
        zero_hits += 1

    elif target < 0:
        target += 100
        if start != 0:
            cross_overs += 1

    elif target == 0:
        zero_hits += 1
        if start == 0 and full_turns > 0:
            cross_overs -= 1

    return target, zero_hits, cross_overs


assert turn(50, 'R5') == (55, 0, 0)
assert turn(50, 'R55') == (5, 0, 1)
assert turn(50, 'R50') == (0, 1, 0)
assert turn(50, 'L55') == (95, 0, 1)
assert turn(50, 'L50') == (0, 1, 0)
assert turn(50, 'L250') == (0, 1, 2)
assert turn(50, 'R250') == (0, 1, 2)
assert turn(40, 'R12345') == (85, 0, 123)
assert turn(0, 'R10') == (10, 0, 0)
assert turn(0, 'L10') == (90, 0, 0)
assert turn(0, 'R310') == (10, 0, 3)
assert turn(0, 'L310') == (90, 0, 3)
assert turn(0, 'R300') == (0, 1, 2)
assert turn(0, 'L300') == (0, 1, 2)


def part1(lines):
    start = 50
    res1, res2 = 0, 0
    for line in lines:
        #print(f'Start {start} + {line} ({len(line)}) = {turn(start, line)}')
        start, hits, cross_overs = turn(start, line)
        res1 += hits
        res2 += cross_overs

    print(f"Part 1: {res1}, part 2: {res1 + res2}")


part1(example)
part1(lines)