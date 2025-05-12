from collections import Counter

# This is ugly brute force, but runs quick enough, so who cares. Dev time is expensive. ;)
def solve(low=168630, high=718098):
    def is_valid(nums: list[str]):
        return len(set(nums)) < 6 and all(nums[k+1] >= nums[k] for k in range(len(nums)-1))

    candidates = [k for k in range(low, high) if is_valid(list(str(k)))]

    return len(candidates), sum(1 for candidate in candidates if 2 in Counter(str(candidate)).values())


print(list(zip(['Part 1', 'Part 2'], solve())))
