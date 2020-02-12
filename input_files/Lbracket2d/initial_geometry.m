function initial_geometry()
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
    [
    1.0000   00.5000   00.5000
    2.0000   00.5000   37.5000
    3.0000   00.5000   62.5000
    4.0000   00.5000   99.5000
    5.0000   37.5000   00.5000
    6.0000   37.5000   37.5000
    7.0000   37.5000   62.5000
    8.0000   37.5000   99.5000
    9.0000   62.5000   00.5000
   10.0000   62.5000   37.5000
   11.0000   99.5000   00.5000
   12.0000   99.5000   37.5000
   ];

 % Format of bar_matrix is [ bar_id, pt1, pt2, alpha, w/2 ], where alpha is
 % the initial value of the bar's size variable, and w/2 the initial radius
 % of the bar.
 %
bar_matrix = ... 
     [
    1.0000    1.0000    2.0000    0.5000    2.0000
    2.0000    1.0000    5.0000    0.5000    2.0000
    3.0000    2.0000    3.0000    0.5000    2.0000
    4.0000    2.0000    5.0000    0.5000    2.0000
    5.0000    2.0000    6.0000    0.5000    2.0000
    6.0000    3.0000    4.0000    0.5000    2.0000
    7.0000    3.0000    6.0000    0.5000    2.0000
    8.0000    3.0000    7.0000    0.5000    2.0000
    9.0000    4.0000    7.0000    0.5000    2.0000
   10.0000    4.0000    8.0000    0.5000    2.0000
   11.0000    5.0000    6.0000    0.5000    2.0000
   12.0000    5.0000    9.0000    0.5000    2.0000
   13.0000    6.0000    7.0000    0.5000    2.0000
   14.0000    6.0000    9.0000    0.5000    2.0000
   15.0000    6.0000   10.0000    0.5000    2.0000
   16.0000    7.0000    8.0000    0.5000    2.0000
   17.0000    9.0000   10.0000    0.5000    2.0000
   18.0000    9.0000   11.0000    0.5000    2.0000
   19.0000   10.0000   11.0000    0.5000    2.0000
   20.0000   10.0000   12.0000    0.5000    2.0000
   21.0000   11.0000   12.0000    0.5000    2.0000
   ];

% *** Do not modify the code below ***
GEOM.initial_design.point_matrix = point_matrix;
GEOM.initial_design.bar_matrix = bar_matrix;

fprintf('initialized %dd initial design with %d points and %d bars\n',...
    FE.dim,...
    size(GEOM.initial_design.point_matrix,1),...
    size(GEOM.initial_design.bar_matrix,1));