function initial_mbb2d_geometry()
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
    1   0.25	4.75	
    2   4.75	4.75	
    3   0.25	2.75	
    4   4.75	4.75	
    5   0.25	4.75	
    6   4.75	2.75	
    7   0.25	2.75	
    8   4.75	2.75	
    9   0.25	2.25	
    10  4.75	2.25	
    11  0.25	0.25	
    12  4.75	2.25	
    13  0.25	2.25	
    14  4.75	0.25	
    15  0.25	0.25	
    16  4.75	0.25	
    17  5.25	4.75	
    18  9.75	4.75	
    19  5.25	2.75	
    20  9.75	4.75	
    21  5.25	4.75	
    22  9.75	2.75	
    23  5.25	2.75	
    24  9.75	2.75	
    25  5.25	2.25	
    26  9.75	2.25	
    27  5.25	0.25	
    28  9.75	2.25	
    29  5.25	2.25	
    30  9.75	0.25	
    31  5.25	0.25	
    32  9.75	0.25	
    33  10.25	4.75	
    34  14.75	4.75	
    35  10.25	2.75	
    36  14.75	4.75	
    37  10.25	4.75	
    38  14.75	2.75	
    39  10.25	2.75	
    40  14.75	2.75	
    41  10.25	2.25	
    42  14.75	2.25	
    43  10.25	0.25	
    44  14.75	2.25	
    45  10.25	2.25	
    46  14.75	0.25	
    47  10.25	0.25	
    48  14.75	0.25	
    49  15.25	4.75	
    50  19.75	4.75	
    51  15.25	2.75	
    52  19.75	4.75	
    53  15.25	4.75	
    54  19.75	2.75	
    55  15.25	2.75	
    56  19.75	2.75	
    57  15.25	2.25	
    58  19.75	2.25	
    59  15.25	0.25	
    60  19.75	2.25	
    61  15.25	2.25	
    62  19.75	0.25	
    63  15.25	0.25	
    64  19.75	0.25    
    ];

 % Format of bar_matrix is [ bar_id, pt1, pt2, alpha, w/2 ], where alpha is
 % the initial value of the bar's size variable, and w/2 the initial radius
 % of the bar.
 %
bar_matrix = ... 
     [1 , 1 , 2 , 0.5, 0.25
      2 , 3 , 4 , 0.5, 0.25
      3 , 5 , 6 , 0.5, 0.25
      4 , 7 , 8 , 0.5, 0.25
      5 , 9 , 10, 0.5, 0.25
      6 , 11, 12, 0.5, 0.25
      7 , 13, 14, 0.5, 0.25
      8 , 15, 16, 0.5, 0.25
      9 , 17 , 18 , 0.5, 0.25
      10 , 19 , 20 , 0.5, 0.25
      11 , 21 , 22 , 0.5, 0.25
      12 , 23 , 24 , 0.5, 0.25
      13 , 25 , 26, 0.5, 0.25
      14 , 27, 28, 0.5, 0.25
      15 , 29, 30, 0.5, 0.25
      16 , 31, 32, 0.5, 0.25
      17 , 33 , 34 , 0.5, 0.25
      18 , 35 , 36 , 0.5, 0.25
      19 , 37 , 38 , 0.5, 0.25
      20 , 39 , 40 , 0.5, 0.25
      21 , 41 , 42, 0.5, 0.25
      22 , 43, 44, 0.5, 0.25
      23 , 45, 46, 0.5, 0.25
      24 , 47, 48, 0.5, 0.25
      25 , 49 , 50 , 0.5, 0.25
      26 , 51 , 52 , 0.5, 0.25
      27 , 53 , 54 , 0.5, 0.25
      28 , 55 , 56 , 0.5, 0.25
      29 , 57 , 58, 0.5, 0.25
      30 , 59, 60, 0.5, 0.25
      31 , 61, 62, 0.5, 0.25
      32 , 63, 64, 0.5, 0.25];

% *** Do not modify the code below ***
GEOM.initial_design.point_matrix = point_matrix;
GEOM.initial_design.bar_matrix = bar_matrix;

fprintf('initialized %dd initial design with %d points and %d bars\n',...
    FE.dim,...
    size(GEOM.initial_design.point_matrix,1),...
    size(GEOM.initial_design.bar_matrix,1));