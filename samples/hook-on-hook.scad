include <../pegmixer.scad>
include <../BOSL2/std.scad>

/*
 * Complex example that illustrates:
 *  - a custom peg profile
 *  - using `virtual`
 * 
 * This example is also unique in that it's designed to be printed on it's side.
 */

total_h= 50;    // height of the hook, top to bottom
hook_d= 70;     // diameter of the hook
width= 5.3;     // width of the hook

rotate([90,270,90]) 
    translate([-(total_h/2)+(hook_d+width)/2,hook_d/2,-(width/2)])
        linear_extrude(width) 
            j_hook(hook_d, total_h, width);

translate([0, -(hook_d/4) - (width/2), width/2-total_h/2])
    cube([width, hook_d/2, width], center= true);

pegmixer() 
    solid([width,width,total_h]) 
        hook_pair() {
            hook() octagon_profile();
            alignment_peg() octagon_profile();
        }

module octagon_profile() octagon(od=$hole_d * $peg_hole_percentage, realign=true);

module j_hook(d,h,w)
    let(
        r= d/2,
        leg_h= h-r
    )
        stroke(
            concat(
                [[leg_h-(w/2),-r],[0,-r]],
                arc(d=d, angle=[270,90], $fn= 60)
            ),
            width= w,
            endcap1="butt"
        );
