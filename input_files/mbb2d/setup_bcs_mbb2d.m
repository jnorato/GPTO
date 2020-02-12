function setup_bcs_mbb2d()
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
compute_predefined_node_sets({'TL_pt', 'BR_pt', 'L_edge'})
% for an overview of this function, use: help compute_predefined_node_sets

TL_pt = FE.node_set.TL_pt;
BR_pt  = FE.node_set.BR_pt;
L_edge = FE.node_set.L_edge;
%% ============================        


%% Applied forces
net_mag = -0.1;  % Force magnitude (net over all nodes where applied)
load_dir = 2;   % Force direction     
load_region = TL_pt;
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
% Symmetry boundary condition on left-hand side edge
disp_region1 = L_edge;
disp_dirs1 = ones(1, length(disp_region1));    
disp_mag1 = zeros(1, length(disp_region1));
% Vertical roller on bottom-right point
disp_region2 = BR_pt;
disp_dirs2 = [2];    
disp_mag2 = [0];
% Combine displacement BC regions
disp_region = [disp_region1 disp_region2];
disp_dirs = [disp_dirs1 disp_dirs2];
disp_mag = [disp_mag1 disp_mag2];
                      
% Here, we build the array with all the displacement BCs. 
% The disp_mat array must contain all the loads as follows:
%  - There is one row per each load on a degree of freedom
%  - Column 1 has the node id where the displacement BC is applied
%  - Column 2 has the direction (1 -> x, 2 -> y, 3 -> z)
%  - Column 3 has the displacement magnitude.
% 
disp_mat = zeros(length(disp_region),3);
for idisp=1:length(disp_region)
    disp_mat(idisp, 1) = disp_region(idisp);
    disp_mat(idisp, 2) = disp_dirs(idisp);
    disp_mat(idisp, 3) = disp_mag(idisp);
end

% *** Do not modify the code below ***
%
% Write displacement boundary conditions and forces to the global FE
% structure.
%
% Note: you must assign values for all of the variables below.
%
FE.BC.n_pre_force_dofs = size(load_mat,1); % # of prescribed force dofs
FE.BC.n_pre_disp_dofs = size(disp_mat,1); % # of prescribed displacement dofs
FE.BC.force_node =  load_mat(:,1)';
FE.BC.force_dof = load_mat(:,2)';
FE.BC.force_value = load_mat(:,3)';
FE.BC.disp_node = disp_mat(:,1)';
FE.BC.disp_dof = disp_mat(:,2)';
FE.BC.disp_value = disp_mat(:,3)';

