include <../pegmixer.scad>

can_d= 69; // spray paint
can_tolerance= 3;
holder_height= 25;
can_holder_wall_thickness= 4;

can_d_with_tolerance = can_d + can_tolerance;
can_square= can_d_with_tolerance + (can_holder_wall_thickness*2);
can_cut_height= min_back_wall()*2;

epsilon= 0.01;


module roundover()
    translate([0,0,-min_back_wall()])
        linear_extrude(min_back_wall()*2)
            difference() {
                square(can_square+epsilon*2, center= true);
                circle(d= can_square);
                translate([0,can_square/2,0])
                    square(can_square+epsilon*4, center= true);
            }
difference() {
    pegmixer() 
        solid([can_square,can_square,holder_height]);
    translate([0, 0, -(holder_height/2)+ can_holder_wall_thickness])
        cylinder(d= can_d_with_tolerance, h= can_cut_height);
    roundover();
}