include <../pegmixer.scad>

// change this value to add more/less 'columns' of dies.
number_of_jaws = 2;

jaw_upper_dims= [34, 12, 10];
jaw_lower_depth= 6.5;
jaw_lower_height= 20;
jaw_padding= 4;

epsilon= 0.01;


double_epsilon = epsilon*2;
double_jaw_padding = jaw_padding*2;

jaw_lower_dims= [jaw_upper_dims.x, jaw_lower_depth, jaw_lower_height];
solid_dims= [
    (jaw_upper_dims.x + double_jaw_padding),
    (jaw_upper_dims.y + double_jaw_padding)*2,
    (jaw_lower_height * 2) + jaw_padding
];

cut_dims = [
    solid_dims.x + double_epsilon,
    solid_dims.y / 2,
    solid_dims.z / 2
];

difference() {
    pegmixer()
        solid([
            solid_dims.x * number_of_jaws,
            solid_dims.y,
            solid_dims.z
        ]);
    translate([0, -(cut_dims.y/2 + epsilon), epsilon+cut_dims.z/2])
        cuboid([
            cut_dims.x * number_of_jaws,
            cut_dims.y,
            cut_dims.z
        ]);
    translate([(solid_dims.x * number_of_jaws/-2) - (solid_dims.x/-2), 0, 0])
            for (i = [0:(number_of_jaws-1)]) {
                translate([i*solid_dims.x, solid_dims.y * -0.25, double_epsilon]) 
                    jaw();
                translate([i*solid_dims.x, solid_dims.y * 0.25, epsilon+cut_dims.z])
                    jaw();
            }
    }


module jaw() 
    translate([0, 0, -jaw_lower_height/2]) {
        cuboid(jaw_lower_dims);
        translate([0, 0, (jaw_lower_height+jaw_upper_dims.z)/2])
            cuboid(jaw_upper_dims);
    }
