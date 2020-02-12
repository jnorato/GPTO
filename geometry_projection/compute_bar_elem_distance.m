function [dist,Ddist_Dbar_ends] = compute_bar_elem_distance()
%
% This function computes an array dist of dimensions n_bar x n_elem with 
% the distance from the centroid of each element to each bar's medial axis.
% 
% Ddist_Dbar_ends is a 3-dimensional array of dimensions n_bar_dofs x n_bar
% x n_elem that contains the sensitivities of the signed distances in dist
% with respect to each of the n__bar_dofs coordinates of the medial axis 
% end points.

%%
global FE GEOM OPT

%% set parameters
tol = 1e-12; % tolerance on the length of a bar

n_elem = FE.n_elem;
dim = FE.dim;
n_bar = GEOM.n_bar;
n_bar_dofs = 2*dim;

% The following code is vectorized over the bars and the elements. We
% have to be consistent with the order of indices to perform element-
% wise array operations. The order of indices is (dim,bar,element)

points = GEOM.current_design.point_matrix(:,2:end).';
x_1b = points(OPT.bar_dv(1:dim,:));       % (i,b) 
x_2b = points(OPT.bar_dv(dim+1:2*dim,:)); % (i,b) 
x_e = permute(FE.centroids ,[1,3,2]);     % (i,1,e) 

a_b = x_2b - x_1b; % Numerator of Eq. (11)
l_b = sqrt(sum(a_b.^2, 1)); % length of the bars, Eq. (10)
l_b(l_b < tol) = 1; % To avoid division by zero
a_b = a_b./l_b;  % normalize the bar direction to unit vector, Eq. (11)

x_e_1b = x_e - x_1b;                   % (i,b,e) 
x_e_2b = x_e - x_2b;                   % (i,b,e) 
norm_x_e_1b = sqrt(sum(x_e_1b.^2, 1)); % (1,b,e)
norm_x_e_2b = sqrt(sum(x_e_2b.^2, 1)); % (1,b,e) 

l_be = sum(x_e_1b.*a_b, 1);       % (1,b,e), Eq. (12)
vec_r_be = x_e_1b - l_be.*a_b;    % (i,b,e)
r_be = sqrt(sum(vec_r_be.^2, 1)); % (1,b,e), Eq. (13)

branch1 = l_be <= 0.0;            % (1,b,e)
branch2 = l_be > l_b;             % (1,b,e)
branch3 = ~(branch1 | branch2);   % (1,b,e)

% Compute the distances, Eq. (14)
dist_tmp =  branch1.* norm_x_e_1b + ...
        branch2.* norm_x_e_2b + ...
        branch3.* r_be;           % (1,b,e)

dist = permute(dist_tmp,[2,3,1]); % (b,e)

%% compute sensitivities

Dd_be_Dx_1b = zeros([FE.dim,n_bar,n_elem]);
Dd_be_Dx_2b = zeros([FE.dim,n_bar,n_elem]);

d_inv = dist_tmp.^-1;    % This can render a division by zero (if point 
d_inv(isinf(d_inv)) = 0; % lies on medial axis), and so we now fix it
l_be_over_l_b = l_be./l_b;

%% The sensitivities below are obtained from Eq. (30)

%% sensitivity to x_1b
if sum(branch1(:)) > 0
Dd_be_Dx_1b(:,branch1) = -x_e_1b(:,branch1) .* d_inv(:,branch1);
end
% Dd_bd_Dx_1b(:,branch2) = 0;
if sum(branch3(:)) > 0
Dd_be_Dx_1b(:,branch3) = ...
    -vec_r_be(:,branch3).*d_inv(:,branch3).* ...
        (1 - l_be_over_l_b(:,branch3));
end

%% sensitivity to x_2b
% Dd_bd_Dx_2b(:,branch1) = 0;
if sum(branch2(:)) ~= 0
Dd_be_Dx_2b(:,branch2) = -x_e_2b(:,branch2) .* d_inv(:,branch2);
end
if sum(branch3(:)) ~= 0
Dd_be_Dx_2b(:,branch3) = ...
    -vec_r_be(:,branch3).*d_inv(:,branch3).*l_be_over_l_b(:,branch3);
end
%% assemble the sensitivities to the bar design parameters (scaled)

Ddist_Dbar_ends = zeros([n_bar_dofs, n_bar,n_elem]);
Ddist_Dbar_ends(     (1:dim),:,:) = Dd_be_Dx_1b.*OPT.scaling.point_scale;
Ddist_Dbar_ends(dim+(1:dim) ,:,:) = Dd_be_Dx_2b.*OPT.scaling.point_scale;

Ddist_Dbar_ends = permute(Ddist_Dbar_ends,[2,3,1]);

