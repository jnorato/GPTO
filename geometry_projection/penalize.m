function [varargout] = penalize(varargin)

% [P, dPdx] = penalize(x, p, penal_scheme)
%     penalize(x) assumes x \in [0,1] and decreases the intermediate values
%
%	  For a single input, the interpolation is SIMP with p = 3
%
%	  The optional second argument is the parameter value p.
%
%     The optional third argument is a string that indicates the way the 
%	  interpolation is defined, possible values are:
%       'SIMP'      : default 
% 	  	'RAMP'      : 
%

% consider input
    n_inputs =  length(varargin);
    x = varargin{1};
    if n_inputs == 1
        % set the definition to be used by default.
        p = 3; 
    	penal_scheme = 'SIMP'; 
    elseif n_inputs == 2
        p = varargin{2};
        penal_scheme = 'SIMP';
    elseif n_inputs == 3
        p = varargin{2};
        penal_scheme = varargin{3}; 
    else 
    	error('penalization received %d inputs, but requires 1 to 3',n_inputs)
    end
    
% consider output
    n_outputs = nargout;
    compute_sensitivity = true;
    if n_outputs <1
        compute_sensitivity = false;
    elseif n_outputs > 2
        error('%d outputs requested; supports up to 2',n_outputs)
    end

% define function
    switch penal_scheme
        case 'SIMP'
            P = @(x) x.^p;
            dPdx = @(x) p*x.^(p-1);
        case 'RAMP'
            P = @(x) x./(1 + p.*(1-x));
            dPdx = @(x) (1+p)./(1 + p.*(1-x)).^2;
        otherwise
            error('penalize received invalid penal_scheme.')
    end

% compute the output
	varargout{1} = P(x);
	if compute_sensitivity
		varargout{2} = dPdx(x);
	end

end