function fd_check_cost()
%
% This function performs a finite difference check of the sensitivities of
% the COST function with respect to the bar design variables.
%

global OPT 

% ===============================
% FINITE DIFFERENCE SENSITIVITIES
% ===============================
n_dv = OPT.n_dv;
grad_theta_i = zeros(n_dv, 1);

fd_step = OPT.fd_step_size;

max_error = 0.0;
max_rel_error = 0.0;
max_error_bar = 0;
max_rel_error_bar = 0;
dv_0 = OPT.dv;
dv_i = OPT.dv;

[theta_0,grad_theta_0] = obj(dv_0);
% Finite differences
disp('Computing finite difference sensitivities...');

% Do this for all design variables or only a few
%up_to_dv = n_dv;
up_to_dv = n_dv;

for i = 1:up_to_dv

    % ---
    % First, perturb dv
    % ---

    dv_i(i) = dv_0( i ) + fd_step;
    [theta_i , ~] = obj(dv_i);

    grad_theta_i(i) = (theta_i - theta_0)/fd_step;

    error = grad_theta_0(i) - grad_theta_i(i);

    if abs(error) > abs(max_error)
        max_error = error;
        max_error_dv = i;
    end
    rel_error = error / theta_0;
    if abs(rel_error) > abs(max_rel_error)
        max_rel_error = rel_error;
        max_rel_error_dv = i;   
    end

    dv_i = dv_0;

end

[theta_0,grad_theta_0] = obj(dv_0); % to reset the design

disp('Max. ABSOLUTE error is:'); disp(max_error);
disp('It occurs at:');
disp('  variable:'); disp(max_error_dv);

disp('Max. RELATIVE error is:'); disp(max_rel_error);
disp('It occurs at:');
disp('  variable:'); disp(max_rel_error_dv);

figure(2)
clf
hold on
plot(grad_theta_i,'o','LineStyle','-')
plot(grad_theta_0,'.','LineStyle','-')
legend('fd','analytical')
title('cost function','Interpreter','latex')
legend('fd','analytical')
xlabel('design variable z');
ylabel('dc/dz');