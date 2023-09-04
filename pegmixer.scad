include <BOSL2/std.scad>
include <BOSL2/walls.scad>
include <BOSL2/rounding.scad>

default_spacing= 25.4;
default_hole_d= 6.35;

/* root */
module pegmixer(
    spacing= default_spacing, 
    hole_d= default_hole_d, 
    board_thickness= 6.35, 
    peg_hole_percentage= 0.9, 
    peg_flatten_percentage= 0.8, 
    alignment_peg_length= 5,

    // hook parameters
    arc_d_mul= 2.5, 
    hook_end_length= 5, 
    extension_length_mul= 0.5,

    wall_thickness= 5,
    chamfer_divide= 3
) {
    $spacing = spacing;
    $hole_d = hole_d;
    $board_thickness = board_thickness;
    $peg_hole_percentage = peg_hole_percentage;
    $peg_flatten_percentage = peg_flatten_percentage;
    $alignment_peg_length = alignment_peg_length;

    $arc_d_mul= arc_d_mul;
    $hook_end_length= hook_end_length;
    $extension_length_mul= extension_length_mul;

    $wall_thickness= wall_thickness;

    $chamfer_divide= chamfer_divide;

    $epsilon= 0.01;

    children(0);
};

/* primary geometry */
module box(
    dims, 
    wall_thinning= 1,
    use_brace= true,
    use_thinning= true,
    cutting= 0
) {
    
    half_wall_thickness = $wall_thickness/2;

    chamfer_calculated= $wall_thickness/$chamfer_divide;

    top_wall = is_undef($top_wall) ? false : $top_wall;
    top_add_h = top_wall ? $wall_thickness : 0;

    left_wall = is_undef($left_wall) ? true : $left_wall;
    right_wall = is_undef($right_wall) ? true : $right_wall;
    
    side_wall_thickness = $wall_thickness * ((left_wall ? 1 : 0) + (right_wall ? 1 : 0));

    module side_wall() {
        h= is_undef($side_wall_height) ? dims.z + $wall_thickness + top_add_h : $side_wall_height;
        l=  dims.y + side_wall_thickness;
        if (use_thinning) {
            thinning_wall(
                h= h, 
                l= l, 
                strut= $wall_thickness, 
                thick= $wall_thickness, 
                wall= wall_thinning, 
                braces= use_brace
            );
        } else {
            cuboid(
                [$wall_thickness, l,  h],
                teardrop= true, 
                chamfer= chamfer_calculated,
                edges= [LEFT+FWD, RIGHT+FWD, BOT+LEFT, BOT+RIGHT, FRONT+BOT, TOP+FWD, TOP+LEFT]
            );
        }
    }

    module front_wall() {
        h= is_undef($front_wall_height) ? dims.z + $wall_thickness + top_add_h : $front_wall_height;
        l= dims.x + side_wall_thickness;
        difference() {
            if (use_thinning) {
                if (cutting > 1) {
                    cuboid(
                        [$wall_thickness, l,  h], 
                        spin= 90
                    );
                } else {
                    thinning_wall(
                        h= h,
                        l= l,
                        strut= $wall_thickness,
                        thick= $wall_thickness,
                        wall= wall_thinning,
                        braces= use_brace,
                        spin=90
                    );
                }
            } else {
                cuboid(
                    [$wall_thickness, l,  h], 
                    spin= 90, 
                    teardrop= true, 
                    chamfer= chamfer_calculated,
                    edges= [LEFT, FWD+BOT, BACK+BOT, TOP+FRONT, TOP+BACK]
                );
            }

            if (cutting > 1) {
                up(($wall_thickness/2)+$epsilon)
                    right($epsilon)
                        cuboid(
                            [cutting, $wall_thickness+($epsilon*2),  h-$wall_thickness]
                        );
            }
        }
        
    }
        
    
    module back_wall()
        cube([dims.x, $wall_thickness, back_wall_height(dims) + $wall_thickness + top_add_h ], center= true) {
            position(BACK+TOP)
                _hook_repeat(floor((dims.x + ($wall_thickness/2))/$spacing))
                    children(0);
        }
    
    module bottom_wall()
        difference() {
            cuboid(
                [
                    dims.x + side_wall_thickness,
                    dims.y + $wall_thickness * 2,
                    $wall_thickness
                ],
                teardrop= true, 
                chamfer= chamfer_calculated,
                edges= concat(
                    [BOT+FWD], 
                    left_wall ? [ BOT+LEFT, LEFT+FWD]  : [],
                    right_wall ? [ BOT+RIGHT, RIGHT+FWD ] : []
                )
            );
            if (!is_undef($bottom_hole))
                cuboid(
                    $bottom_hole,
                    teardrop= true, 
                    chamfer= -chamfer_calculated
                );
        }
    side_wall_height = is_undef($side_wall_height) ? dims.z : $side_wall_height;
    sidewall_z_push = is_undef($side_wall_height) ? 0 : (dims.z-$side_wall_height)/2 + half_wall_thickness;

    frontwall_z_push = is_undef($front_wall_height) ? 0 : (dims.z-$front_wall_height)/2 + half_wall_thickness;
    
    module translated_side_wall()
        if (side_wall_height > 0) 
            left((dims.x + $wall_thickness)/2) 
                    side_wall();
    module translated_bottom() 
        down((dims.z + top_add_h) / 2) bottom_wall();

    down(half_wall_thickness-(top_add_h/2)) {
        down(sidewall_z_push) {
            if (left_wall) translated_side_wall();
            if (right_wall) mirror([1,0,0])
                 translated_side_wall();
        }


        translated_bottom();
        if (top_wall) mirror([0,0,1]) translated_bottom();

        down(frontwall_z_push)
            fwd((dims.y + $wall_thickness)/2) front_wall();
    
    
        up((back_wall_height(dims) - dims.z) / 2) 
            back((dims.y + $wall_thickness) / 2) 
                back_wall()
                    if ($children == 0) {
                        default_peg_set();
                    } else {
                        children();
                    }
    }
}

module _blank(dims, cube_tag= "preserve") {
    $x = dims.x;
    peg_position = BACK+TOP;
   
    tag(cube_tag)
        cube(dims, center= true) 
            if (dims.z < min_back_wall()) {
                position(TOP)
                    prismoid(
                        size1=[dims.x, dims.y], 
                        size2=[dims.x, $wall_thickness], 
                        h= min_back_wall()-dims.z,
                        shift= [undef,(dims.y-$wall_thickness)/2]
                    )
                        position(peg_position) _place_pegs() children();

            } else {
                echo("here", peg_position)
                position(peg_position) _place_pegs() children();
            }
}

module solid(dims) {
    _blank(dims)
        if ($children == 0) {
            default_peg_set();
        } else {
            children();
        }
}

module plate(dims) {
    _blank([dims.x, $wall_thickness, dims.z])
        if ($children == 0) {
            default_peg_set();
        } else {
            children();
        }
}
    
module virtual(dims) 
    let(hidden_tag= "hide_cube")
        hide(hidden_tag) 
            _blank(dims, cube_tag= hidden_tag)         
                if ($children == 0) {
                    default_peg_set();
                } else {
                    children();
                }

//'anchorify' is an awful sounding word.
module anchorize(
    //these are defaults for a m2 bolt and 1/4 pegboard
    screw_d= 3,
    screw_head_d= [7,6],
    screw_head_h= 2,
    shaft_reduce= 2,
    shaft_reduce_length= 3,
    split_w = 0.5,
    length_add = 5
) {
    $anchor_screw_d = screw_d;

    $anchor_screw_head_d = screw_head_d;
    $anchor_screw_head_h = screw_head_h;

    $anchor_shaft_reduce = shaft_reduce;
    $anchor_shaft_reduce_length = shaft_reduce_length;
    
    $anchor_split_w = split_w;
    $anchor_length_add = length_add;

    difference() {
        children(0);
        children(1);
    }
}

module anchor_screws(dims)
    let(hidden_tag= "hide_cube")
        hide(hidden_tag) 
            _blank(dims, cube_tag= hidden_tag) 
                anchor_screw_set(dims);

module slingify_box(side_height,front_height) {
    $side_wall_height = is_undef(side_height) ? undef : side_height;
    $front_wall_height = is_undef(front_height) ? undef : front_height;
    children();
}

module box_bottom_hole(dims) {
    $bottom_hole = [dims.x, dims.y, $wall_thickness + ($epsilon*2)];
    children();
}

module slideify_box() {
    $top_wall = true;
    $left_wall = false;
    $right_wall = false;
    children();
}

/* peg/hooks */
module hook() {
    arc_d= $board_thickness * $arc_d_mul;
    arc_r= arc_d/2;
    extension_length= $board_thickness * $extension_length_mul;

    right(arc_r)
        path_extrude2d(
            concat(
                [
                    [-arc_r, 0],
                    [-arc_r, extension_length]
                ],
                back(extension_length, arc(d= arc_d, angle=[180,90])),
                [
                    [0, extension_length + arc_r],
                    [$hook_end_length, extension_length + arc_r]
                ]
            ),
            caps=false
        )
            if ($children == 0) { flattened_peg_profile(); } else { children(0); }
}

module default_peg_set() 
    hook_pair() {
        hook();
        alignment_peg();
    };

module anchor_peg_set()
    hook_pair() {   
        anchor_peg();
        anchor_peg();
    }

module anchor_screw_set(dims)
    let(
        l = dims.y + ($epsilon*4)
    )
        translate([0, -dims.y/2, 0])
            hook_pair() {
                anchor_screw_hole(l);
                anchor_screw_hole(l);
            }

module anchor_screw_hole(l)
    let(
        d1 = is_list($anchor_screw_head_d) ? $anchor_screw_head_d[1] : $anchor_screw_d,
        d2 =  is_list($anchor_screw_head_d) ? $anchor_screw_head_d[0] : $anchor_screw_head_d,
        fn = 30
    )
        rotate([90, 0, 0]) {
            cylinder(d= $anchor_screw_d, h= l, $fn= fn, center= true);
            translate([0, 0, -($anchor_screw_head_h - l)/2])
                cylinder(d1= d1, d2= d2, h= $anchor_screw_head_h, $fn= fn, center= true);
        }   

module _place_pegs() 
    tag("hooks")
        _hook_repeat(floor($x/$spacing))
            fwd($epsilon)
                if ($children == 0) {
                    default_peg_set();
                } else {
                    children();
                }

module anchor_peg()
    difference() {
        path_extrude2d(
            [
                [0, 0],
                [0, $board_thickness + $anchor_length_add ]
            ]
        )
            if ($children == 0) {  
                anchor_peg_profile(); 
            } else { 
                children(0); 
            }
        union() {
            translate([0, -$epsilon, 0])
                rotate([-90, 0, 0])
                    cylinder(d= $anchor_screw_d, $fn=30, h= $board_thickness - $anchor_shaft_reduce  + ($epsilon*2));
            translate(
                [
                    0, 
                    $board_thickness - $anchor_shaft_reduce -  $epsilon, 
                    0
            ])
                rotate([-90, 0, 0])
                    cylinder(
                        d1= $anchor_screw_d,
                        d2= $anchor_screw_d - $anchor_shaft_reduce,
                        $fn=30,
                        h= $anchor_shaft_reduce_length + ($epsilon*2)
                    );
        }
    }
    

module alignment_peg()
    path_extrude2d(
        [
            [0, 0],
            [0, $alignment_peg_length]
        ]
    )
       if ($children == 0) { 
            flattened_peg_profile();
        } else { 
            children(0); 
        }
        

module hook_pair() {
    rotate([0,-90,0]) {
        children(0);
        left($spacing) children(1);
    }
}
module hook_single() rotate([0,-90,0]) children(0);

module _hook_repeat(n)
    translate([0,0,-$hole_d]) 
        if (n>0) {
            translate([-(n-1) * $spacing/2, 0, 0])
                for(i= [0:n-1])
                    right(i * $spacing)
                        children(0);
        } else {
            children(0);
        }
    

module flattened_peg_profile() 
     difference() {
        circle(d= $hole_d * $peg_hole_percentage, $fn= 20);
        left($hole_d * $peg_flatten_percentage)
            square($hole_d, center= true);
    }

module anchor_peg_profile() 
    difference() {
        circle(d= $hole_d * $peg_hole_percentage, $fn= 20);
        square([$hole_d, $anchor_split_w], center= true);
        left($hole_d * $peg_flatten_percentage)
            square($hole_d, center= true);
    }

function back_wall_height(s) = s.z < min_back_wall() ? min_back_wall() : s.z;
function min_back_wall(spacing, hole_d) = (is_undef($spacing) ? default_spacing : $spacing) + ((is_undef($hole_d) ? default_hole_d : $hole_d)*2);