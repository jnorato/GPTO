function generate_mesh()
%
% This function generates a uniform quadrilateral or hexahedral mesh for 
% rectangular or parallelepiped design regions respectively. 
%
% The two arguments needed (box_dimensions and elements_per_side) must have
% been assigned in the FE.mesh_input structure prior to calling this
% routine.
%
% box_dimensions is a vector (2 x 1 in 2D, 3 x 1 in 3D) with the dimensions
%                of the design region.
% elements_per_side is a vector of the same dimensions as box_dimensions
%                   with the number of elements to be created in each
%                   corresponding dimension.
%
% The function updates the necessary arrays in the global FE structure.
% This function does not need modification from the user.
%

global FE

box_dimensions = FE.mesh_input.box_dimensions;
elements_per_side = FE.mesh_input.elements_per_side;

% A sanity check:
if ~ length(box_dimensions)==length(elements_per_side) 
    error('Inconsistent number of dimensions and elements per side.');
end

if length(box_dimensions) == 3
    FE.dim = 3;
elseif length(box_dimensions) == 2
    FE.dim = 2;
else 
    error('FE.mesh_input.dimensions must be of length 2 or 3')
end



%% create nodal coordinates

n_i = elements_per_side + 1; % number of nodes in coord i

x_i = cell(FE.dim,1);
for i = 1:FE.dim
    x_i{i}  = linspace(0,box_dimensions(i),n_i(i));
end

FE.n_elem = prod(elements_per_side(1:FE.dim));
FE.n_node = prod(elements_per_side(1:FE.dim)+1);

if FE.dim == 2
    [xx, yy] = meshgrid(x_i{1}, x_i{2});
    node_coords = [xx(:), yy(:)];
elseif FE.dim == 3
    [xx, yy, zz] = meshgrid(x_i{1}, x_i{2}, x_i{3});
    node_coords = [xx(:), yy(:), zz(:)];
end


%% define element connectivity

elem_mat = zeros(FE.n_elem,2^FE.dim);
nelx = elements_per_side(1);
nely = elements_per_side(2);
if FE.dim == 2
    row=reshape(1:nely,[],1);
    col=reshape(1:nelx,1,[]);
    n1 = row + (col-1)*(nely+1);
    n2 = row + col*(nely+1);
    n3 = n2 + 1;
    n4 = n1 + 1;
    elem_mat = [n1(:), n2(:), n3(:), n4(:)];
elseif FE.dim == 3
    nelz = elements_per_side(3);
    row = reshape(1:nely,[],1,1);
    col = reshape(1:nelx,1,[],1);
    pile= reshape(1:nelz,1,1,[]);
    n1 = row + (col-1)*(nely+1) + (pile-1)*(nelx+1)*(nely+1);
    n2 = row + col*(nely+1) + (pile-1)*(nelx+1)*(nely+1);
    n3 = n2 + 1;
    n4 = n1 + 1;
    n5 = n1 + (nelx+1)*(nely+1);
    n6 = n2 + (nelx+1)*(nely+1);
    n7 = n6 + 1;
    n8 = n5 + 1;
    elem_mat = [n1(:), n2(:), n3(:), n4(:), n5(:), n6(:), n7(:), n8(:)];
end

%% export the mesh to the FE object by updating relevant fields 

FE.coords = node_coords(:,1:FE.dim).';
FE.elem_node = elem_mat';  % 4 nodes for quads, 8 for hexas


%% print to terminal details of mesh generation

fprintf('generated %dd cuboid mesh with %d elements and %d nodes.\n',...
    FE.dim,FE.n_elem,FE.n_node)
