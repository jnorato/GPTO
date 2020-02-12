function history = runfmincon(x0,obj,nonlcon)
%
% Perform the optimization using Matlab's fmincon
%
global OPT GEOM FE


    % Initialize history object
    history.x = [];
    history.fval = [];
    history.fconsval = [];
    % call optimization
    options = optimoptions(@fmincon,...
        'OutputFcn',@output,... 
        'PlotFcn',@plotfun,... 
        'Algorithm','active-set', ...
        'FiniteDifferenceStepSize', 1e-5, ...
        'SpecifyObjectiveGradient',true,...
        'SpecifyConstraintGradient',true,...
        'RelLineSrchBnd', OPT.options.move_limit, ...   % Eq. (33)
        'RelLineSrchBndDuration', OPT.options.max_iter, ...
        'ConstraintTolerance', 1e-3, ...
        'MaxIterations',OPT.options.max_iter, ...
        'OptimalityTolerance',OPT.options.kkt_tol, ...%         
        'StepTolerance',OPT.options.step_tol,...
        'Display', 'iter'); % 

        
    % x0                
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    
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

    % ******
    % This is the call to the optimizer
    %
    [x,fval,exitflag,optim_output] = fmincon(obj,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
    % ******
    
    % Write vtk for final iteration if requested
    if strcmp(OPT.options.write_to_vtk, 'all') || ...
            strcmp(OPT.options.write_to_vtk, 'last')
        writevtk(OPT.options.vtk_output_path, 'dens', optim_output.iterations);
    end    
   
% =========================================================================

    function stop = output(x,optimValues,state)
       stop = false;
       switch state
           case 'init'
               % do nothing
           case 'iter'
               % Concatenate current point and objective function
               % value with history
               history.fval = [history.fval; optimValues.fval];
               history.fconsval = [history.fconsval; nonlcon(OPT.dv)];
               history.x = [history.x x(:)]; % here we make x into a column vector
               % Save design to .mat file
               [folder, baseFileName, ~] = fileparts(GEOM.initial_design.path);
               mat_filename = fullfile(folder, strcat(baseFileName, '.mat'));
               save(mat_filename, 'GEOM');
               % Write to vtk file if requested.  
               if strcmp(OPT.options.write_to_vtk, 'all')
                   writevtk(OPT.options.vtk_output_path, 'dens', optimValues.iteration);
               end
           case 'done'
               % do nothing
           otherwise
       end
    end
% =========================================================================

    function stop = plotfun(x,optimValues,state)
        if OPT.options.plot == true
            figure(1)
            plot_design(1)
            title(sprintf('design, iteration = %i',optimValues.iteration))
            axis equal
            xlim([FE.coord_min(1), FE.coord_max(1)])
            ylim([FE.coord_min(2), FE.coord_max(2)])
            if FE.dim == 2
                view(2)
            else
                zlim([FE.coord_min(3), FE.coord_max(3)])
                view([50,22])
            end
            if strcmp(state, 'init')
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
            if strcmp(state, 'init')
                % fig2_x = pos1(1); 
                fig2_y = pos1(2); 
                fig2_width = pos1(3); fig2_height = pos1(4);   
                % Shift position of fig 2 so that its left-bottom
                % corner coincides with the right-bottom corner of fig 1
                set(gcf,'Position', [fig1_x + fig1_width/2,fig2_y,fig2_width,fig2_height]) 
            end
            stop = false;
        end
    end
end