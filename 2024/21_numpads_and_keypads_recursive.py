from functools import cache
from itertools import pairwise
from collections import defaultdict


example = """029A
980A
179A
456A
379A"""

puzzle = """540A
839A
682A
826A
974A"""


num_pad = {
    '7': (0, 0), '8': (0, 1), '9': (0, 2),
    '4': (1, 0), '5': (1, 1), '6': (1, 2),
    '1': (2, 0), '2': (2, 1), '3': (2, 2),
    '0': (3, 1), 'A': (3, 2)
}

directions = {
    '^': (-1, 0), 'v': (1, 0), '<': (0, -1), '>': (0, 1),
}
directions.update({v: k for k, v in directions.items()})

key_pad = {
    '^': (0, 1), 'A': (0, 2),
    '<': (1, 0), 'v': (1, 1), '>': (1, 2),
}


def layout_tuple_paths(start: str, end: str, layout=num_pad):
    # Creates all paths from one value to another, depending on the layout. It does NOT add an 'A' at the end.
    s, e = layout[start], layout[end]
    allowed_directions = [(0, 1 if e[1] > s[1] else -1), (1 if e[0] > s[0] else -1, 0)]

    candidates = [(s, [])]
    max_len = 1000
    valid_paths = defaultdict(list)

    if start == end:
        return [[]]

    while candidates:
        (x, y), movements = candidates.pop()

        for dx, dy in allowed_directions:
            movement = directions[(dx, dy)]  # Will contain a char-like direction
            new_x, new_y = x + dx, y + dy

            # We reached the end:
            if (new_x, new_y) == e and len(movements) + 1 <= max_len:
                max_len = len(movements) + 1
                valid_paths[max_len].append(movements + [movement])
                continue

            # We did not reach the end yet, but we are not out of bounds:
            if (new_x, new_y) in layout.values() and len(movements) + 1 <= max_len:
                candidates.append(((new_x, new_y), movements + [movement]))

    return valid_paths[max_len]

# Generate the lookups to be used from here on:
all_num_pad_tuple_paths = {
    f'{start}{end}': [''.join(l + ['A']) for l in layout_tuple_paths(start, end, layout=num_pad)] for start in num_pad.keys() for end in num_pad.keys()
}
all_key_pad_tuple_paths = {
    f'{start}{end}': [''.join(l + ['A']) for l in layout_tuple_paths(start, end, layout=key_pad)] for start in key_pad.keys() for end in key_pad.keys()
}
all_tuple_paths = {'num_pad': all_num_pad_tuple_paths, 'key_pad': all_key_pad_tuple_paths}


@cache
def minimal_cost_from_start_to_end(pad_type: str, start: str, end: str, iteration):
    # Returns the minimum of the cost between two points in a keypad layout.
    # The key here is that we are at iteration 0, and our cost to press any button is 1.
    return min(
        cost_of_sequence('key_pad', path, iteration - 1) for path in all_tuple_paths[pad_type][start + end]
    ) if iteration else 1


@cache
def cost_of_sequence(keypad, sequence, links):
    return sum(minimal_cost_from_start_to_end(keypad, a, b, links)
               for a, b in pairwise('A' + sequence))


def score(code, robots):
    return cost_of_sequence('num_pad', code, robots + 1) * int(code[:-1])


print(sum(score(code, 0) for code in example.splitlines()))
print(sum(score(code, 2) for code in puzzle.splitlines()))
print(sum(score(code, 25) for code in puzzle.splitlines()))

