function initial_geometry_cantilever3d()
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
% the initial bar radius (half-width of the bar).
%
% Note that this way of defining the bars allows for bars to be 'floating'
% (if the endpoints of a bar are not shared by any other bar) or
% 'connected' (if two or more bars share the same endpoint).
%

global FE GEOM 

point_matrix = ... % [ point_id, x, y, z ]
    [1    2.4, 2.5 , 2.5 
     2    2.6, 2.5 , 2.5
     3    7.4, 2.5 , 2.5
     4    7.6, 2.5 , 2.5
     5   12.4, 2.5 , 2.5
     6   12.6, 2.5 , 2.5
     7   17.4, 2.5 , 2.5
     8   17.6, 2.5 , 2.5
     9    2.4, 7.5 , 2.5
     10   2.6, 7.5 , 2.5
     11   7.4, 7.5 , 2.5
     12   7.6, 7.5 , 2.5
     13  12.4, 7.5 , 2.5
     14  12.6, 7.5 , 2.5
     15  17.4, 7.5 , 2.5
     16  17.6, 7.5 , 2.5
     17   2.4, 2.5 , 7.5
     18   2.6, 2.5 , 7.5
     19   7.4, 2.5 , 7.5
     20   7.6, 2.5 , 7.5
     21  12.4, 2.5 , 7.5
     22  12.6, 2.5 , 7.5
     23  17.4, 2.5 , 7.5
     24  17.6, 2.5 , 7.5
     25   2.4, 7.5 , 7.5
     26   2.6, 7.5 , 7.5
     27   7.4, 7.5 , 7.5
     28   7.6, 7.5 , 7.5
     29  12.4, 7.5 , 7.5
     30  12.6, 7.5 , 7.5
     31  17.4, 7.5 , 7.5
     32  17.6, 7.5 , 7.5];

bar_matrix = ... % [bar_id pt1, pt2, size, radius]
     [1 , 1 , 2 , 0.5, 0.75
      2 , 3 , 4 , 0.5, 0.75
      3 , 5 , 6 , 0.5, 0.75
      4 , 7 , 8 , 0.5, 0.75
      5 , 9 , 10, 0.5, 0.75
      6 , 11, 12, 0.5, 0.75
      7 , 13, 14, 0.5, 0.75
      8 , 15, 16, 0.5, 0.75
      9 , 17, 18, 0.5, 0.75
      10, 19, 20, 0.5, 0.75
      11, 21, 22, 0.5, 0.75
      12, 23, 24, 0.5, 0.75
      13, 25, 26, 0.5, 0.75
      14, 27, 28, 0.5, 0.75
      15, 29, 30, 0.5, 0.75
      16, 31, 32, 0.5, 0.75];
  

  % *** Do not modify the code below ***
GEOM.initial_design.point_matrix = point_matrix;
GEOM.initial_design.bar_matrix = bar_matrix;


fprintf('initialized %dd initial design with %d points and %d bars\n',...
    FE.dim,...
    size(GEOM.initial_design.point_matrix,1),...
    size(GEOM.initial_design.bar_matrix,1));