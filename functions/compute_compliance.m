function [c,grad_c] = compute_compliance()
%
% This function computes the mean compliance and its sensitivities
% based on the last finite element analysis
%
global FE OPT

% compute the compliance (Eq. (15))
    c = full(dot(FE.U,FE.P));

% compute the design sensitivity
    Ke = FE.Ke;
    Ue = permute(repmat(...
        FE.U(FE.edofMat).',...
            [1,1,FE.n_edof]), [1,3,2]);
    Ue_trans = permute(Ue, [2,1,3]);

    Dc_Dpenalized_elem_dens = reshape(sum(sum( ...
        -Ue_trans.*Ke.*Ue, ...
            1),2),[1,FE.n_elem]);   % Eq. (24)

    Dc_Ddv = Dc_Dpenalized_elem_dens * OPT.Dpenalized_elem_dens_Ddv; % Eq. (25)
    grad_c = Dc_Ddv.';
% save these values in the OPT structure
    OPT.compliance = c;
    OPT.grad_compliance = grad_c;