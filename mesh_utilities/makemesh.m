function makemesh(dimensions, elements_per_side, filename)
%
% This function generates a uniform quadrilateral or hexahedral mesh for 
% rectangular or parallelepiped design regions respectively and saves it to
% a Matlab .mat file so that it can be loaded.
%
% Arguments:
%
% box_dimensions is a vector (2 x 1 in 2D, 3 x 1 in 3D) with the dimensions
%                of the design region.
% elements_per_side is a vector of the same dimensions as box_dimensions
%                   with the number of elements to be created in each
%                   corresponding dimension.
% filename is the name of the .mat file to be generated.
%
%
global FE
FE.mesh_input.box_dimensions = dimensions;
FE.mesh_input.elements_per_side = elements_per_side;
generate_mesh();
save(filename, 'FE');


