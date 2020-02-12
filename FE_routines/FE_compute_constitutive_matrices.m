function FE_compute_constitutive_matrices
%
% Compute elasticity matrix for given elasticity modulus and Poisson's ratio
%
global FE

% compute the elastic matrix for the design-material 
C = ...
    FE_compute_constitutive_matrix(...
        FE.material.E,...
        FE.material.nu);

FE.material.C = C;
