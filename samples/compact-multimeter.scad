include <../pegmixer.scad>

h= 54;

pegmixer() 
    slingify_box(
        side_height= 0,
        front_height= h
    )
        box(
            use_brace= false,
            use_thinning= false,
            [62, 23,h]
        );
