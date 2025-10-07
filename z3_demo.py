from z3 import *

# --- User Input ---
try:
    budget = int(input("Enter your total budget (e.g., 40): "))
except ValueError:
    print("Invalid input. Please enter a number.")
    exit()

# --- Define variables ---
meat = Int('meat')
milk = Int('milk')
bread = Int('bread')
veggies = Int('veggies')

# --- Create solver ---
s = Solver()

# --- Define Boolean labels for constraints ---
A = Bool('budget_constraint')
B1 = Bool('milk_requirement')
B2 = Bool('bread_requirement')
B3 = Bool('veggies_requirement')
C = Bool('non_negative')
D = Bool('meat_requirement')

# --- Add constraints with tracking ---
s.assert_and_track(meat >= 0, C)
s.assert_and_track(milk >= 1, B1)
s.assert_and_track(bread >= 1, B2)
s.assert_and_track(veggies >= 1, B3)

# --- Prices ---
price_meat = 10
price_milk = 3
price_bread = 2
price_veggies = 4

# --- Budget constraint ---
s.assert_and_track(price_meat * meat + price_milk * milk +
                   price_bread * bread + price_veggies * veggies <= budget, A)

# --- Example goal: require at least 5 meats ---
s.assert_and_track(meat >= 5, D)

# --- Solve ---
if s.check() == sat:
    m = s.model()
    total_cost = (price_meat * m[meat].as_long() +
                  price_milk * m[milk].as_long() +
                  price_bread * m[bread].as_long() +
                  price_veggies * m[veggies].as_long())

    print("\n✅ Solution found:")
    print(f"  Meat:    {m[meat]} units")
    print(f"  Milk:    {m[milk]} units")
    print(f"  Bread:   {m[bread]} units")
    print(f"  Veggies: {m[veggies]} units")
    print(f"  Total cost: ${total_cost} (Budget: ${budget})")

else:
    print("\n❌ No solution found.")

    core = s.unsat_core()
    print("⚠️  Conflicting constraints:")

    explanations = {
        A: "Budget constraint — you don't have enough money.",
        B1: "Milk requirement — need at least one unit of milk.",
        B2: "Bread requirement — need at least one unit of bread.",
        B3: "Veggie requirement — need at least one unit of veggies.",
        C: "Non-negative constraint — cannot buy negative items.",
        D: "Meat requirement — required minimum amount of meat cannot be met."
    }

    for c in core:
        if c in explanations:
            print(f"  - {explanations[c]}")
        else:
            print(f"  - Unknown constraint: {c}")
