% rng default % For reproducibility

%% Problem definition
problem.nVar = 2; % Number of Unknown (Decision) variables

VarSize = [1, problem.nVar]; % Matrix size of Decision Variables

problem.VarMin = -10; % Lower bound of Decision Variables
problem.VarMax = 10; % Upper bound of Decision Variables

base_edge = imread('base_outer_edge.jpg');
template = imread('outer_edge.jpg');

%% Parameters of PSO
kappa = 1;
phi1 = 2.05;
phi2 = 2.05;
phi = phi1 + phi2;
chi = 2*kappa/(abs(2-phi-sqrt(phi^2 - 4*phi)));

params.MaxIt = 200; % Max number of iterations
params.nPop = 5;   % Population size (Swarm Size)

params.w = chi;    % Inertia coefficient
params.wdamp = 1; % Damping Ratio of Inertia Weight
params.c1 = chi*phi1;   % Personal Acceleration coeff
params.c2 = chi*phi2;   % Social Acceleration coeff
params.ShowIterInfo = true;

warp_params.dist_EPF = outer_epf;
warp_params.angle_EPF = outer_angle_epf;
warp_params.angle_EPF_template = angle_EPF_template;

%% Calling PSO
out = pso_template_warping(problem, params, templatePoints, template, warp_params);

BestSol = out.BestSol;
BestCosts = out.BestCosts;

%% Results
figure;
semilogy(BestCosts, 'LineWidth', 2);
xlabel('Iterations');
ylabel('BestCost');
grid on;