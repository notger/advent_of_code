from aocd import get_data

def fuel(x, loop=False):
    return fuel(dx * int(loop), loop) + dx if (dx := x // 3 - 2) > 0 else 0

print(sum([fuel(int(x)) for x in get_data(year=2019, day=1).splitlines()]))
print(sum([fuel(int(x), loop=True) for x in get_data(year=2019, day=1).splitlines()]))
