N_rows, N_cols = 7, 5
layouts = [layout.replace('\n', '') for layout in open('data/25.dat', 'rt').read().split('\n\n')]

locks = [[sum([1 for i in range(N_rows) if layout[k + N_cols * i] == '#']) - 1 for k in range(N_cols)] for layout in layouts if layout.startswith('#')]
keys = [[sum([1 for i in range(N_rows) if layout[k + N_cols * i] == '#']) - 1 for k in range(N_cols)] for layout in layouts if layout.startswith('.')]
print(sum(1 for lock in locks for key in keys if all(sum(both) <= 5 for both in zip(lock, key))))
