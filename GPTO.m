% =========================================================================
% 
% GPTO
% 
% A Matlab code for topology optimization with bars using the geometry
% projection method.
% Version 1.0 -- Nov 2019 
%
% Hollis Smith and Julian Norato
% Department of Mechanical Engineering
% University of Connecticut
%
%
% Disclaimer
% ==========
% This software is provided by the contributors "as-is" with no explicit or
% implied warranty of any kind. In no event shall the University of
% Connecticut or the contributors be held liable for damages incurred by
% the use of this software.
%
% License
% =======
% This software is released under the Creative Commons CC BY-NC 4.0
% license. As such, you are allowed to copy and redistribute the material 
% in any medium or format, and to remix, transform, and build upon the 
% material, as long as you: 
% a) give appropriate credit, provide a link to the license, and indicate 
% if changes were made. You may do so in any reasonable manner, but not in 
% any way that suggests the licensor endorses you or your use.
% b) do not use it for commercial purposes.
%
% To fulfill part a) above, we kindly ask that you please cite the paper
% that introduces this code:
%
% Smith, H. and Norato, J.A. "A Matlab code for the topology optimization
% of structures made of bars using the geometry projection method."
% Structural and Multidisciplinary Optimization, 2018 (in review).
%
% =========================================================================


clear all; close all; clc;
%% source folders containing scripts not in this folder
addpath(genpath('FE_routines'))
addpath(genpath('geometry_projection'))
addpath(genpath('functions'))
addpath(genpath('mesh_utilities'))
addpath(genpath('optimization'))
addpath(genpath('utilities'))
addpath(genpath('plotting'))


global OPT GEOM FE

%% Start timer
tic;

%% Initialization
get_inputs();

init_FE();
init_geometry();
init_optimization();

% load('matlab.mat','GEOM'); update_dv_from_geom;

%% Analysis
perform_analysis(); 

%% Finite difference check of sensitivities
% (If requested)
if OPT.make_fd_check
    run_finite_difference_check();
    return;  % End code here
end

%% Optimization
switch OPT.options.optimizer
    case 'fmincon-active-set'
        OPT.history = runfmincon(OPT.dv,@(x)obj(x),@(x)nonlcon(x));
    case 'mma'
        OPT.history = runmma(OPT.dv,@(x)obj(x),@(x)nonlcon(x));
end

%% Plot History
if OPT.options.plot == true
    plot_history(3);
end

%% Report time
toc
 