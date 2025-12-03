from math import ceil
from re import match


example = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124".split(',')
tuples = open('data/02.dat').read().strip('\n').split(',')


def num_sillys(pair: str, num_paddings: int=0, low_limit: int=0, high_limit: int=0) -> int:
    left0, right0 = pair.split('-')
    res = []
    num_digits_left, num_digits_right = len(left0), len(right0)
    if low_limit == 0 and high_limit == 0:
        low_limit, high_limit = int(left0), int(right0)

    for num_digits in range(num_digits_left, num_digits_right + 1):
        # We can not have silly numbers when we have an uneven number of digits.
        if num_digits % 2:
            continue

        if num_digits > num_digits_left:
            left = "1" + "0" * (num_digits - 1)
        else:
            left = left0

        if num_digits < num_digits_right:
            right = "9" * len(left)
        else:
            right = right0

        # A silly number has to be equal or higher than the first half of the lower range value,
        # and lower than or equal to the first half of the higher range value and if equal to it, 
        # then at least lower than or equal to the latter half of the higher range value, in order to fit in.
        # There is a corner case for the first numbers to check, where there can only be a candidate if
        # the second half of the lower value is lower than the first half.
        # Any number which fits this criterion and has the same number of digits is a candidate.
        L1, L2 = int(left[:num_digits//2]), int(left[num_digits//2:])
        H1, H2 = int(right[:num_digits//2]), int(right[num_digits//2:])

        # Determine the search boundaries:
        low = L1 if L1 >= L2 else L1 + 1
        high = H1 if H1 <= H2 else H1 - 1

        if low > high:
            continue

        # Construct all candidates:
        nums = [int(str(k) + str(k) * num_paddings + str(k)) for k in range(low, high + 1)]
        nums = [n for n in nums if low_limit <= n <= high_limit]
        res += nums
    
    return res

assert sum(num_sillys(("1698522-1698528"))) == 0
assert sum(num_sillys(("123-999"))) == 0
assert sum(num_sillys(("11-22"))) == 33
assert sum(num_sillys("95-115")) == 99
assert sum(num_sillys("998-1012")) == 1010
assert sum(num_sillys("1188511880-1188511890")) == 1188511885
assert sum(num_sillys("222220-222224")) == 222222
assert sum(num_sillys("1698522-1698528")) == 0
assert sum(num_sillys("11-199")) == 495
assert sum(num_sillys("38593856-38593862")) == 38593859
assert sum(num_sillys("1212-1212")) == 1212
assert sum(num_sillys("11-22", num_paddings=1, low_limit=111, high_limit=222)) == 333
assert sum(num_sillys("99-112", num_paddings=2, low_limit=9900, high_limit=11200)) == 9999
assert sum(num_sillys("5600-5699", num_paddings=1, low_limit=565653, high_limit=565659)) == 565656


def part1(inp):
    return sum([sum(num_sillys(line)) for line in inp])

assert part1(example) == 1227775554

def part2(inp):
    # For this part, we will take a front chunk and end chunk, based on the chunk-length we want
    # to subdivide the number in. Then we will feed the front chunk (potentially rounded up to the next
    # lowest value of the same length as chunks) and filled up with zeros and the end chunk filled up 
    # with nines into the system above. We have to specify the number of paddings and the actual
    # low and high number applicable.

    res = 0

    for line in inp:
        nums = []
        left, right = line.split('-')
        max_len_of_chunk = ceil(len(right) / 2)

        for chunk_length in range(1, max_len_of_chunk + 1):
            if chunk_length == 1:
                lower_limit, upper_limit = int(left), int(right)
                for k in range(1, 10):
                    candidates = [int(str(k) * len(left)), int(str(k) * len(right))]
                    nums += [c for c in candidates if lower_limit <= c <= upper_limit]
            else:
                # If the length of both left and right is not divisible by the chunk-length,
                # then we can not split this up like this and have to continue:
                if len(left) % chunk_length and len(right) % chunk_length:
                    continue

                # Extract the front and back and create a new input:
                back = right[:chunk_length] + "9" * chunk_length

                # Do we have to fill up the front chunk?
                if chunk_length == 1:
                    front = left[0]
                elif len(left) % chunk_length:
                    front = "1" + "0" * (2 * chunk_length - 1)
                else:
                    front = left[:chunk_length] + "0" * chunk_length

                num_paddings = ceil(len(right) / chunk_length) - 2
                nums += num_sillys(f"{front}-{back}", num_paddings=num_paddings, low_limit=int(left), high_limit=int(right))

        # Clean up BS:
        nums = [n for n in nums if n > 10]

        # Someone else's more elegant code:
        check = [num for num in range(int(left), int(right) + 1) if match(r'^(\d+)\1+$', str(num))]

        assert set(nums) == set(check), f"Numbers differ for {line}: {nums} vs. {check} <- correct"

        res += sum(set(nums))

    return res

assert part2(["565653-565659"]) == 565656
assert part2(["2121212118-2121212124"]) == 2121212121
assert part2(["95-115"]) == 99 + 111
assert part2(["824824821-824824827"]) == 824824824
assert part2(example) == 4174379265

print(f"Part 1: {part1(tuples)}")
print(f"Part 2: {part2(tuples)}")


# Someone else's solution just to double-check:
# Hate to say it, but this solution is superior in any way for the task at hand.
num_ranges = [[int(k) for k in entry.split('-')] for entry in tuples]

print(sum([sum([num for num in range(a, b + 1) if match(r'^(\d+)\1$', str(num))]) for a, b in num_ranges]))
print(sum([sum([num for num in range(a, b + 1) if match(r'^(\d+)\1+$', str(num))]) for a, b in num_ranges]))