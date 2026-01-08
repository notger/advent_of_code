# Gonna use this to solve LP
import re
from pulp import LpMinimize, LpProblem, LpVariable, value, lpSum
 
 
 
def solve_machine(buttons, joltage): 
    prob = LpProblem('Machine Problem', LpMinimize)
    variables = [LpVariable(f"x_{i}", lowBound=0, cat="Integer") for i in range(len(buttons))]
    prob += lpSum(variables[i] for i in range(len(variables))), "Objective"
    for i in range(len(joltage)):
        currVars = []
        for j in range(len(buttons)):
            if(i in buttons[j]):
                currVars.append(variables[j])
        prob += lpSum(currVars[i] for i in range(len(currVars))) == joltage[i], f"Constraint_{i}"
        # print(currVars, ",", joltage[i])
    prob.solve()
    ans = 0
    for v in variables:
        ans += v.value()
    # print(buttons, joltage)
    return ans
 
def main(): 
    ans = 0
    with open('data/10.dat', 'r') as f:
        for line in f.readlines():
            button_matches = re.findall(r'\((.*?)\)', line)
            buttons = [list(map(int, b.split(','))) for b in button_matches]
 
            voltage_match = re.search(r'\{(.*?)\}', line)
            voltages = list(map(int, voltage_match.group(1).split(','))) if voltage_match else []
            ans += solve_machine(buttons, voltages)
    print(ans)
 
 
if __name__ == '__main__':
    main()