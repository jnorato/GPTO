function plot_design(varargin)
%
% Plot_design(fig,point_mat,bar_mat) plots the bars into the figure fig
%
% fig is the number (or handle) of the figure to use
%
global GEOM FE

nargin = length(varargin);
if nargin == 0
    fig = 1;
    point_mat = GEOM.current_design.point_matrix;
    bar_mat = GEOM.current_design.bar_matrix;
elseif nargin == 1
    fig = varargin{1};
    point_mat = GEOM.current_design.point_matrix;
    bar_mat = GEOM.current_design.bar_matrix;        
elseif nargin == 3
    fig = varargin{1};
    point_mat = varargin{2};
    bar_mat = varargin{3}; 
else
    error('plot_design received an invalid number of arguments.')
end

%% user specified parameters

% set the color of the bars
bar_color = [1 0 0];    % red 
% set size variable threshold to plot bars
size_tol = 0.05;
% set the resolution of the bar-mesh (>=8 and even)
N = 16; 

%% bar points,vectors and length
bar_tol = 1e-12; % threshold below which bar is just a circle
n_bar = size(bar_mat,1);
x_1b = zeros(3,n_bar);  x_2b = zeros(3,n_bar); % these are always in 3D 
pt1_IDs = bar_mat(:,2); pt2_IDs = bar_mat(:,3); 
x_1b(1:FE.dim,:) = point_mat(... 
    GEOM.point_mat_row(pt1_IDs),... 
    2:end).'; 
x_2b(1:FE.dim,:) = point_mat(... 
    GEOM.point_mat_row(pt2_IDs),... 
    2:end).'; 
n_b = x_2b - x_1b;
l_b = sqrt(dot(n_b,n_b)); % length of the bars
%% principle bar direction
e_hat_1b = n_b./l_b;
    short = l_b < bar_tol;
    e_hat_1b(:,short) = repmat([1;0;0],1,sum(short));
% determine coordinate direction most orthogonal to bar
case_1 = abs(n_b(1,:)) < abs(n_b(2,:)) & abs(n_b(1,:)) < abs(n_b(3,:));
case_2 = abs(n_b(2,:)) < abs(n_b(1,:)) & abs(n_b(2,:)) < abs(n_b(3,:));
case_3 = ~(case_1 | case_2);
%% secondary bar direction
e_alpha = zeros(size(n_b));
    e_alpha(1,case_1) = 1;
    e_alpha(2,case_2) = 1;
    e_alpha(3,case_3) = 1;
e_2b = l_b.*cross(e_alpha,e_hat_1b);
norm_e_2b = sqrt(sum(e_2b.^2));
e_hat_2b = e_2b./norm_e_2b;
%% tertiary bar direction
e_3b = cross(e_hat_1b,e_hat_2b);
norm_e_3b = sqrt(sum(e_3b.^2));
e_hat_3b = e_3b./norm_e_3b;
%% Jacobian transformation (rotation) matrix R
R_b = zeros(3,3,n_bar);
R_b(:,1,:) = e_hat_1b;
R_b(:,2,:) = e_hat_2b;
R_b(:,3,:) = e_hat_3b;
    
%% create the reference-sphere mesh
if FE.dim == 3
    [x,y,z] = sphere(N);
    sx1 = z(1:N/2,:);
    sy1 = x(1:N/2,:);
    sz1 = y(1:N/2,:);
    sx2 = z(N/2+1:end,:);
    sy2 = x(N/2+1:end,:);
    sz2 = y(N/2+1:end,:);
    X1 = [sx1(:), sy1(:), sz1(:)]';
    X2 = [sx2(:), sy2(:), sz2(:)]';
else
    N = N^2; 
    t = linspace(-pi/2,-pi/2+2*pi,N+1)';
    x = -cos(t);
    y = sin(t);
    z = zeros(size(t));

    cxo = x(1:N/2);
    cyo = y(1:N/2);
    czo = z(1:N/2);

    cxf = x(N/2+1:end);
    cyf = y(N/2+1:end);
    czf = z(N/2+1:end);

    X1 = [cxo(:), cyo(:), czo(:)]';
    X2 = [cxf(:), cyf(:), czf(:)]';
end


%% create the surface for each bar and plot it 
figure(fig);
cla;
hold on;

r_b = bar_mat(:,end);
alpha = bar_mat(:,end-1);
    for b = 1:n_bar
        bar_X1 = r_b(b) * R_b(:,:,b) * X1 + x_1b(:,b);
        bar_X2 = r_b(b) * R_b(:,:,b) * X2 + x_2b(:,b);
        if FE.dim == 3
            bar_x1 = reshape(bar_X1(1,:), [N/2, N+1]);
            bar_y1 = reshape(bar_X1(2,:), [N/2, N+1]);
            bar_z1 = reshape(bar_X1(3,:), [N/2, N+1]);

            bar_x2 = reshape(bar_X2(1,:), [N/2+1, N+1]);
            bar_y2 = reshape(bar_X2(2,:), [N/2+1, N+1]);
            bar_z2 = reshape(bar_X2(3,:), [N/2+1, N+1]); 
        else
            bar_x1 = bar_X1(1,:)';
            bar_y1 = bar_X1(2,:)';
            bar_z1 = bar_X1(3,:)';

            bar_x2 = bar_X2(1,:)';
            bar_y2 = bar_X2(2,:)';
            bar_z2 = bar_X2(3,:)';
        end

        bar_x = [bar_x1; bar_x2];
        bar_y = [bar_y1; bar_y2];
        bar_z = [bar_z1; bar_z2];

        Color = bar_color;
        Alpha = alpha(b).^2;
        if Alpha > size_tol
            C = colormap('gray');
            colormap(C.*Color) % color the gray-scale map

            if FE.dim == 3
                s = surfl(bar_x,bar_y,bar_z); % shaded surface with lighting
                s.LineStyle = 'none';
                s.FaceAlpha = Alpha;
                shading interp
            else
                s = patch(bar_x,bar_y,Color);
                s.FaceAlpha = Alpha;
            end
        end
    end