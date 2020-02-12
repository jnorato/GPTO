function [sK] = FE_compute_element_stiffness(C)
%
% This function computes the element stiffness matrix fo all elements given
% an elasticity matrix.
% It computes the 'fully-solid' (i.e., unpenalized) matrix.

global FE

%% Inline Functions
% Jacobian matrix
Jacobian = @(xi,eta,elem) 0.25*[eta-1  xi-1
                    1-eta -xi-1
                    1+eta  1+xi
                    -eta-1 1-xi]'*...
                    FE.coords(:,FE.elem_node(:,elem))';
Jacobian8 = @(xi,eta,zeta, elem) 0.125*[-(1-zeta)*(1-eta)  -(1-zeta)*(1-xi)  -(1-eta)*(1-xi)
                                         (1-zeta)*(1-eta)  -(1-zeta)*(1+xi)  -(1-eta)*(1+xi)
                                         (1-zeta)*(1+eta)   (1-zeta)*(1+xi)  -(1+eta)*(1+xi)  
                                        -(1-zeta)*(1+eta)   (1-zeta)*(1-xi)  -(1+eta)*(1-xi)
                                        -(1+zeta)*(1-eta)  -(1+zeta)*(1-xi)   (1-eta)*(1-xi)
                                         (1+zeta)*(1-eta)  -(1+zeta)*(1+xi)   (1-eta)*(1+xi)
                                         (1+zeta)*(1+eta)   (1+zeta)*(1+xi)   (1+eta)*(1+xi)
                                        -(1+zeta)*(1+eta)   (1+zeta)*(1-xi)   (1+eta)*(1-xi)]'* ...
                    FE.coords(:,FE.elem_node(:,elem))';
                
% Gradient of shape function matrix in parent coordinates
G0_N = @(xi,eta,elem) 0.25*[eta-1  xi-1
                    1-eta -xi-1
                    1+eta  1+xi
                    -eta-1 1-xi]'; 
G0_N8 = @(xi,eta,zeta,elem) 0.125*[-(1-zeta)*(1-eta)  -(1-zeta)*(1-xi)  -(1-eta)*(1-xi)
                                         (1-zeta)*(1-eta)  -(1-zeta)*(1+xi)  -(1-eta)*(1+xi)
                                         (1-zeta)*(1+eta)   (1-zeta)*(1+xi)  -(1+eta)*(1+xi)  
                                        -(1-zeta)*(1+eta)   (1-zeta)*(1-xi)  -(1+eta)*(1-xi)
                                        -(1+zeta)*(1-eta)  -(1+zeta)*(1-xi)   (1-eta)*(1-xi)
                                         (1+zeta)*(1-eta)  -(1+zeta)*(1+xi)   (1-eta)*(1+xi)
                                         (1+zeta)*(1+eta)   (1+zeta)*(1+xi)   (1+eta)*(1+xi)
                                        -(1+zeta)*(1+eta)   (1+zeta)*(1-xi)   (1+eta)*(1-xi)]'; 
                
%% Solid Stiffness Matrix Computation
% We will use a 2 point quadrature to integrate the stiffness matrix:
gauss_pt = [-1 1]/sqrt(3);
W = [1 1 1];
num_gauss_pt = length(gauss_pt);

% inititalize element stiffness matrices
Ke = zeros(2^FE.dim*FE.dim,2^FE.dim*FE.dim,FE.n_elem);
% loop over elements
bad_elem = false(FE.n_elem,1); % any element with a negative det_J will be flagged
for e = 1:FE.n_elem
    if FE.dim == 2
      % loop over Gauss Points
        for i = 1:num_gauss_pt
            xi = gauss_pt(i);
            for j = 1:num_gauss_pt
                eta = gauss_pt(j);
              % Compute Jacobian
                J = Jacobian(xi,eta,e);
                det_J = det(J);
                inv_J = J\eye(size(J));
              % Compute shape function derivatives (strain displacement matrix)  
                GN = inv_J * G0_N(xi,eta,e);
                B = [GN(1,1) 0 GN(1,2) 0 GN(1,3) 0 GN(1,4) 0
                     0 GN(2,1) 0 GN(2,2) 0 GN(2,3) 0 GN(2,4)
                     GN(2,1) GN(1,1) GN(2,2) GN(1,2) GN(2,3) GN(1,3) GN(2,4) GN(1,4)];
                Ke(:,:,e) = Ke(:,:,e) + W(i)*W(j)*det_J * B'*C*B;
            end
        end
    elseif FE.dim == 3
      % loop over Gauss Points
        for i = 1:num_gauss_pt
            xi = gauss_pt(i);
            for j = 1:num_gauss_pt
                eta = gauss_pt(j);
                for k = 1:num_gauss_pt
                    zeta = gauss_pt(k);
                  % Compute Jacobian
                    J = Jacobian8(xi,eta,zeta,e);
                    det_J = det(J);
                    inv_J = J\eye(size(J));
                  % Compute shape function derivatives (strain displacement matrix)  
                    GN = inv_J * G0_N8(xi,eta,zeta,e);
                    B = [GN(1,1) 0 0 GN(1,2) 0 0 GN(1,3) 0 0 GN(1,4) 0 0 GN(1,5) 0 0 GN(1,6) 0 0 GN(1,7) 0 0 GN(1,8) 0 0
                         0 GN(2,1) 0 0 GN(2,2) 0 0 GN(2,3) 0 0 GN(2,4) 0 0 GN(2,5) 0 0 GN(2,6) 0 0 GN(2,7) 0 0 GN(2,8) 0 
                         0 0 GN(3,1) 0 0 GN(3,2) 0 0 GN(3,3) 0 0 GN(3,4) 0 0 GN(3,5) 0 0 GN(3,6) 0 0 GN(3,7) 0 0 GN(3,8)
                         GN(2,1) GN(1,1) 0 GN(2,2) GN(1,2) 0 GN(2,3) GN(1,3) 0 GN(2,4) GN(1,4) 0 GN(2,5) GN(1,5) 0 GN(2,6) GN(1,6) 0 GN(2,7) GN(1,7) 0 GN(2,8) GN(1,8) 0
                         0 GN(3,1) GN(2,1) 0 GN(3,2) GN(2,2) 0 GN(3,3) GN(2,3) 0 GN(3,4) GN(2,4) 0 GN(3,5) GN(2,5) 0 GN(3,6) GN(2,6) 0 GN(3,7) GN(2,7) 0 GN(3,8) GN(2,8)
                         GN(3,1) 0 GN(1,1) GN(3,2) 0 GN(1,2) GN(3,3) 0 GN(1,3) GN(3,4) 0 GN(1,4) GN(3,5) 0 GN(1,5) GN(3,6) 0 GN(1,6) GN(3,7) 0 GN(1,7) GN(3,8) 0 GN(1,8)];
                    Ke(:,:,e) = Ke(:,:,e) + W(i)*W(j)*W(k)*det_J * B'*C*B;
                end
            end
        end
    end
    if det_J < 0;bad_elem(e) = true; end
end
if sum(bad_elem) > 0; error('The following elements have nodes in the wrong order:\n%s',sprintf('%i\n',find(bad_elem))); end
sK = Ke(:);
