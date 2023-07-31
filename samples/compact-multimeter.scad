include <../pegmixer.scad>

h= 54; /* height of the front and back wall */
w= 62; /* width of the inner portion (does not include wall width on left and right) */
d= 23; /* depth of the inside of the sling */


pegmixer() 
    slingify_box(
        side_height= 0,
        front_height= h
    )
        box(
            use_brace= false,
            use_thinning= false,
            [w, d, h]
        );
