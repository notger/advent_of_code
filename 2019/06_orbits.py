from collections import defaultdict


example = """COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L""".splitlines()


example2 = """COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
K)YOU
I)SAN""".splitlines()


def construct_orbits(inp):
    orbits = defaultdict(list)
    for line in inp:
        l, r = line.strip().split(")")
        orbits[l].append(r)

    return orbits


def count_orbits(orbits):
    candidates = orbits['COM']

    ctr = 0
    level = 1
    while candidates:
        ctr += level * len(candidates)

        candidates = [orbit for c in candidates for orbit in orbits[c] if c in orbits.keys()]
        level += 1

    return ctr


def has_upstream_links_to(orbits, origin, target):
    # Lets create a map of satellites and what they orbit around:
    satellites = {v: k for k, l in orbits.items() for v in l}

    cur = origin
    chain = []
    while cur != 'COM':
        chain.append(satellites[cur])
        cur = satellites[cur]

    return set(chain[::-1])


print('Part 1 example:', count_orbits(construct_orbits(example)))
print('Part 1 puzze:', count_orbits(construct_orbits(open('data/06.dat').readlines())))


def solve2(inp):
    chain1, chain2 = has_upstream_links_to(inp, 'SAN', 'COM'), has_upstream_links_to(inp, 'YOU', 'COM')
    return len(chain1) + len(chain2) - 2 * len(chain1.intersection(chain2))


print('Part 2 example:', solve2(construct_orbits(example2)))
print('Part 1 puzze:', solve2(construct_orbits(open('data/06.dat').readlines())))