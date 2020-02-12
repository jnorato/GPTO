function setup_bcs_cantilever3d()
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
compute_predefined_node_sets({'MR_pt','TLK_pt', 'TLF_pt', 'BLK_pt', 'BLF_pt'})
% for an overview of this function, use: help compute_predefined_node_sets

MR_pt  = FE.node_set.MR_pt;
TLK_pt = FE.node_set.TLK_pt;
TLF_pt = FE.node_set.TLF_pt;
BLK_pt = FE.node_set.BLK_pt;
BLF_pt = FE.node_set.BLF_pt;

%% ============================        


%% Applied forces
net_mag = -.1;  % Force magnitude (net over all nodes where applied)
load_dir = 3;   % Force direction 
    
load_region = MR_pt;
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
disp_region = [TLK_pt TLF_pt BLK_pt BLF_pt];
disp_mag = zeros(1, length(disp_region));
disp_dirs1 = ones(1, length(disp_region));    
disp_dirs2 = 2*ones(1, length(disp_region));    
disp_dirs3 = 3*ones(1, length(disp_region));

% Combine displacement BC regions
disp_region = [disp_region disp_region disp_region];
disp_dirs = [disp_dirs1 disp_dirs2 disp_dirs3];
disp_mag = [disp_mag disp_mag disp_mag];


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
%
FE.BC.n_pre_force_dofs = size(load_mat,1); % # of prescribed force dofs
FE.BC.n_pre_disp_dofs = size(disp_mat,1); % # of prescribed displacement dofs
FE.BC.force_node =  load_mat(:,1)';
FE.BC.force_dof = load_mat(:,2)';
FE.BC.force_value = load_mat(:,3)';
FE.BC.disp_node = disp_mat(:,1)';
FE.BC.disp_dof = disp_mat(:,2)';
FE.BC.disp_value = disp_mat(:,3)';

