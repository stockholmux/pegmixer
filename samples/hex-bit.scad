include <../pegmixer.scad>
include <../BOSL2/std.scad>

/*
 * Complex example that illustrates:
 *  - how a short Z on `dims` creates a angled geometery.
 *  - how to subtract from a `solid`
 * 
 * Note: with OpenSCAD 2021.1 the preview looks a little funny, but renders out fine.
 */

bit_wall= 5;                // the wall around the bits
bit_id= 6.9;                // the inner d of the bit
bit_hole_depth= 10;         // how far the bit goes into the parent geometry
bit_end_width = 6;          // measurement of the hex part of the bit

height_before_angle = 12;   // on the `solid` this is height of the front part
first_row_angle= 45;        // angle of the first row of bits
second_row_angle= 0;        // angle of the second row of bits

number_of_bits= 10;         // number of bits per row

bit_rect_length= bit_id + bit_wall*2;
bit_center_to_center= bit_id + bit_wall;
center_to_center_width = (number_of_bits-1)*bit_center_to_center;
total_width = (bit_end_width * 2) + center_to_center_width;

difference() {
    pegmixer(wall_thickness= 2) 
        solid([total_width,bit_rect_length,height_before_angle]);

    rotate([first_row_angle, 0, 0])
        bit_row(bit_hole_depth*2);

    translate([0,0,height_before_angle])
        rotate([second_row_angle, 0, 0])
            bit_row(bit_hole_depth*2);
}


module bit_row(depth= bit_hole_depth)
    right(center_to_center_width/2) // correct for starting on centers
        linear_extrude(depth)
            for (i = [0:(number_of_bits-1)]) left(i*bit_center_to_center) 
                bit_hole_2d();


module bit_hole_2d() hexagon(id=bit_id);