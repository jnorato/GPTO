function init_geometry()
%
% Initialize GEOM structure with initial design
%
global GEOM

if ~GEOM.initial_design.restart
    run(GEOM.initial_design.path)
    
    % To use non contiguous numbers in the point_mat, we need to grab the
    % points whose ID matches the number specified by bar_mat. We achieve 
    % this via a map (sparse vector) between ppoint_mat_rows and pt_IDs st
    % point_mat_row(point_ID) = row # of point_mat for point_ID
    pt_IDs = GEOM.initial_design.point_matrix(:,1);
    GEOM.point_mat_row = sparse(pt_IDs,1,[1:length(pt_IDs)]);
else
    load(GEOM.initial_design.path);
    GEOM.initial_design.point_matrix = GEOM.current_design.point_matrix;
    GEOM.initial_design.bar_matrix = GEOM.current_design.bar_matrix;
end

% plot the initial design:
if GEOM.initial_design.plot
    plot_design(1,...
        GEOM.initial_design.point_matrix,...
        GEOM.initial_design.bar_matrix);
    axis equal;
    title('initial design');
    drawnow;
end

GEOM.n_point = size(GEOM.initial_design.point_matrix,1);
GEOM.n_bar = size(GEOM.initial_design.bar_matrix,1);
