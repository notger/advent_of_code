import re

code = open('data/03.dat').read()

matches = re.findall('mul\([0-9]+,[0-9]+\)', code)

def multiply(match):
    a, b = map(int, match[4:-1].split(','))
    return a * b

print(sum(multiply(m) for m in matches))


matches = re.findall("mul\([0-9]+,[0-9]+\)|do\(\)|don't\(\)", code)

factor = 1
s = 0
for m in matches:
    if m == "do()":
        factor = 1
    elif m == "don't()":
        factor = 0
    else:
        s += factor * multiply(m)


print(s)
