function init_FE()
%
% Initialize the Finite Element structure
%
global FE

switch FE.mesh_input.type
    case 'generate'
        generate_mesh();
    case 'read-home-made'
        load(FE.mesh_input.mesh_filename);
    case 'read-gmsh'
        read_gmsh();
    otherwise
        error('Unidentified mesh input type.');
end

% Compute element volumes and centroidal coordinates
FE_compute_element_info();

% Setup boundary conditions
run(FE.mesh_input.bcs_file);

% initialize the fixed/free partitioning scheme:
FE_init_partitioning();

% assemble the boundary conditions
FE_assemble_BC();

% compute elastic coefficients
FE_compute_constitutive_matrices();

% compute the element stiffness matrices
FE_init_element_stiffness();
