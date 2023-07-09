include <../pegmixer.scad>

/*
 * Example that illustrates:
 *  - a very simple script
 *  - cutting the front of a box to accomidate protrusions in the front of the object
 */

pegmixer() 
    box([72,37,50], cutting= 45);