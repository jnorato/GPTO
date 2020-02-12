function [S, dSdx] = smooth_max(x,p,form_def,x_min)
%
% This function computes a smooth approximation of the maximum of x.  The
% type of smooth approximation (listed below) is given by the argument
% form_def, and the corresponding approximation parameter is given by p.
% x_min is a lower bound to the smooth approximation for the modified
% p-norm and modified p-mean approximations.
%
%
%     The optional third argument is a string that indicates the way the 
%	  approximation is defined, possible values are:
% 		'mod_p-norm'   : overestimate using modified p-norm (supports x=0)
% 		'mod_p-mean'   : underestimate using modified p-norm (supports x=0)
%		'KS'           : Kreisselmeier-Steinhauser, overestimate
%		'KS_under'     : Kreisselmeier-Steinhauser, underestimate
%
    
    epx = @(x) exp(p*x);
    sum_epx = @(x) sum(epx(x));
    switch form_def
        case 'mod_p-norm'
            % Eq. (6)
            % in this case, we assume x >= 0 
            S = ( x_min^p + (1-x_min^p)*sum(x.^p) ).^(1/p);
            dSdx = (1-x_min^p)*(x./S).^(p-1);
        case 'mod_p-mean'
            % in this case, we assume x >= 0 
            N = size(x,1);
            S = ( x_min^p + (1-x_min^p)*sum(x.^p)/N ).^(1/p);
            dSdx = (1-x_min^p)*(1/N)*(x./S).^(p-1);            
        case 'KS'
            S = x_min + (1-x_min)*log(sum_epx(x))/p;
            dSdx = (1-x_min)*epx(x)./sum_epx(x);
        case 'KS_under'
            % note: convergence might be fixed with Euler-Gamma
            N = size(x,1);
            S = x_min + (1-x_min)*log(sum_epx(x)/N)/p; 
            dSdx =(1-x_min)*epx(x)./sum_epx(x);
        otherwise
            error('smooth_max received invalid form_def.')
    end


end