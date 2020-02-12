function setup_bcs_cantilever2d()
%% Input file 
%
% *** THIS SCRIPT HAS TO BE CUSTOMIZED BY THE USER ***
%
% This script sets up the displacement boundary conditions and the forces
% for the analysis. 
%
% Important note: you must make sure you do not simultaneously impose 
% displacement boundary conditions and forces on the same degree of
% freedom.

% ** Do not modify this line **
global FE

coord_x = FE.coords(1,:);
coord_y = FE.coords(2,:);
if FE.dim == 3
    coord_z = FE.coords(3,:);
end

%% ============================
%% Compute predefined node sets
compute_predefined_node_sets({'BR_pt','L_edge'})
% for an overview of this function, use: help compute_predefined_node_sets

BR_pt  = FE.node_set.BR_pt;
L_edge = FE.node_set.L_edge;
%% ============================        


%% Applied forces
net_mag = -.1;  % Force magnitude (net over all nodes where applied)
load_dir = 2;   % Force direction 
    
load_region = BR_pt;
load_mag = net_mag/length(load_region);

% Here, we build the array with all the loads.  If you have multiple
% applied loads, the load_mat array must contain all the loads as follows:
%  - There is one row per each load on a degree of freedom
%  - Column 1 has the node id where the load is applied
%  - Column 2 has the direction (1 -> x, 2 -> y, 3 -> z)
%  - Column 3 has the load magnitude.
%
load_mat = zeros(length(load_region),3);
load_mat(:,1) = load_region;
load_mat(:,2) = load_dir;
load_mat(:,3) = load_mag;


%% Displacement boundary conditions
%
disp_mag = 0;
disp_region = L_edge;
disp_dirs = [1 2];    % In this example, we are constraining both the x- 
                      % and y- displacements. 
                      
% Here, we build the array with all the displacement BCs. 
% The disp_mat array must contain all the loads as follows:
%  - There is one row per each load on a degree of freedom
%  - Column 1 has the node id where the displacement BC is applied
%  - Column 2 has the direction (1 -> x, 2 -> y, 3 -> z)
%  - Column 3 has the displacement magnitude.
% 
disp_mat = zeros(length(disp_region)*length(disp_dirs),3);
for idir=1:length(disp_dirs)
    idx_start = 1 + (idir-1)*length(disp_region);
    idx_end = idir*length(disp_region);
    disp_mat(idx_start:idx_end,1) = disp_region;
    disp_mat(idx_start:idx_end,2) = disp_dirs(idir);
    disp_mat(idx_start:idx_end,3) = disp_mag;
end

% *** Do not modify the code below ***
%
% Write displacement boundary conditions and forces to the global FE
% structure.
%
%
FE.BC.n_pre_force_dofs = size(load_mat,1); % # of prescribed force dofs
FE.BC.n_pre_disp_dofs = size(disp_mat,1); % # of prescribed displacement dofs
FE.BC.force_node =  load_mat(:,1)';
FE.BC.force_dof = load_mat(:,2)';
FE.BC.force_value = load_mat(:,3)';
FE.BC.disp_node = disp_mat(:,1)';
FE.BC.disp_dof = disp_mat(:,2)';
FE.BC.disp_value = disp_mat(:,3)';

