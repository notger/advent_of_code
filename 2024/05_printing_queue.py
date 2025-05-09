input = """47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47"""

input = open('data/05.dat').read()


rules = []
updates = []
for line in input.splitlines():
    if '|' in line:
        rules.append(list(map(int, line.split('|'))))
    elif ',' in line:
        updates.append(list(map(int, line.split(','))))


def is_correctly_ordered(update, rules):
    for rule in rules:
        left, right = rule
        if left in update and right in update:
            if not (update.index(left) < update.index(right)):
                return False
    return True


def get_middle(update):
    return update[len(update) // 2]


print("Part 1: ", sum(get_middle(update) for update in updates if is_correctly_ordered(update, rules)))


def order_pages(pages):
    # Create the applicable rule set:
    local_rule_set = []
    for rule in rules:
        left, right = rule
        if left in pages and right in pages:
            local_rule_set.append(rule)

    while not is_correctly_ordered(pages, local_rule_set):
        for rule in local_rule_set:
            left, right = rule
            left_at, right_at = pages.index(left), pages.index(right)
            while left_at > right_at:
                _ = pages.pop(pages.index(right))
                pages.insert(left_at + 1, right)
                left_at, right_at = pages.index(left), pages.index(right)

    return pages

print("Part 2: ", sum(get_middle(order_pages(update)) for update in updates if not is_correctly_ordered(update, rules)))
