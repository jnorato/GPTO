function [] = perform_analysis()
%
% Perform the geometry projection, solve the finite
% element problem for the displacements and reaction forces, and then
% evaluate the relevant functions.
%
project_element_densities()
FE_analysis()
evaluate_relevant_functions()
end

