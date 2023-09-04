include <../pegmixer.scad>



pegmixer(
    nth_skip = 2
)
    anchorize() {
        solid([77,6,40])
            anchor_peg_set();

        anchor_screws([77,6,40]);
    }


  
