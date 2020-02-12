function plot_density(fig)
%
% Create figure with plot of densities
%
if nargin < 1
    f = gcf; fig = f.Number;
end
%PLOT_DENSITY plots the density field into the specified figure
%
global FE OPT

if strcmpi(FE.mesh_input.type,'read-gmsh') % mesh was made by gmsh
    plot_density_cells(fig);
else % mesh was generated and comforms to meshgrid format. 
%     we then default to plotting level-sets of the density as
%     linearly interpolated between the centroids of the mesh.
    plot_density_levelsets(fig);
end

title_string = sprintf('density, %s = %f',...
    OPT.functions.objective,OPT.functions.f{1}.value);
title(title_string)
