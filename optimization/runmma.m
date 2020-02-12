function history = runmma(x0,obj,nonlcon)
%
% Perform the optimization using MMA
%
global OPT GEOM FE


% Initialize history object
history.x = [];
history.fval = [];
history.fconsval = [];

% Initialize lower and upper bounds vectors
if OPT.options.dv_scaling   % Eq. (33)
    lb_point = zeros(FE.dim,1);
    ub_point = ones(FE.dim,1);
    lb_radius = 0;
    % Consider case when max_bar_radius and min_bar_radius are
    % the same (when bars are of fixed radius)
    if GEOM.max_bar_radius - GEOM.min_bar_radius < 1e-12
        ub_radius = 0;
    else
        ub_radius = 1;
    end
else
    lb_point = FE.coord_min;            % Eq. (18)
    ub_point = FE.coord_max;            % Eq. (18)
    lb_radius = GEOM.min_bar_radius;    % Eq. (19)
    ub_radius = GEOM.max_bar_radius;    % Eq. (19)
end
lb_size = 0;    % Eq. (20)
ub_size = 1;    % Eq. (20)

lb_bar = [lb_point;lb_point;lb_size;lb_radius];
ub_bar = [ub_point;ub_point;ub_size;ub_radius];

lb = zeros(size(OPT.dv)); 
ub = zeros(size(OPT.dv)); 
lb(OPT.bar_dv) = repmat(lb_bar,1,GEOM.n_bar);
ub(OPT.bar_dv) = repmat(ub_bar,1,GEOM.n_bar);


%
ncons = OPT.functions.n_func - 1;  % Number of optimization constraints
ndv = OPT.n_dv; % Number of design variables

% Initialize vectors that store current and previous two design iterates
x = x0;
xold1 = x0; 
xold2 = x0;

% Initialize move limits 
ml_step = OPT.options.move_limit * abs(ub - lb);  % Compute move limits once

% Initialize lower and upper asymptotes
low = lb;
upp = ub;

% These are the MMA constants (Svanberg, 1998 DACAMM Course)
c = 1000*ones(ncons,1);
d = ones(ncons,1);
a0 = 1;
a = zeros(ncons, 1);

% Evaluate the initial design and print values to screen 
iter = 0;
[f0val , df0dx] = obj(x);
[fval, ~, dfdx, ~] = nonlcon(x);
dfdx = dfdx';
fprintf('It. %i, Obj= %-12.5e, ConsViol = %-12.5e\n', ...
    iter, f0val, max(max(fval, zeros(ncons,1))));

%%%
% Save initial design to history
history.fval = [history.fval; f0val];
history.fconsval = [history.fconsval; fval];
history.x = [history.x x(:)];

%%%
% Plot initial design 
plotfun(iter);
          
%%%% Initialize stopping values
kktnorm = OPT.options.kkt_tol*10;
dv_step_change = 10*OPT.options.step_tol;
%
% ******* MAIN MMA LOOP STARTS *******
%
while kktnorm > OPT.options.kkt_tol && iter < OPT.options.max_iter && ...
        dv_step_change > OPT.options.step_tol

    iter = iter+1;

    % Impose move limits by modifying lower and upper bounds passed to MMA
    % Eq. (33)
    mlb = max(lb, x - ml_step);
    mub = min(ub, x + ml_step);


    %%%% Solve MMA subproblem for current design x
    [xmma,ymma,zmma,lam,xsi,eta,mu,zet,s,low,upp] = ...
    mmasub(ncons,ndv,iter,x,mlb,mub,xold1, ...
           xold2, f0val,df0dx,fval,dfdx,low,upp,a0,a,c,d);

    %%%% Updated design vectors of previous and current iterations
    xold2 = xold1;
    xold1 = x;
    x  = xmma;
    
    % Update function values and gradients
    [f0val , df0dx] = obj(x);
    [fval, ~, dfdx, ~] = nonlcon(x);
    dfdx = dfdx';
    
    % Compute change in design variables
    % Check only after first iteration
    if iter > 1
        dv_step_change = norm(x - xold1);
        if dv_step_change < OPT.options.step_tol
            fprintf('Design step convergence tolerance satisfied.\n');
        end
    end
    if iter == OPT.options.max_iter
        fprintf('Reached maximum number of iterations.\n');
    end    
    
    % Compute norm of KKT residual vector
    [residu,kktnorm,residumax] = ...
    kktcheck(ncons,ndv,xmma,ymma,zmma,lam,xsi,eta,mu,zet,s, ...
           lb,ub,df0dx,fval,dfdx,a0,a,c,d);
    
    % Produce output to screen
    fprintf('It. %i, Obj= %-12.5e, ConsViol = %-12.5e, KKT-norm = %-12.5e, DV norm change = %-12.5e\n', ...
        iter, f0val, max(max(fval, zeros(ncons,1))), kktnorm, dv_step_change);
    
    % Save design to .mat file
    [folder, baseFileName, ~] = fileparts(GEOM.initial_design.path);
    mat_filename = fullfile(folder, strcat(baseFileName, '.mat'));
    save(mat_filename, 'GEOM');
    
    % Write to vtk file if requested.  
    if strcmp(OPT.options.write_to_vtk, 'all')
        writevtk(OPT.options.vtk_output_path, 'dens', iter);
    end    
    
    % Update history
    history.fval = [history.fval; f0val];
    history.fconsval = [history.fconsval; fval];
    history.x = [history.x x(:)];
    
    % Plot current design
    plotfun(iter);
%
end

% Write vtk for final iteration if requested
if strcmp(OPT.options.write_to_vtk, 'all') || ...
        strcmp(OPT.options.write_to_vtk, 'last')
    writevtk(OPT.options.vtk_output_path, 'dens', iter);
end 

% ============================================


    function plotfun(iter)
        % Note that this function has a slightly different format than its
        % equivalent for fmincon.
        
        if OPT.options.plot == true
            figure(1)
            plot_design(1)
            title(sprintf('design, iteration = %i',iter))
            axis equal
            xlim([FE.coord_min(1), FE.coord_max(1)])
            ylim([FE.coord_min(2), FE.coord_max(2)])
            if FE.dim == 2
                view(2)
            else
                zlim([FE.coord_min(3), FE.coord_max(3)])
                view([50,22])
            end
            if iter==0
                pos1 = get(gcf,'Position'); % get position of fig 1
                % This assume Matlab places figure centered at center of
                % screen
                fig1_x = pos1(1);       % fig1_y = pos1(2); 
                fig1_width = pos1(3);   % fig1_height = pos1(4);
                % Shift position left by half figure width
                set(gcf,'Position', pos1 - [fig1_width/2,0,0,0]) % Shift position of Figure(1) 
            end
            
            figure(2)
            plot_density(2)
            axis equal
            xlim([FE.coord_min(1), FE.coord_max(1)])
            ylim([FE.coord_min(2), FE.coord_max(2)])
            if FE.dim == 2
                view(2)
            else
                zlim([FE.coord_min(3), FE.coord_max(3)])
                view([50,22])
            end
            drawnow;
            if iter==0
                % fig2_x = pos1(1); 
                fig2_y = pos1(2); 
                fig2_width = pos1(3); fig2_height = pos1(4);   
                % Shift position of fig 2 so that its left-bottom
                % corner coincides with the right-bottom corner of fig 1
                set(gcf,'Position', [fig1_x + fig1_width/2,fig2_y,fig2_width,fig2_height]) 
            end
            
        end
    end
end