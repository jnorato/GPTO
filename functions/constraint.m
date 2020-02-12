function [g,outputArg2] = constraint(inputArg1,inputArg2)
%CONSTRAINT Summary of this function goes here
%   Detailed explanation goes here
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end


function [g, geq, gradg, gradgeq] = nonlcon(d)
% [g, geq, gradg, gradgeq] = nonlcon(d)

    global  opt_param
    
    opt_param.PARAM_VALUE_OLD = opt_param.PARAM_VALUE;
    opt_param.PARAM_VALUE = d;
    
    if opt_param.PARAM_VALUE == opt_param.PARAM_VALUE_OLD
        %don't update or perform the analysis
    else
        if opt_param.symmetry
        % reflect the design
            reflect_design2() % updates the reflected param_value
        end
        update_bars_geom(); % update bars_geom for these design parameters
        compute_effective_densities_and_element_elasticity(); % for the new design
        FE_analysis(); % solve the FEA for the new design
        sensitivity(); % evaluate the sensitivity for the new design
        if opt_param.symmetry
        % reflect the design
            unreflect_design() % updates the unreflected geometry and reduces param_value
        end
    end
    

    g = [opt_param.volume_fraction 
         opt_param.discreteness_constraint
         opt_param.MME_constraint 
         opt_param.overlap_constraint 
         opt_param.angle_constraint ...
        ] - opt_param.cons_lim;
    
    
    gradg = [opt_param.GRAD_volume_fraction ...
             opt_param.GRAD_discreteness_constraint ...
             opt_param.GRAD_MME_constraint ...
             opt_param.GRAD_overlap_constraint ...
             opt_param.GRAD_angle_constraint ...
        ];
    
    if opt_param.symmetry
        gradg = full([gradg.' * opt_param.DPARAM_VALUE_DPARAM_VALUE0].');
    end
    geq = [];
    gradgeq = [];