include <../pegmixer.scad>
include <../BOSL2/std.scad>

/*
 *  This example illustrates using a `block` as a simple backplate for a more complex object
 */

back_thickness= 2;      // thickness of the surface with pegs

arm_widths= [3, 10];    // The front ([0]) and back ([1]) arm width. Narrowing balances strength vs material
arm_length= 100;        // the distance from the backplate to the end of the arm */

roll_w= 35;             // the roll arc's bottom width
roll_thickness= 13;     // the height of the arc
roll_l= 30;             // the length of the roll arc's extension from the arm 

heights= [10, 40];      // the height of the front ([0]) and back ([1]) arm

left_facing= false;     // false = render a right facing part, true = render a left facing part
epsilon= 0.01;

pegmixer()
    solid([arm_widths[1], back_thickness, heights[1]]);

hull() {
    fwd(back_thickness/2)
        cuboid([arm_widths[1],epsilon, heights[1]]);

    move([(left_facing ? 
        arm_widths[1]-arm_widths[0] : arm_widths[0]-arm_widths[1]
    )/2, -arm_length, -(heights[1]-heights[0])/2])
        cuboid([arm_widths[0], epsilon, heights[0]]);
}

move([left_facing ? arm_widths[1]/2 : -roll_w , -arm_length+(roll_w/2), -heights[1]/2])
    rotate([90, 0, 90])
        linear_extrude(roll_l)
            arc(width=roll_w, thickness=roll_thickness);