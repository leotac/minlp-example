### SETS
set T := 1..24 circular;

### PARAMS

# Demands
param req_q{t in T}; 
param req_u{t in T}; 

# Time-sensitive market price for q
param q_cost{t in T};
param q_selling_price{t in T};

param fixed_cost;
param x_cost; 

# Function coefficients 
param u_coef{i in 1..6};
param q_coef{i in 1..6};

# Storage (with constant loss rate)
param max_stored;
param loss_percentage;

# Bounds
param min_x;
param max_x;
param min_q{t in T};
param max_q{t in T};
param min_u{t in T};
param max_u{t in T};

# Functions f,g are actually 'time-varying': 
# production efficiency depends also on t via auxiliary parameter alpha[t]
# f(x;t) g(x;t)
param alpha{t in T}; 


## VARIABLES

# input/production variables
var x{t in T} >= 0, <= max_x;
var q{t in T} >= 0, <= max_q[t];
var u{t in T} >= 0, <= max_u[t];

# q sold/back-ordered
var q_sold{t in T} >= 0, <= max_q[t]; 
var q_bought{t in T} >= 0, <= req_q[t]; 

var s{t in T}>=0, <= max_stored;
var z{t in T} binary;


## OBJECTIVE FUNCTION

minimize total_cost: 
   sum{t in T}(x_cost*x[t] + fixed_cost*z[t] 
               + q_cost[t]*q_bought[t] - q_selling_price[t]*q_sold[t]);


## CONSTRAINTS

# Balance
subject to u_balance{t in T}:
   u[t] + (s[t]*(1 - loss_percentage)- s[next(t)]) >= req_u[t];

subject to q_balance{t in T}:
   q[t] + q_bought[t] - q_sold[t] = req_q[t];

# Activation
subject to x_lb{t in T}:
   z[t]*min_x <= x[t];
subject to x_ub{t in T}:
   x[t] <= z[t]*max_x;

subject to q_lb{t in T}:
    z[t]*min_q[t] <= q[t];
subject to q_ub{t in T}:
    q[t] <= z[t]*max_q[t];

subject to u_lb{t in T}:
    z[t]*min_u[t] <= u[t];
subject to u_ub{t in T}:
    u[t] <= z[t]*max_u[t];

# Nonlinear production
# u[t] <= z[t]*g(x[t];t)
subject to u_production{t in T}:
    u[t] <= z[t]*(u_coef[1] + u_coef[2]*alpha[t] + u_coef[3]*x[t]
    + u_coef[4]*alpha[t]*alpha[t] + u_coef[5]*alpha[t]*x[t]
    + u_coef[6]*x[t]*x[t]);

# q[t] <= z[t]*f(x[t];t)
subject to q_production{t in T}:
    q[t] <= z[t]*(q_coef[1] + q_coef[2]*alpha[t] + q_coef[3]*x[t]
    + q_coef[4]*alpha[t]*alpha[t] + q_coef[5]*alpha[t]*x[t]
    + q_coef[6]*x[t]*x[t]);

# Cutting plane
subject to cutting_plane{t in T}:
   q[t] <= x[t]*(max_q[t]/max_x);


