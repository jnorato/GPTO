// Gmsh project created on Sat Dec 15 11:56:40 2018
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
Point(5) = {0, 0, 10, 1.0};
//+
Point(6) = {20, 0, 10, 1.0};
//+
Point(7) = {20, 10, 10, 1.0};
//+
Point(8) = {0, 10, 10, 1.0};
//+
Line(1) = {1, 2};
//+
Line(2) = {2, 3};
//+
Line(3) = {3, 4};
//+
Line(4) = {4, 1};
//+
Line(5) = {5, 6};
//+
Line(6) = {6, 7};
//+
Line(7) = {7, 8};
//+
Line(8) = {8, 5};
//+
Line(9) = {1, 5};
//+
Line(10) = {2, 6};
//+
Line(11) = {3, 7};
//+
Line(12) = {4, 8};
//+
Curve Loop(1) = {1, 2, 3, 4};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {5, 6, 7, 8};
//+
Plane Surface(2) = {2};
//+
Curve Loop(3) = {11, 7, -12, -3};
//+
Plane Surface(3) = {3};
//+
Curve Loop(4) = {5, -10, -1, 9};
//+
Plane Surface(4) = {4};
//+
Curve Loop(5) = {9, -8, -12, 4};
//+
Plane Surface(5) = {5};
//+
Curve Loop(6) = {10, 6, -11, -2};
//+
Plane Surface(6) = {6};
//+
Surface Loop(1) = {2, 4, 6, 3, 5, 1};
//+
Volume(1) = {1};
//+

//+
Transfinite Surface {5};
//+
Transfinite Surface {6} Right;
//+
Transfinite Surface {2};
//+
Transfinite Surface {1} Right;
//+
Transfinite Surface {4};
//+
Transfinite Surface {3} Right;
//+
Recombine Surface {3, 6, 2, 4, 1, 5};
//+
Transfinite Volume{1} = {1, 2, 3, 4, 5, 6, 7, 8};

//+
Transfinite Curve {9, 4, 12, 8, 10, 2, 11, 6} = 11 Using Progression 1;
//+
Transfinite Curve {1, 3, 7, 5} = 21 Using Progression 1;
