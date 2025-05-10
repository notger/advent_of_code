from collections import defaultdict


example = """125 17"""


def parse(inp):
    counter = defaultdict(int)
    for x in inp.split():
        counter[x] += 1

    return counter


def handle_number(number: str) -> list:
    # Takes a string containing a number and applies the rules given in the task description.
    if number == "0":
        return ["1"]
    elif len(number) % 2 == 0:
        return [str(int(number[:len(number) // 2])), str(int(number[len(number) // 2:]))]
    else:
        return [str(int(number) * 2024)]


def step(numbers: dict) -> dict:
    new_numbers = defaultdict(int)
    for number, count in numbers.items():
        res = handle_number(number)
        for r in res:
            new_numbers[r] += count

    return new_numbers


def solve1(inp, N):
    numbers = parse(inp)
    for _ in range(N):
        numbers = step(numbers)

    print(sum(numbers.values()))


print('Part 1:')
solve1(example, 25)
solve1(open('data/11.dat').read(), 25)
print()
print('Part 2:')
solve1(open('data/11.dat').read(), 75)
