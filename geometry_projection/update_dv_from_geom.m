function update_dv_from_geom()
%
% This function updates the values of the design variables (which will be
% scaled if OPT.options.dv_scaling is true) based on the unscaled bar 
% geometric parameters. It does the opposite from the function 
% update_geom_from_dv.
%

global GEOM OPT 

% Fill in design variable vector based on the initial design
% Eq. (32)
OPT.dv( OPT.point_dv) = (GEOM.initial_design.point_matrix(:,2:end).' ...
     - OPT.scaling.point_min )./OPT.scaling.point_scale;
OPT.dv(  OPT.size_dv) = GEOM.initial_design.bar_matrix(:,end-1);
OPT.dv(OPT.radius_dv) = (GEOM.initial_design.bar_matrix(:,end) ...
    - OPT.scaling.radius_min)./OPT.scaling.radius_scale ;