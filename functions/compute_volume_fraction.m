function [volfrac,grad_vofrac] = compute_volume_fraction()
%
% This function computes the volume fraction and its sensitivities
% based on the last geometry projection
%
global FE OPT

% compute the volume fraction
        v_e = FE.elem_vol; % element volume
        V = sum(v_e); % full volume
        v = v_e(:).' * OPT.elem_dens(:); % projected volume
    volfrac =  v/V; % Eq. (16)

% compute the design sensitivity
    Dvolfrac_Ddv = (v_e(:).' * OPT.Delem_dens_Ddv)/V;   % Eq. (31)
    grad_vofrac = Dvolfrac_Ddv.';
    
% output
    OPT.volume_fraction = volfrac;
    OPT.grad_volume_fraction = grad_vofrac;