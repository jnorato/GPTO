function compute_predefined_node_sets(requested_node_set_list)
%
% This function computes the requested node sets and stores them as 
% members of FE.node_set.
%
% Input is a cell array of strings identifying the node sets to compute
% e.g. {'T_edge','BR_pt'}
%
% this function predefines certain sets of nodes (requested by the user)
% that you can use for convenience to define displacement boundary
% conditions and forces.  IMPORTANT: they only make sense (in general) for
% rectangular / cuboidal meshes, and you must be careful to use them and/or
% change the code according to your needs.
%
% Note that an advantage of using these node sets is that you can use them
% with meshes that have different element sizes (but same dimensions)
%
%--------------------------------------------------------------------------
% 2D:
%
%  Edges:                  Points:
%   -----Top (T)-----          TL-------MT-------TR
%  |                 |          |                 |
%  |                 |          |                 |   
% Left (L)         Right (R)   ML                MR   | y
%  |                 |          |                 |   |
%  |                 |          |                 |   |
%   ---Bottom (B)----          BL-------MB-------BR    ----- x
%
%--------------------------------------------------------------------------
% 3D:
%
%  Faces:                                Edges:            
%                     Back (K)     
%               -----------------                   -------TK--------          
%             /|                /|                /|                /|
%            / |   Top (T)     / |              TL |              TR |
%           /  |              /  |              /  LK             /  RK
%          |-----------------|   |             |-------TF--------|   |
% Left (L) |   |             |   | Right (R)   |   |             |   |
%          |  / -------------|--/             LF  / -------BK----RF-/
%          | /   Bottom (B)  | /               |BL               | BR 
%          |/                |/                |/                |/
%           -----------------                   -------BF--------
%                Front (F)
%
%  Points:                                       
%         TLK---------------TRK    For edge midpoints:       
%         /|                /|       Add 'M' to the edge    
%        / |               / |       notation, e.g.,           
%       /  |              /  |       'MTK' is the midpoint    | y
%     TLF---------------TRF  |       of edge 'TK'.            |
%      |   |             |   |                                | 
%      |  BLK------------|--BRK    For face midpoints:         ---- x    
%      | /               | /          Add 'M' to the face    /    
%      |/                |/           notation, e.g.,       / 
%     BLF---------------BRF           'MT' is the midpoint   z
%                                     of face 'T'.


%% The user should not modify this function.
global FE

%% determine which node sets to compute from input list
msg.odd_n_elem = strcat('The number of elements along a dimension ',...
    'requesting a midpoint is odd,\nreturning empty list of nodes.');

nel_odd = mod(FE.mesh_input.elements_per_side(:),2)~=0;

coord_x = FE.coords(1,:);
coord_y = FE.coords(2,:);
if FE.dim == 3
    coord_z = FE.coords(3,:);
end


tol = max(abs(FE.coord_max - FE.coord_min))/1e6;
minX = FE.coord_min(1); maxX = FE.coord_max(1); avgX = (maxX - minX)/2;
minY = FE.coord_min(2); maxY = FE.coord_max(2); avgY = (maxY - minY)/2;
if FE.dim == 3
    minZ = FE.coord_min(3); maxZ = FE.coord_max(3); avgZ = (maxZ - minZ)/2;
end


if FE.dim == 2
    for i = 1:numel(requested_node_set_list)
    switch requested_node_set_list{i}
    % == Edges ==
        case 'T_edge'
            FE.node_set.T_edge = find(coord_y > maxY - tol);
        case 'B_edge'
            FE.node_set.B_edge = find(coord_y < minY + tol);
        case 'L_edge' 
            FE.node_set.L_edge = find(coord_x < minX + tol);
        case 'R_edge'
            FE.node_set.R_edge = find(coord_x > maxX - tol);
    % == Points ==
        case 'BL_pt'
            FE.node_set.BL_pt = ...
                find( coord_x < minX + tol & coord_y < minY + tol);
        case 'BR_pt'
            FE.node_set.BR_pt = ...
                find( coord_x > maxX - tol & coord_y < minY + tol);
        case 'TR_pt'
            FE.node_set.TR_pt = ...
                find( coord_x > maxX - tol & coord_y > maxY - tol);
        case 'TL_pt'
            FE.node_set.TL_pt = ...
                find( coord_x < minX + tol & coord_y > maxY - tol);
    % Note: the following ones only work if there is an even number of
    % elements on the corresponding sides, i.e., there is a node exactly in
    % the middle of the side.
        case 'ML_pt'
            FE.node_set.ML_pt = ...
                find( coord_x < minX + tol & coord_y > avgY - tol ...
                  & coord_y < avgY + tol);
            if nel_odd(2) % # of y elements is odd
               warning(msg.odd_n_elem,[])
            end
        case 'MR_pt'
            FE.node_set.MR_pt = ...
                find( coord_x > maxX - tol & coord_y > avgY - tol ...
                  & coord_y < avgY + tol);
            if nel_odd(2) % # of y elements is odd
               warning(msg.odd_n_elem,[])
            end
        case 'MB_pt'
            FE.node_set.MB_pt = ...
                find( coord_y < minY + tol & coord_x > avgX - tol ...
                  & coord_x < avgX + tol);
            if nel_odd(1) % # of x elements is odd
               warning(msg.odd_n_elem,[])
            end
        case 'MT_pt'
            FE.node_set.MT_pt = ...
                find( coord_y > maxY - tol & coord_x > avgX - tol ...
                          & coord_x < avgX + tol);
            if nel_odd(1) % # of x elements is odd
               warning(msg.odd_n_elem,[])
            end
             % Volume-center point
        case 'C_pt'
            if nel_odd(1) || nel_odd(2) % # of x or y elements is odd
                warning(msg.odd_n_elem,[])
            end
        FE.node_set.C_pt = find(coord_y > avgY - tol & coord_y < avgY + tol & ...
              coord_x > avgX - tol & coord_x < avgX + tol); 
    end
    end
elseif FE.dim == 3
    for i = 1:numel(requested_node_set_list)
    switch requested_node_set_list{i}
    % == Faces ==
        case 'T_face'
    FE.node_set.T_face = find(coord_y > maxY - tol);
        case 'B_face'
    FE.node_set.B_face = find(coord_y < minY + tol);
        case 'L_face'
    FE.node_set.L_face = find(coord_x < minX + tol);
        case 'R_face'
    FE.node_set.R_face = find(coord_x > maxX - tol);    
        case 'K_face'
    FE.node_set.K_face = find(coord_z < minZ + tol);
        case 'F_face'
    FE.node_set.F_face = find(coord_z > maxZ - tol);
    % == Edges ==
        case 'TK_edge'
    FE.node_set.TK_edge = find(coord_y > maxY - tol & coord_z < minZ + tol);
        case 'BK_edge'
    FE.node_set.BK_edge = find(coord_y < minY + tol & coord_z < minZ + tol);
        case 'LK_edge'
    FE.node_set.LK_edge = find(coord_x < minX + tol & coord_z < minZ + tol);
        case 'RK_edge'
    FE.node_set.RK_edge = find(coord_x > maxX - tol & coord_z < minZ + tol);
        case 'TF_edge'
    FE.node_set.TF_edge = find(coord_y > maxY - tol & coord_z > maxZ - tol);
        case 'BF_edge'
    FE.node_set.BF_edge = find(coord_y < minY + tol & coord_z > maxZ - tol);
        case 'LF_edge'
    FE.node_set.LF_edge = find(coord_x < minX + tol & coord_z > maxZ - tol);
        case 'RF_edge'
    FE.node_set.RF_edge = find(coord_x > maxX - tol & coord_z > maxZ - tol);
        case 'TL_edge'
    FE.node_set.TL_edge = find(coord_y > maxY - tol & coord_x < minX - tol);
        case 'TR_edge'
    FE.node_set.TR_edge = find(coord_y > maxY - tol & coord_x > maxX - tol);
        case 'BL_edge'
    FE.node_set.BL_edge = find(coord_y < minY + tol & coord_x < minX - tol);
        case 'BR_edge'
    FE.node_set.BR_edge = find(coord_y < minY + tol & coord_x > maxX - tol);   
    % == Points ==
        case 'BLK_pt'
    FE.node_set.BLK_pt = find( coord_x < minX + tol & coord_y < minY + tol & ...
                   coord_z < minZ + tol);
        case 'BRK_pt'
    FE.node_set.BRK_pt = find( coord_x > maxX - tol & coord_y < minY + tol & ...
                   coord_z < minZ + tol);
        case 'TRK_pt'
    FE.node_set.TRK_pt = find( coord_x > maxX - tol & coord_y > maxY - tol & ...
                   coord_z < minZ + tol);
        case 'TLK_pt'
    FE.node_set.TLK_pt = find( coord_x < minX + tol & coord_y > maxY - tol & ...
                   coord_z < minZ + tol);   
        case 'BLF_pt'
    FE.node_set.BLF_pt = find( coord_x < minX + tol & coord_y < minY + tol & ...
                   coord_z > maxZ - tol);
        case 'BRF_pt'
    FE.node_set.BRF_pt = find( coord_x > maxX - tol & coord_y < minY + tol & ...
                   coord_z > maxZ - tol);
        case 'TRF_pt'
    FE.node_set.TRF_pt = find( coord_x > maxX - tol & coord_y > maxY - tol & ...
                   coord_z > maxZ - tol);
        case 'TLF_pt'
    FE.node_set.TLF_pt = find( coord_x < minX + tol & coord_y > maxY - tol & ...
                   coord_z > maxZ - tol);
    % *****
    % Note: the following ones only work if there is an even number of
    % elements on the corresponding sides, i.e., there is a node exactly in
    % the middle of the side.
    %
    % Mid-edge points
        case 'MLK_pt'
            if nel_odd(2) % # of y elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MLK_pt = find( coord_x < minX + tol & coord_y > avgY - tol ...
                  & coord_y < avgY + tol & coord_z < minZ + tol);
        case 'MRK_pt'
            if nel_odd(2) % # of y elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MRK_pt = find( coord_x > maxX - tol & coord_y > avgY - tol ...
                  & coord_y < avgY + tol & coord_z < minZ + tol);
        case 'MBK_pt'
            if nel_odd(1) % # of x elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MBK_pt = find( coord_y < minY + tol & coord_x > avgX - tol ...
                  & coord_x < avgX + tol & coord_z < minZ + tol);
        case 'MTK_pt'
            if nel_odd(1) % # of x elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MTK_pt = find( coord_y > maxY - tol & coord_x > avgX - tol ...
                  & coord_x < avgX + tol & coord_z < minZ + tol); 
        case 'MLF_pt'
            if nel_odd(2) % # of y elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MLF_pt = find( coord_x < minX + tol & coord_y > avgY - tol ...
                  & coord_y < avgY + tol & coord_z > maxZ - tol);
        case 'MRF_pt'
            if nel_odd(2) % # of y elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MRF_pt = find( coord_x > maxX - tol & coord_y > avgY - tol ...
                  & coord_y < avgY + tol & coord_z > maxZ - tol);
        case 'MBF_pt'
            if nel_odd(1) % # of x elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MBF_pt = find( coord_y < minY + tol & coord_x > avgX - tol ...
                  & coord_x < avgX + tol & coord_z > maxZ - tol);
        case 'MTF_pt'
            if nel_odd(1) % # of x elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MTF_pt = find( coord_y > maxY - tol & coord_x > avgX - tol ...
                  & coord_x < avgX + tol & coord_z > maxZ - tol);     
        case 'MBL_pt'
            if nel_odd(3) % # of z elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MBL_pt = find( coord_x < minX + tol & coord_z > avgZ - tol ...
                  & coord_z < avgZ + tol & coord_y < minY + tol);
        case 'MBR_pt'
            if nel_odd(3) % # of z elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MBR_pt = find( coord_x > maxX - tol & coord_z > avgZ - tol ...
                  & coord_z < avgZ + tol & coord_y < minY + tol);
        case 'MTL_pt'
            if nel_odd(3) % # of z elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MTL_pt = find( coord_x < minX + tol & coord_z > avgZ - tol ...
                  & coord_z < avgZ + tol & coord_y > maxY - tol);
        case 'MTR_pt'
            if nel_odd(3) % # of z elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MTR_pt = find( coord_x > maxX - tol & coord_z > avgZ - tol ...
                  & coord_z < avgZ + tol & coord_y > maxY - tol);   
    % Mid-face points
        case 'MB_pt'
            if nel_odd(1) || nel_odd(3) % # of x or z elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MB_pt = find( coord_y < minY + tol & ...
              coord_x > avgX - tol & coord_x < avgX + tol & ...
              coord_z > avgZ - tol & coord_z < avgZ + tol);
        case 'MT_pt'
            if nel_odd(1) || nel_odd(3) % # of x or z elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MT_pt = find( coord_y > maxY - tol & ...
              coord_x > avgX - tol & coord_x < avgX + tol & ...
              coord_z > avgZ - tol & coord_z < avgZ + tol); 
        case 'ML_pt'
            if nel_odd(2) || nel_odd(3) % # of y or z elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.ML_pt = find( coord_x < minX + tol & ...
              coord_y > avgY - tol & coord_y < avgY + tol & ...
              coord_z > avgZ - tol & coord_z < avgZ + tol);
        case 'MR_pt'
            if nel_odd(2) || nel_odd(3) % # of y or z elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MR_pt = find( coord_x > maxX - tol & ...
              coord_y > avgY - tol & coord_y < avgY + tol & ...
              coord_z > avgZ - tol & coord_z < avgZ + tol);   
        case 'MK_pt'
            if nel_odd(1) || nel_odd(2) % # of x or y elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MK_pt = find( coord_z < minZ + tol & ...
              coord_y > avgY - tol & coord_y < avgY + tol & ...
              coord_x > avgX - tol & coord_x < avgX + tol);    
        case 'MF_pt'
            if nel_odd(1) || nel_odd(2) % # of x or y elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.MF_pt = find( coord_z > maxZ - tol & ...
              coord_y > avgY - tol & coord_y < avgY + tol & ...
              coord_x > avgX - tol & coord_x < avgX + tol);
    % Volume-center point
        case 'C_pt'
            if nel_odd(1) || nel_odd(2) || nel_odd(3) % # of x,y or z elements is odd
                warning(msg.odd_n_elem,[])
            end
    FE.node_set.C_pt = find( coord_z < minZ + tol & coord_z > maxZ - tol & ...
              coord_y > avgY - tol & coord_y < avgY + tol & ...
              coord_x > avgX - tol & coord_x < avgX + tol); 
    end
    end
end

end
