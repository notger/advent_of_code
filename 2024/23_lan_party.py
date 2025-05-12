import networkx as nx
from aocd import get_data
from collections import defaultdict


example = """kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn
"""


puzzle = get_data(year=2024, day=23)


def parse(inp):
    nodes = defaultdict(list)
    for line in inp.splitlines():
        a, b = line.split('-')
        nodes[a].append(b)
        nodes[b].append(a)

    return nodes


def find_threeways(nodes: dict):
    res = set()
    # For each node, check if the connections this node has at least two nodes which are also
    # in the original node connections.
    for a in nodes:
        for b in nodes[a]:
            for c in nodes[b]:
                if c in nodes[a]:
                    res.add(tuple(sorted([a, b, c])))

    return res


# The following works but is too expensive and slow. As usual, a recursive version would have been better.
# Or doing the Bron-Kerbosch-algorithm myself.
def find_largest(nodes: dict):
    networks_in_the_race = [(2, x, y) for x in nodes for y in nodes[x] if x != y]

    final_networks = set()

    while networks_in_the_race:
        L, *candidate = networks_in_the_race.pop()
        for node in nodes[candidate[0]]:
            if node in candidate:
                continue

            if set(candidate).issubset(nodes[node]):
                networks_in_the_race.append((L + 1, *candidate, node))

            else:
                final_networks.add(tuple(candidate))

    L = max([len(x) for x in final_networks])

    return [x for x in final_networks if len(x) == L][0]


def find_largest_nx(nodes: dict):
    G = nx.Graph()
    G.add_nodes_from(nodes.keys())

    for node in nodes:
        G.add_edges_from([(node, x) for x in nodes[node]])

    clique = max(nx.find_cliques(G), key=len)

    return clique


def solve(inp):
    nodes = parse(inp)
    sub_graphs = find_threeways(nodes)

    part1 = 0
    for a, b, c in sub_graphs:
        if a.startswith('t') or b.startswith('t') or c.startswith('t'):
            part1 += 1

    print(part1)

    part2 = sorted(find_largest_nx(nodes))

    print(','.join(part2))


solve(example)
solve(puzzle)
