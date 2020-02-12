Point(1) = {0., 0., 0, 1.0};
//+
Point(2) = {0., 40, 0, 1.0};
//+
Point(3) = {0., 100, 0, 1.0};
//+
Point(4) = {100, 0, 0, 1.0};
//+
Point(5) = {100, 40, 0, 1.0};
//+
Point(6) = {40, 100, 0, 1.0};
//+
Point(7) = {40, 40, 0, 1.0};
//+
Point(8) = {40, 0, 0, 1.0};
//+
Line(1) = {1, 8};
//+
Line(2) = {8, 4};
//+
Line(3) = {4, 5};
//+
Line(4) = {5, 7};
//+
Line(5) = {7, 8};
//+
Line(6) = {1, 2};
//+
Line(7) = {7, 2};
//+
Line(8) = {2, 3};
//+
Line(9) = {3, 6};
//+
Line(10) = {6, 7};
//+
Curve Loop(1) = {1, -5, 7, -6};
//+
Plane Surface(1) = {1};
//+
Curve Loop(2) = {2, 3, 4, 5};
//+
Plane Surface(2) = {2};
//+
Curve Loop(3) = {9, 10, 7, 8};
//+
Plane Surface(3) = {3};
//+
Transfinite Surface {2} = {8, 4, 5, 7};
//+
Transfinite Surface {1} = {1, 8, 7, 2};
//+
Transfinite Surface {3} = {2, 7, 6, 3};
//+
Transfinite Curve {1, 5, 7, 6, 9, 3} = 40 Using Progression 1;
//+
Transfinite Curve {2, 4, 10, 8} = 60 Using Progression 1;
//+
Recombine Surface {3, 1, 2};
