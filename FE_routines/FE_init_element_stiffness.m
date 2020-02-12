function [] = FE_init_element_stiffness()
%
% This function computes FE.sK_void, the vector of element 
% stiffess matrix entries for the void material.

global FE

%% Void Stiffness Matrix Computation

n_edof = FE.n_edof;

FE.Ke = reshape(...
    FE_compute_element_stiffness(FE.material.C),...
        [n_edof,n_edof,FE.n_elem]);
 
