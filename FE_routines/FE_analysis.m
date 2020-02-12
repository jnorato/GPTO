function [] = FE_analysis()
%
% Assemble the global stiffness matrix and solve the finite element
% analysis

% assemble the stiffness matrix partitions Kpp Kpf Kff
FE_assemble_stiffness_matrix();

% solve the displacements and reaction forces
FE_solve();