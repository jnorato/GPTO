function C = FE_compute_constitutive_matrix(E,nu)

global FE
  % Compute constitutive matrix  
    if FE.dim == 2
        % Plane Stress (for thin out of plane dimension)
           a=E/(1-nu^2); b=nu; c=(1-nu)/2; 
        % Plane Strain (for thick out of plane dimension)
        %     a=E*(1 - nu)/((1 + nu)*(1 - 2*nu)); b=nu/(1-nu); c=(1-2*nu)/(2*(1-nu)); 
        C = a*[1 b 0
               b 1 0
               0 0 c];
    elseif FE.dim == 3
        a = E/( (1+nu)*(1-2*nu));
        b = nu;
        c = 1-nu;
        d = (1-2*nu)/2;
        C = a*[ c  b  b  0  0  0 
                b  c  b  0  0  0
                b  b  c  0  0  0 
                0  0  0  d  0  0
                0  0  0  0  d  0
                0  0  0  0  0  d];
    end

C = 0.5*(C+C');