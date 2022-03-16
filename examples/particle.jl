# PREAMBLE

# PKG_SETUP

# ## Setup

using IterativeLQR 
using LinearAlgebra

# ## horizon 
T = 11 

# ## acrobot 
num_state = 2
num_action = 1 

function particle(x, u, w)
   A = [1.0 1.0; 0.0 1.0]
   B = [0.0; 1.0] 
   return A * x + B * u[1]
end

# ## model
dyn = Dynamics(particle, num_state, num_action)
model = [dyn for t = 1:T-1] 

# ## initialization
x1 = [0.0; 0.0] 
xT = [1.0; 0.0]
ū = [1.0e-1 * randn(num_action) for t = 1:T-1] 
x̄ = rollout(model, x1, ū)

# ## objective 
ot = (x, u, w) -> 0.1 * dot(x, x) + 0.1 * dot(u, u)
oT = (x, u, w) -> 0.1 * dot(x, x)
ct = Cost(ot, num_state, num_action)
cT = Cost(oT, num_state, 0)
obj = [[ct for t = 1:T-1]..., cT]

# ## constraints
goal(x, u, w) = x - xT

cont = Constraint()
conT = Constraint(goal, num_state, 0)
cons = [[cont for t = 1:T-1]..., conT] 

# ## problem
prob = Solver(model, obj, cons)
initialize_controls!(prob, ū)
initialize_states!(prob, x̄)

# ## solve
solve!(prob)

# ## solution
x_sol, u_sol = get_trajectory(prob)
