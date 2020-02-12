function initial_geometry_Lbracket2d_floating()
%
%% Initial design input file 
%
% *** THIS SCRIPT HAS TO BE CUSTOMIZED BY THE USER ***
%
% In this file, you must create two matrices that describe the initial
% design of bars.
%
% The first matrix contains the IDs (integer) and coordinates of the
% endpoints of the bars (point_matrix).
%
% The second matrix defines the IDs of the points that make up each bar.
% This matrix also sets the initial value of each bar's size variable, and
% the initial bar radius (half-width of the bar in 2-d).
%
% Note that this way of defining the bars allows for bars to be 'floating'
% (if the endpoints of a bar are not shared by any other bar) or
% 'connected' (if two or more bars share the same endpoint).
%

% *** Do not modify the line below ***
global FE GEOM 

% Format of point_matrix is [ point_id, x, y] for 2-d problems, and 
% [ point_id, x, y, z] for 3-d problems)

point_matrix = ... 
    [1 10 10
2 10 30
3 30 10
4 30 30
5 50 10
6 50 30
7 70 10
8 70 30
9 10 60
10 10 80
11 30 60
12 30 80
13 10 50
14 30 50
15 15 20
16 25 20
17 35 20
18 45 20
19 55 20
20 65 20
21 90 10
22 90 30 ];

 % Format of bar_matrix is [ bar_id, pt1, pt2, alpha, w/2 ], where alpha is
 % the initial value of the bar's size variable, and w/2 the initial radius
 % of the bar.
 %
bar_matrix = ... 
     [1 1 2 0.500 4.0 
2 3 4 0.500 4.0 
3 5 6 0.500 4.0 
4 7 8 0.500 4.0 
5 9 10 0.500 4.0 
6 11 12 0.500 4.0 
7 13 14 0.500 4.0 
8 15 16 0.500 4.0 
9 17 18 0.500 4.0 
10 19 20 0.500 4.0 
11 21 22 0.500 4.0 ];

bar_matrix(:,end) = 2;

% *** Do not modify the code below ***
GEOM.initial_design.point_matrix = point_matrix;
GEOM.initial_design.bar_matrix = bar_matrix;

fprintf('initialized %dd initial design with %d points and %d bars\n',...
    FE.dim,...
    size(GEOM.initial_design.point_matrix,1),...
    size(GEOM.initial_design.bar_matrix,1));