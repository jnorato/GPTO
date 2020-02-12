function FE_solve
%
% This function solves the system of linear equations arising from the
% finite element discretization of Eq. (17).  It stores the displacement 
% and the reaction forces in FE.U and FE.P.

global FE
p = FE.fixeddofs_ind;
f = FE.freedofs_ind;

% save the system RHS
FE.rhs = FE.P(f) - FE.Kfp * FE.U(p);


if strcmpi(FE.analysis.solver.type, 'direct')
    if FE.analysis.solver.use_gpu == true
       warning('GPU solver selected, but only available for iterative solver, solving on CPU.')
       FE.analysis.solver.use_gpu = false;
    end
    FE.U(f) = FE.Kff\FE.rhs;
elseif strcmpi(FE.analysis.solver.type, 'iterative')
    tol = FE.analysis.solver.tol;
    maxit = FE.analysis.solver.maxit;
    % check if the user has specified use of the gpu
    if ~isfield(FE.analysis.solver,'use_gpu')
        FE.analysis.solver.use_gpu = false;
    end
    
    if FE.analysis.solver.use_gpu == true
        %% gpu solver
        ME.identifier = [];
        try
            gpu = gpuDevice(1);
            gpu.wait
            gpu.reset;
            
            A = gpuArray(FE.Kff); % copy FE.Kff to gpu
            b = FE.rhs;
            
            M1 = diag(diag(FE.Kff)); % Jacobi preconditioner
            M2 = [];
            FE.U(f) = gather(pcg(...
                A, ...
                b, ... % need to loop over columns
                tol, maxit, ...
                M1,M2, ... % preconditioner(s)
                FE.U(f) ... % use last solution as initial guess. 
                )); 
            gpu.wait
            gpu.reset;
        catch ME
            % something went wrong, display it and revert to cpu solver
            disp(ME.identifier);
            FE.analysis.solver.use_gpu = false;
        end
    elseif FE.analysis.solver.use_gpu == false
        %% cpu solver
        
        ME.identifier = [];
        try
            L = ichol(FE.Kff);
        catch ME    
        end 

        if (strcmp(ME.identifier,'MATLAB:ichol:Breakdown'))
          msg = ['ichol encountered nonpositive pivot, using no preconditioner.'];

        % you might consider tring different preconditioners (e.g. LU) in 
        % the case ichol breaks down. We will default to no preconditioner:
            FE.U(f) = pcg(FE.Kff, FE.rhs, ...
                tol,maxit, ...
                [] ... % preconditioner
                );   
        else
           msg = [];
           FE.U(f) = pcg(FE.Kff, FE.rhs, ...
                tol, maxit, ...
                L,L.' ... % preconditioner
                );  
        end
        disp(msg)
    end
end

% solve the reaction forces:
FE.P(p) = FE.Kpp*FE.U(p) + FE.Kfp' * FE.U(f);
