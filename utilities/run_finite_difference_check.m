function run_finite_difference_check()
%
% This function performs a finite difference check of the analytical
% sensitivities of the cost and/or constraint functions by invoking the
% corresponding routines.
%
global OPT

if OPT.check_cost_sens
    fd_check_cost();
end
if OPT.check_cons_sens
    fd_check_constraint();
end