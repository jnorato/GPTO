function [] = FE_init_partitioning()
%
% Partition finite element matrix and RHS vector for solution
%

global FE

FE.n_global_dof = FE.dim*FE.n_node;

FE.fixeddofs = false(1,FE.n_global_dof);
if FE.dim == 2
    FE.fixeddofs(2*FE.BC.disp_node(FE.BC.disp_dof==1)-1) = true; % set prescribed x1 DOFs 
    FE.fixeddofs(2*FE.BC.disp_node(FE.BC.disp_dof==2)) = true;   % set prescribed x2 DOFs 
else
    FE.fixeddofs(3*FE.BC.disp_node(FE.BC.disp_dof==1)-2) = true; % set prescribed x1 DOFs 
    FE.fixeddofs(3*FE.BC.disp_node(FE.BC.disp_dof==2)-1) = true; % set prescribed x2 DOFs 
    FE.fixeddofs(3*FE.BC.disp_node(FE.BC.disp_dof==3)) = true;   % set prescribed x3 DOFs 
end    
FE.freedofs = ~FE.fixeddofs;

% by calling find() once to these functions to get the indices, the 
% overhead of logical indexing may be removed.
FE.fixeddofs_ind = find(FE.fixeddofs);
FE.freedofs_ind = find(FE.freedofs);
FE.n_free_dof = length(FE.freedofs_ind); % the number of free DOFs


% To vectorize the assembly for the global system in
% the FEA, the method employed in the 88-lines paper is adopted: 

n_elem_dof = 2^FE.dim*FE.dim;
FE.n_edof = n_elem_dof;

[n,m] = size(FE.elem_node);
FE.edofMat = zeros(m,n*FE.dim);
for elem = 1:m
    enodes = FE.elem_node(:,elem);
    if FE.dim == 2
        edofs = reshape([2*enodes-1,2*enodes]',1,n_elem_dof);
    elseif FE.dim == 3
        edofs = reshape([3*enodes-2, 3*enodes-1, 3*enodes]', 1, n_elem_dof);
    end
    FE.edofMat(elem,:) = edofs;
end

FE.iK = reshape(kron(FE.edofMat,ones(n_elem_dof,1))',n_elem_dof^2*FE.n_elem,1);
FE.jK = reshape(kron(FE.edofMat,ones(1,n_elem_dof))',n_elem_dof^2*FE.n_elem,1);


