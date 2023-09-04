include <../pegmixer.scad>


pegmixer()
    anchorize() {
        solid([30,6,40])
            anchor_peg_set();

        anchor_screws([30,6,40]);
    }


  
