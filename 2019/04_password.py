from collections import Counter

# This is ugly, but runs rather fast, so who cares. Dev time is expensive. ;)
def brute_force(low=168630, high=718098):
    candidates = []

    for k in range(low, high):
        nums = list(str(k))
        if len(set(nums)) < 6 and all(nums[k+1] >= nums[k] for k in range(len(nums)-1)):
            candidates.append(k)

    num_part2 = 0
    for candidate in candidates:
        ctr = Counter(str(candidate))
        if 2 in ctr.values():
            num_part2 += 1

    return len(candidates), num_part2


print(brute_force())
