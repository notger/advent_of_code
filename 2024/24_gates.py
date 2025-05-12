from aocd import get_data
import networkx as nx
import matplotlib.pyplot as plt


example = """x00: 1
x01: 0
x02: 1
x03: 1
x04: 0
y00: 1
y01: 1
y02: 1
y03: 1
y04: 1

ntg XOR fgs -> mjb
y02 OR x01 -> tnw
kwq OR kpj -> z05
x00 OR x03 -> fst
tgd XOR rvg -> z01
vdt OR tnw -> bfw
bfw AND frj -> z10
ffh OR nrd -> bqk
y00 AND y03 -> djm
y03 OR y00 -> psh
bqk OR frj -> z08
tnw OR fst -> frj
gnj AND tgd -> z11
bfw XOR mjb -> z00
x03 OR x00 -> vdt
gnj AND wpb -> z02
x04 AND y00 -> kjc
djm OR pbm -> qhw
nrd AND vdt -> hwm
kjc AND fst -> rvg
y04 OR y02 -> fgs
y01 AND x02 -> pbm
ntg OR kjc -> kwq
psh XOR fgs -> tgd
qhw XOR tgd -> z09
pbm OR djm -> kpj
x03 XOR y03 -> ffh
x00 XOR y04 -> ntg
bfw OR bqk -> z06
nrd XOR fgs -> wpb
frj XOR qhw -> z04
bqk OR frj -> z07
y03 OR x01 -> nrd
hwm AND bqk -> z03
tgd XOR rvg -> z12
tnw OR pbm -> gnj

none"""

puzzle = open('data/24.dat', 'rt').read()


def visualise_network(inp):
    G = nx.Graph()

    for line in inp.splitlines():
        if '->' in line:
            words = line.split()
            in1, in2, out = words[0], words[2], words[-1]
            G.add_nodes_from([in1, in2, out])
            G.add_edge(in1, out)
            G.add_edge(in2, out)

    nx.draw(G, with_labels=True, pos=nx.spring_layout(G))
    plt.show()

#visualise_network(example)

def OR(a, b):
    return a | b

def XOR(a, b):
    return a ^ b

def AND(a, b):
    return a & b

assert XOR(1, 0) == 1
assert XOR(0, 0) == 0
assert XOR(1, 1) == 0
assert OR(1, 0) == 1
assert OR(0, 0) == 0
assert OR(1, 1) == 1

operator_lookup = {
    'OR': OR,
    'XOR': XOR,
    'AND': AND,
}


def parse(inp):
    constants_raw, equations_raw, _ = inp.split('\n\n')

    constants = {}
    for line in constants_raw.splitlines():
        name, value = line.split(': ')
        constants[name] = int(value)

    equations = {}
    targets = set()
    for line in equations_raw.splitlines():
        a, operator, b, _, out = line.split()
        equations[out] = (a, operator_lookup[operator], b)
        if out.startswith('z'):
            targets.add(out)

    return constants, equations, targets


def solve_for(target, constants, equations):
    if target in constants:
        return constants[target]

    a, operator, b = equations[target]

    return operator(solve_for(a, constants, equations), solve_for(b, constants, equations))

    #a_value = solve_for(a, constants, equations)
    #b_value = solve_for(b, constants, equations)

    #return operator(a_value, b_value)


def bit_to_num(var_name, L, constants, results):
    res = 0
    for k in range(L):
        target = f'{var_name}{k:02}'
        if target in constants:
            res += constants[target] * 2**k
        if target in results:
            res += results[target] * 2**k

    return res


def process(targets, constants, equations):
    results = {}
    for target in targets:
        results[target] = solve_for(target, constants, equations)
    return results

def solve(inp):
    constants, equations, targets = parse(inp)
    print('Part 1:', bit_to_num('z', len(targets), constants, process(targets, constants, equations)))


#solve(example)
solve(puzzle)


def solve2(inp):
    constants, equations, _ = parse(inp)
    L = len(constants) // 2
    targets = {f'z{k:02}' for k in range(L + 1)}

    results = {}
    for target in targets:
        results[target] = solve_for(target, constants, equations)

    # For each digit, starting with the first digit, find the first place where it breaks:
    for k in range(len(targets) - 1):
        constants = {key: 0 for key in constants}
        constants[f'x{k:02}'], constants[f'y{k:02}'] = 1, 1

        results = {}
        for i in range(k + 2):
            target = f'z{i:02}'
            results[target] = solve_for(target, constants, equations)

        expected = [0] * (len(results) - 1) + [1]
        actual = [results[idx] for idx in sorted(results.keys())]

        # Compare bit-wise:
        if expected != actual:
            print(f'{k+1:02}', 'exp:', expected, 'act:', actual)
            raise ValueError(k + 1)

    # If we get here, we have a solution:
    print('Solution: ', ','.join(sorted(open('data/24.dat', 'rt').read().split('\n\n')[-1].split(','))))

# The example is malformed and does not work for part 2!
solve2(puzzle)
