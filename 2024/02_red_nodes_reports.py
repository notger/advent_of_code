import numpy as np

reports = [[int(e) for e in l.split()] for l in open('data/02.dat').read().splitlines()]

def gte(a, b):
    return a > b

def lte(a, b):
    return a < b

def close(a, b):
    return abs(a - b) <= 3

def is_safe(report):
    sign = gte if report[1] - report[0] > 0 else lte

    for i in range(1, len(report)):
        if not close(report[i], report[i - 1]) or not sign(report[i], report[i - 1]):
            return False

    return True

print("Part 1:", sum([is_safe(report) for report in reports]))


def repair(report):
    for r in range(len(report)):
        candidate = report[:]
        _ = candidate.pop(r)
        if is_safe(candidate):
            return candidate

    return None

s = 0
for report in reports:
    try:
        if is_safe(report):
            s += 1
        else:
            if repaired := repair(report):
                if is_safe(repaired):
                    s += 1
    except:
        print(report)

print("Part 2:", s)
