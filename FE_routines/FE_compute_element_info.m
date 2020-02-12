function FE_compute_element_info()
%
% This function computes element volumes, element centroid locations and
% maximum / minimum nodal coordinates values for the mesh. 
% It assumes the FE structure has already been populated.
%
global FE

dim = FE.dim;
CoordArray = zeros(2^dim,dim,FE.n_elem);
FE.elem_vol = zeros( FE.n_elem, 1);

for n = 1:FE.n_elem
    CoordArray(:,:,n)=FE.coords(:,FE.elem_node(:,n))';     
end
FE.centroids = reshape(mean(CoordArray),[FE.dim,FE.n_elem]);

% Create arrays with nodal coordinates for all nodes in an element; e.g., 
% n1(:,e) is the array of coordinates of node 1 for element e. Then use these to
% compute the element volumes using the vectorized vector-functions `cross'
% and `dot'.
%
n1(:,:) = CoordArray(1,:,:);
n2(:,:) = CoordArray(2,:,:);
n3(:,:) = CoordArray(3,:,:);
n4(:,:) = CoordArray(4,:,:);
if dim == 3
    n5(:,:) = CoordArray(5,:,:);
    n6(:,:) = CoordArray(6,:,:);
    n7(:,:) = CoordArray(7,:,:);
    n8(:,:) = CoordArray(8,:,:);
    
    % In the general case where the hexahedron is not a parallelepiped and 
    % does not necessarily have parallel sides, we use 3 scalar triple 
    % products to compute the volume of the Tetrakis Hexahedron.
    %     ( see J. Grandy, October 30, 1997,
    %       Efficient Computation of Volume of Hexahedral Cells )
    FE.elem_vol(:) = ( ...
        dot( (n7-n2) + (n8-n1), cross( (n7-n4)          , (n3-n1)           ) ) + ...
        dot( (n8-n1)          , cross( (n7-n4) + (n6-n1), (n7-n5)           ) ) + ...
        dot( (n7-n2)          , cross( (n6-n1)          , (n7-n5) + (n3-n1) ) ) ...
       )/12 ;
   
elseif dim == 2
    % Here we can take advantage of the planar quadrilaterals and use
    % Bretschneider's formula (cross product of diagonals):
    diag1 = zeros(size(n1) + [1 0]); diag1(1:2,:) = n3-n1;
    diag2 = zeros(size(n1) + [1 0]); diag2(1:2,:) = n4-n2;
    % NOTE: since only the 3rd componenet is nonzero, we use it instead 
    % of, 0.5*sqrt(sum(cross(diag1,diag2).^2))'
    v1 = cross(diag1,diag2);
    FE.elem_vol = 0.5*abs(v1(3,:))'; 
end


FE.coord_max = max(FE.coords,[],2);
FE.coord_min = min(FE.coords,[],2); 

