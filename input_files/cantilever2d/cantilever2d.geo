// Gmsh project created on Sat Dec 15 11:40:04 2018
SetFactory("OpenCASCADE");
//+
Point(1) = {0, 0, 0, 1.0};
//+
Point(2) = {20, 0, 0, 1.0};
//+
Point(3) = {20, 10, 0, 1.0};
//+
Point(4) = {0, 10, 0, 1.0};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 1};
//+
Curve Loop(1) = {1, 2, 3, 4};
//+
Plane Surface(1) = {1};
//+
Transfinite Surface {1};
//+
Transfinite Curve {3, 1} = 129 Using Progression 1;
//+
Transfinite Curve {4, 2} = 65 Using Progression 1;
//+
Recombine Surface {1};
