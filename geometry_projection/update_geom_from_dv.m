function update_geom_from_dv()
%
% This function updates the values of the unscaled bar geometric parameters
% from the values of the design variableds (which will be scaled if
% OPT.options.dv_scaling is true). It does the
% opposite from the function update_dv_from_geom.
%
global GEOM OPT FE

% Eq. (32)
GEOM.current_design.point_matrix(:,2:end) = ...
    (OPT.scaling.point_scale.* reshape(OPT.dv( OPT.point_dv), ...
    [FE.dim,GEOM.n_point]) + OPT.scaling.point_min ).';
GEOM.current_design.bar_matrix(:,end-1) = ...
    OPT.dv(  OPT.size_dv);
GEOM.current_design.bar_matrix(:,end) = ...
OPT.dv(OPT.radius_dv).* OPT.scaling.radius_scale + OPT.scaling.radius_min;