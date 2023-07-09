include <../pegmixer.scad>

/*
 * Example that illustrates:
 *  - A hole in the bottom of the box with `box_bottom_hole`
 *  - A solid, non-thinning box with eased over edges
 */
 
pegmixer(wall_thickness= 6) 
    box_bottom_hole([23,18])
        box(use_brace= false, use_thinning= false, [48,30,50]);