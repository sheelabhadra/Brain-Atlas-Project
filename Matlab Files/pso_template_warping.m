function out = pso_template_warping(problem, params, templatePoints, template, base_edge, warp_params)
    %% Problem definition
    
    nVar = 2; % Number of Unknown (Decision) variables

    VarSize = [1, nVar]; % Matrix size of Decision Variables
    
    % Check these
    VarMin = problem.VarMin; % Lower bound of Decision Variables
    VarMax = problem.VarMax; % Upper bound of Decision Variables

    %% Parameters of PSO
     
    MaxIt = params.MaxIt; % Max number of iterations
    nPop = params.nPop;   % Population size (Swarm Size) for each Control Point

    w = params.w;    % Inertia coefficient
    wdamp = params.wdamp; % Damping Ratio of Inertia Weight
    c1 = params.c1;   % Personal Acceleration coeff
    c2 = params.c2;   % Social Acceleration coeff

    ShowIterationInfo = params.ShowIterInfo;  % The flag for showing iteration information

    MaxVelocity = 0.2*(VarMax - VarMin);
    MinVelocity = -MaxVelocity;

    %% Initialization
    
    % Particle template
    empty_particle.Position = [];
    empty_particle.Velocity = [];
    empty_particle.Cost = [];
    empty_particle.Best.Cost = [];
    empty_particle.Best.Position = [];
    
    % Create population array
    particle = repmat(empty_particle, size(templatePoints, 1), nPop);
    
    % Initialize Global Best
    best_particle.Position = [];
    best_particle.Cost = inf;
    GlobalBest = repmat(best_particle, size(templatePoints, 1), 1);
    GlobalBest_cost = inf;
   
    % Paramters for the random control point generator
    rand_params.n = 1;
    rand_params.radius = 20;
    
    % Initialize the position of the swarm particles - 1 from each set
    swarmPoints = templatePoints;
    
%     C = {'c','b','r','g','y',[.5 .6 .7],[.8 .2 .6],[.2 .3 .4],[.9 .6 .2], [.7 .2 .4]};
    
%     imshow(template);
%     hold on;
    for cp=1:size(templatePoints, 1)
%         selected_particles = repmat(empty_particle, size(templatePoints, 1), 1);
        for i=1:nPop
            % Assign one of the particles = CP
            if i == 1
                particle(cp,1).Position = [templatePoints(cp,1) templatePoints(cp,2)];
            
            else
                rand_params.center = particle(cp,1).Position;

                % Generate random solution
                particle(cp,i).Position = get_rand_point(rand_params);

            end
            
%             plot(particle(cp,i).Position(1,1), particle(cp,i).Position(1,2), 'color', C{cp}, 'marker','*','LineWidth', 1, 'MarkerSize', 10);   
    
            
            % Initialize Velocity
            particle(cp,i).Velocity = zeros(VarSize);
            
            % Evaluation - Cost of particle set
            % Find the template after warping
            
            swarmPoints(cp,:) = particle(cp,i).Position;
            
            % Transformation function
            tform = fitgeotrans(swarmPoints,templatePoints,'lwm',size(templatePoints,1));
            
            % Warped template
            Wtemplate = imwarp(template,tform);
            
            % Update particle cost
            particle(cp,i).Cost = mod_EPF(Wtemplate, base_edge, warp_params.dist_EPF, warp_params.angle_EPF, warp_params.angle_EPF_template, templatePoints, swarmPoints);
            
            % Update the Personal Best
            particle(cp,i).Best.Position = particle(cp,i).Position;
            particle(cp,i).Best.Cost = particle(cp,i).Cost;

            % Update Global Best
            if particle(cp,i).Best.Cost < GlobalBest_cost
                % Add the entire particle set instead of the individual set
                % to the GlobalBest
%                 for j=1:size(templatePoints, 1)
%                     GlobalBest(j) = particle(cp,i).Best; % Change this
%                 end
                % Store the particle
                GlobalBest_particle = [cp i];
                GlobalBest_cost = particle(cp,i).Best.Cost;
            end
            
            % Reset the swarm points
            swarmPoints = templatePoints;
        end
    end
    
    % Update Global Best
    for cp=1:size(templatePoints, 1)
        if cp == GlobalBest_particle(1)
            GlobalBest(cp).Position = particle(cp, GlobalBest_particle(2)).Best.Position;
        else
            GlobalBest(cp).Position = particle(cp, 1).Best.Position;
        end
        GlobalBest(cp).Cost = GlobalBest_cost; 
    end
    
    % Array to hold Best Cost Value on each iteration
    BestCosts = zeros(MaxIt, 1);
    
    %% Main loop of PSO
    
    for it=1:MaxIt
        selected_particles = repmat(empty_particle, size(templatePoints, 1), 1);
        for cp=1:size(templatePoints, 1)
            
            % Choose a random particle in the current CP
            i = randsample(nPop, 1);
            
            particle(cp,i).Velocity = w*particle(cp,i).Velocity + ...
                c1*rand(VarSize).*(particle(cp,i).Best.Position - particle(cp,i).Position) + ...
                c2*rand(VarSize).*(GlobalBest(cp).Position - particle(cp,i).Position);

            % Apply Lower and Upper Bound Limits on Velocity
            particle(cp,i).Velocity = max(particle(cp,i).Velocity, MinVelocity);
            particle(cp,i).Velocity = min(particle(cp,i).Velocity, MaxVelocity);

            % Update Position
            particle(cp,i).Position = particle(cp,i).Position + particle(cp,i).Velocity;
            
            % Apply Lower and Upper Bound Limits on Position
            if abs(particle(cp, i).Position(1) - particle(cp, 1).Position(1)) > rand_params.radius
                if particle(cp, i).Position(1) - particle(cp, 1).Position(1) > 0
                    particle(cp, i).Position(1) =  particle(cp, 1).Position(1) + rand_params.radius;
                else
                    particle(cp, i).Position(1) =  particle(cp, 1).Position(1) - rand_params.radius;
                end
            end
            
            if abs(particle(cp, i).Position(2) - particle(cp, 1).Position(2)) > rand_params.radius
                if particle(cp, i).Position(2) - particle(cp, 1).Position(2) > 0
                    particle(cp, i).Position(2) =  particle(cp, 1).Position(2) + rand_params.radius;
                else
                    particle(cp, i).Position(2) =  particle(cp, 1).Position(2) - rand_params.radius;
                end
            end
            
            % Add the swarm particle to the collection
            selected_particles(cp) = particle(cp,i);
            
            swarmPoints(cp, :) = selected_particles(cp).Position;
        end
        
        % Find the template after warping
        tform = fitgeotrans(swarmPoints,templatePoints,'lwm',size(templatePoints,1));
        
        Wtemplate = imwarp(template,tform);
        
        % Find the modified EPF cost
        selected_particles_cost = mod_EPF(Wtemplate, base_edge, warp_params.dist_EPF, warp_params.angle_EPF, warp_params.angle_EPF_template, templatePoints, swarmPoints);
        
        % Evaluation
        for i=1:size(templatePoints,1)
            % Update the Cost of all the selected particles
            selected_particles(i).Cost = selected_particles_cost;
            
            % Update Personal Best
            if selected_particles(i).Cost < selected_particles(i).Best.Cost
                selected_particles(i).Best.Position = selected_particles(i).Position;
                selected_particles(i).Best.Cost = selected_particles(i).Cost;
            end
            
            % Update Global Best
            if selected_particles(i).Best.Cost < GlobalBest(i).Cost
                GlobalBest(i) = selected_particles(i).Best;
            end 
        end

        % Store the Best Cost Value
        BestCosts(it) = GlobalBest(1).Cost;
        
        if ShowIterationInfo
            % Display iteration information
            disp(['Iteration' num2str(it) ': Best Cost = ' num2str(BestCosts(it))]);
        end

        % Damping Inertia Coefficient
        w = w*wdamp;
        
    end

    out.BestSol = GlobalBest;
    out.BestCosts = BestCosts;
end
