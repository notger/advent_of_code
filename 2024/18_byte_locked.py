import networkx
import numpy as np
import matplotlib.pyplot as plt


example = """5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0"""


def parse(inp):
    return [tuple(int(x) for x in line.split(',')) for line in inp.splitlines()]


def generate_admissible_points(size=71, corrupt=None):
    points = set()
    for i in range(size):
        for j in range(size):
            if corrupt is None or (i, j) not in corrupt:
                points.add((i, j))

    return points


def convert_to_matrix(positions, max_x=7, max_y=7):
    matrix = np.zeros((max_y, max_x), dtype=int)
    for pos in positions:
        matrix[pos[1], pos[0]] += 1

    return matrix


def points_to_graph(points):
    # Create an empty undirected graph
    G = networkx.Graph()

    # Add all points as nodes to the graph
    G.add_nodes_from(points)

    # Iterate over each point in the graph
    for point in G.nodes:
        x, y = point  # Unpack the (x, y) coordinates

        # Define possible adjacent neighbors (right and up only)
        for dx, dy in [(1, 0), (0, 1), (-1, 0), (0, -1)]:
            neighbor = (x + dx, y + dy)  # Calculate neighbor coordinates

            # If the neighbor exists in the node set, add an edge with weight 1
            if neighbor in G.nodes:
                G.add_edge(point, neighbor, weight=1)

    # Return the constructed graph
    return G


def solve1(inp, steps=1024, size=71):
    broken = parse(inp)
    admissible = generate_admissible_points(size=size, corrupt=broken[:steps])

    #M = convert_to_matrix(admissible)
    #plt.matshow(M)
    #plt.show()

    G = points_to_graph(admissible)
    return len(networkx.shortest_path(G, (0, 0), (size - 1, size - 1))) - 1


def solve2(inp, start_idx=1024, size=71):
    broken = parse(inp)
    admissible = generate_admissible_points(size=size, corrupt=broken[:start_idx])

    G = points_to_graph(admissible)

    for b in broken[start_idx:]:
        admissible.remove(b)
        G.remove_node(b)

        try:
            networkx.shortest_path_length(G, (0, 0), (size - 1, size - 1))

        except networkx.exception.NetworkXNoPath:
            return b

print(solve1(example, steps=12, size=7))
print(solve1(open('data/18.dat', 'rt').read()))

print(solve2(example, start_idx=12, size=7))
print(solve2(open('data/18.dat', 'rt').read()))
