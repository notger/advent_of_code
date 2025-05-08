import numpy as np
from collections import Counter

locations = open('data/01.dat').read().splitlines()

left, right = zip(*[location.split() for location in locations])

left = np.sort(np.array([int(l) for l in left], dtype=int))
right = np.sort(np.array([int(r) for r in right], dtype=int))

print(np.abs(left - right).sum())


# Part 2:
ctr = Counter(right)

print(ctr.get('asd', 0))
print(sum(
    [l * ctr.get(l, 0) for l in left]
))