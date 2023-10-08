include <../pegmixer.scad>

*pegmixer()
    box([30,20,40]);

*pegmixer(wall_thickness= 7)
    box([30,20,40]);

*pegmixer()
    box([300,20,40]);

*pegmixer()
    solid([30,20,40]);

*pegmixer()
    plate([30,20,40]);

*pegmixer()
    virtual([30,20,40]);

*pegmixer()
    slingify_box(
        side_height= 15,
        front_height= 10
    )
        box([30,20,40]);

*pegmixer()
    box_bottom_hole([20,10])
        box([30,20,40]);

pegmixer()
    bottomless()
        box(
            use_thinning= false, 
            [65, 18.3, 40]
        );