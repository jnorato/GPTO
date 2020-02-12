function [] = project_element_densities()
% 
% This function computes the combined unpenalized densities (used to
% compute the volume) and penalized densities (used to compute the ersatz
% material for the analysis) and saves them in the global variables
% FE.elem_dens and FE.penalized_elem_dens.  
%
% It also computes the derivatives of the unpenalized and penalized
% densities with respect to the design parameters, and saves them in the
% global variables FE.Delem_dens_Ddv and FE.Dpenalized_elem_dens_Ddv. 
%

global FE GEOM OPT

%%  Distances from the element centroids to the medial segment of each bar
    [d_be,Dd_be_Dbar_ends] = compute_bar_elem_distance();

%% Bar-element projected densities
    r_b =  GEOM.current_design.bar_matrix(:,end); % bar radii
    r_e =  OPT.parameters.elem_r; % sample window radius
    % X_be is \phi_b/r in Eq. (2).  Note that the numerator corresponds to
    % the signed distance of Eq. (8).
    X_be = (r_b(:) - d_be)./(r_e(:).'); 

    % Projected density 
    if FE.dim == 2  % 2D
        rho_be = ( (pi-acos(X_be)+X_be.*sqrt(-X_be.^2+1.0))./pi )  .*(abs(X_be)<1) ...
         + 1.* (X_be>= 1); % Eqs. (2) and (3)
        Drho_be_Dx_be = ( (sqrt(-X_be.^2+1.0).*2.0)./pi ) .*(abs(X_be)<1); % Eq. (28)
    elseif FE.dim == 3
        rho_be = ( (X_be+1.0).^2.*(X_be-2.0).*(-1.0./4.0) ) .*(abs(X_be)<1) ...
         + 1.* (X_be>= 1); % Eqs. (2) and (3)
        Drho_be_Dx_be = ( X_be.^2.*(-3.0./4.0)+3.0./4.0 )  .*(abs(X_be)<1); % Eq. (28)
    end
    % Sensitivities of raw projected densities, Eqs. (27) and (29)
    Drho_be_Dbar_ends = Drho_be_Dx_be .* (-1./r_e(:).') .* Dd_be_Dbar_ends; 
    Drho_be_Dbar_radii = Drho_be_Dx_be .* (1./r_e(:).') .* OPT.scaling.radius_scale;
        
%% Combined densities

% Get size variables 
    alpha_b = GEOM.current_design.bar_matrix(:,end-1); % bar size

% Without penalization:
% ====================
    % X_be here is \hat{\rho}_b in Eq. (4) with the value of q such that
    % there is no penalization (e.g., q = 1 in SIMP).
    X_be = rho_be .* alpha_b; 
    % Sensitivities of unpenalized effective densities, Eq. (26) with
    % ?\partial \mu / \partial (\alpha_b \rho_{be})=1
    DX_be_Dbar_ends = Drho_be_Dbar_ends .* alpha_b;
    DX_be_Dbar_size = rho_be;  
    DX_be_Dbar_radii = Drho_be_Dbar_radii .* alpha_b;

    % Combined density of Eq. (5).
    [rho_e,Drho_e_DX_be] = smooth_max(X_be,...
        OPT.parameters.smooth_max_param,...
        OPT.parameters.smooth_max_scheme, FE.material.rho_min);
    % Sensitivities of combined densities, Eq. (25)
    Drho_e_Dbar_ends = Drho_e_DX_be .* DX_be_Dbar_ends;
    Drho_e_Dbar_size = Drho_e_DX_be .* DX_be_Dbar_size;
    Drho_e_Dbar_radii = Drho_e_DX_be .* DX_be_Dbar_radii;

    % Stack together sensitivities with respect to different design
    % variables into a single vector per element
    Drho_e_Ddv = zeros(FE.n_elem,OPT.n_dv);
    for b = 1:GEOM.n_bar
        Drho_e_Ddv(:,OPT.bar_dv(:,b)) = Drho_e_Ddv(:,OPT.bar_dv(:,b)) + ...
            [ reshape(Drho_e_Dbar_ends(b,:,:),[FE.n_elem,2*FE.dim]) ,  ...
            reshape(Drho_e_Dbar_size(b,:),[FE.n_elem,1])   ,  ...
            reshape(Drho_e_Dbar_radii(b,:),[FE.n_elem,1]) ];
    end

% With penalization:   
% =================
    % In this case X_be *is* penalized (Eq. (4)).
    [penal_X_be,Dpenal_X_be_DX_be]  = penalize(X_be,...
        OPT.parameters.penalization_param,...
        OPT.parameters.penalization_scheme);
    % Sensitivities of effective (penalized) densities, Eq. (26)
    Dpenal_X_be_Dbar_ends  = Dpenal_X_be_DX_be .* DX_be_Dbar_ends;
    Dpenal_X_be_Dbar_size  = Dpenal_X_be_DX_be .* DX_be_Dbar_size;
    Dpenal_X_be_Dbar_radii = Dpenal_X_be_DX_be .* DX_be_Dbar_radii;
     
    % Combined density of Eq. (5).    
    [penal_rho_e,Dpenal_rho_e_Dpenal_X_be] = smooth_max(penal_X_be, ...
            OPT.parameters.smooth_max_param, ...
            OPT.parameters.smooth_max_scheme, FE.material.rho_min);
    % Sensitivities of combined densities, Eq. (25)
    Dpenal_rho_e_Dbar_ends = Dpenal_rho_e_Dpenal_X_be .* Dpenal_X_be_Dbar_ends;
    Dpenal_rho_e_Dbar_size = Dpenal_rho_e_Dpenal_X_be .* Dpenal_X_be_Dbar_size;
    Dpenal_rho_e_Dbar_radii= Dpenal_rho_e_Dpenal_X_be .* Dpenal_X_be_Dbar_radii;
    
    % Sensitivities of projected density
    Dpenal_rho_e_Ddv = zeros(FE.n_elem,OPT.n_dv);
    % Stack together sensitivities with respect to different design
    % variables into a single vector per element
    for b = 1:GEOM.n_bar
    Dpenal_rho_e_Ddv(:,OPT.bar_dv(:,b)) = Dpenal_rho_e_Ddv(:,OPT.bar_dv(:,b)) + ...
        [ reshape(Dpenal_rho_e_Dbar_ends(b,:,:),[FE.n_elem,2*FE.dim]) ,  ...
        reshape(Dpenal_rho_e_Dbar_size(b,:),[FE.n_elem,1])   ,  ...
        reshape(Dpenal_rho_e_Dbar_radii(b,:),[FE.n_elem,1]) ];
    end


%% Write the element densities and their sensitivities to OPT 
    OPT.elem_dens = rho_e(:);
    OPT.Delem_dens_Ddv = Drho_e_Ddv;
    
    OPT.penalized_elem_dens = penal_rho_e(:);
    OPT.Dpenalized_elem_dens_Ddv = Dpenal_rho_e_Ddv;
    
