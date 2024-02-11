include <../pegmixer.scad>

// the size of the caliper's scale/ruler
ruler_size= [16.5, 3.75, 39];
// the screw at the bottom of the scale/ruler
stop_slot_h = 1.75;
// the diameter of the adjustment wheel
thumb_wheel_d= 11.25;
// the thickness of the adjustment wheel
thumb_wheel_thickness= 7.75;

// the material to add to the max size of the cutout on x/y
wall_thickness= 2;

// the width that makes it have a couple of pegs on the board side
min_mount_width= 51;
// prevent z fighting
epsilon= 0.01;

total_width= thumb_wheel_d + ruler_size.x;
thumb_wheel_r= thumb_wheel_d/2;
double_wall_thickness= wall_thickness*2;
real_width= total_width + double_wall_thickness;
solid_size= [
    max(real_width, min_mount_width),
    thumb_wheel_thickness + double_wall_thickness,
    ruler_size.z - (epsilon*4)
];


pegmixer()
    virtual(solid_size);

difference() {
   hull() {
        translate([0, solid_size.y/2, 0])
            cube([solid_size.x, epsilon, solid_size.z], center= true);

        translate([0, -solid_size.y/2, solid_size.y/4])
            cube([solid_size.x - (real_width/2), epsilon, solid_size.z - (solid_size.y/2)], center= true);
    }
 

    translate([-thumb_wheel_r, 0, -epsilon]) { 
        hull() {
            translate([0, ruler_size.y/2, -ruler_size.z/2])
                cube([ruler_size.x/2, stop_slot_h, ruler_size.z]);

            translate([0, 0, ruler_size.z/4])
                ruler_half();

            translate([(ruler_size.x + thumb_wheel_d)/2, 0, (ruler_size.z - thumb_wheel_d)/2]){
                rotate([90, 0, 0]) 
                    cylinder(d= thumb_wheel_d, h=thumb_wheel_thickness, center=true);
                
                translate([0, 0, thumb_wheel_r/2])
                    cube([thumb_wheel_d, thumb_wheel_thickness, thumb_wheel_r], center= true);
            }
        }

        translate([0, 0, -ruler_size.z/4])
            ruler_half();
    }
}


module ruler_half()
    cube([ruler_size.x, ruler_size.y, ruler_size.z/2], center= true);