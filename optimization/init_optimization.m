function init_optimization()
global OPT FE GEOM

% Initialize functions to compute
% Concatenate list of functions to be computed
f_list = {OPT.functions.objective; OPT.functions.constraints{:}};

% here we list all the functions that are available to compute as f{i}

f{1}.name = 'compliance';
f{1}.function = 'compute_compliance';

f{2}.name = 'volume fraction';
f{2}.function = 'compute_volume_fraction';

% compare all functions available with the ones specified in inputs.m
n = length(f);
m = length(f_list);
for j = 1:m
    for i = 1:n
        if strcmpi( f{i}.name, f_list{j})
            OPT.functions.f{j} = f{i};
        end
    end
end

OPT.functions.n_func =  numel(OPT.functions.f);

%% initialize sample window size
if ~isfield(OPT.parameters,'elem_r')
% compute sampling radius
    % The radius corresponds to the circle (or sphere) that circumscribes a
    % square (or cube) that has the edge length of elem_size.
    OPT.parameters.elem_r = sqrt(FE.dim)/2 * FE.elem_vol.^(1./FE.dim) ;
end

%%
% Initilize the design variable and its indexing schemes

% we are designing the points, the size variables, and the radii of the
% bars:

    OPT.n_dv = FE.dim*GEOM.n_point + 2*GEOM.n_bar;
    OPT.dv = zeros(OPT.n_dv,1);
    
    OPT.point_dv = (1:FE.dim*GEOM.n_point); % such that dv(point_dv) = point
    OPT.size_dv = OPT.point_dv(end) + (1:GEOM.n_bar);
    OPT.radius_dv = OPT.size_dv(end) + (1:GEOM.n_bar);


    if OPT.options.dv_scaling
        % Compute variable limits for Eq. (32)
        OPT.scaling.point_scale = (FE.coord_max-FE.coord_min); 
        OPT.scaling.point_min   = FE.coord_min;
        % Consider possibility that max_bar_radius and min_bar_radius are
        % the same (when bars are of fixed radius)
        delta_radius = GEOM.max_bar_radius - GEOM.min_bar_radius;
        if delta_radius < 1e-12
            OPT.scaling.radius_scale = 1;
        else
            OPT.scaling.radius_scale = delta_radius;
        end
        OPT.scaling.radius_min = GEOM.min_bar_radius;
    else
        OPT.scaling.point_scale= 1.0;
        OPT.scaling.point_min   = 0.0;
        OPT.scaling.radius_scale = 1.0;
        OPT.scaling.radius_min = 0.0;
    end
    
% fill in design variable vector based on the initial design
update_dv_from_geom();

% set the current design to the initial design:
GEOM.current_design.point_matrix = GEOM.initial_design.point_matrix;
GEOM.current_design.bar_matrix = GEOM.initial_design.bar_matrix;


% consider the bar design variables
% x_1b, x_2b, alpha_b, r_b

x_1b_id = GEOM.current_design.bar_matrix(:,2);
x_2b_id = GEOM.current_design.bar_matrix(:,3);

pt1 = GEOM.point_mat_row(x_1b_id);
pt2 = GEOM.point_mat_row(x_2b_id);

pt_dv = reshape(OPT.point_dv(:),[FE.dim,GEOM.n_point]);

OPT.bar_dv = [  pt_dv(:,pt1);...
                pt_dv(:,pt2);...
                OPT.size_dv;...
                OPT.radius_dv];

