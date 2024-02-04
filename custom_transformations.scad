// Created 2023-2024 by Dan Brown

/*
 - General purpose class for functions pertaining to
      object manipulation and/ or transformations
      
 - This is intended to be used as a sort-of small library or framework component in other designs. 
    As such, this work is released with CC0 into the public domain.
    https://creativecommons.org/publicdomain/zero/1.0/
    
 - Also allows the ability to create "custom transformations", which
      create a final matrix transform that can then be referenced
      again and again, and in various ways.

      This also allows us to have custom names for these 
      transformations as well.
      
      This is done by utilizing the multmatrix function that is called 
      ontop of a specific final matrix transform 
      (which is really just a matrix). 
      
      The finalized matrix itself is created by muiltiplying
      stacks of other more "basic" matrix transforms - sort of like 
      building block transformation matricies. 
      
      Already "basic" matrix functions are
      defined below - these essentially mimic already defined
      transformations such as rotate, translate, scale, but I also 
      added skew in as well. 
      These are what can be used to construct various new final 
      custom matrices. 

      This framework/ library is designed to compliment 
      the already existing ability of creating "transformation-modules",
      supplying the transformations, and calling children();  
      
      ** Combining these concepts is where things become interesting and
      can lead to powerful outcomes. **
      
      For example: 
      - * Passing in a custom transformation as a parameter
        to a module becomes possible now. 
        
        Since all you are actually doing is passing in a matrix 
        (and then invoking it via the multmatrix method). 
        OR better yet, you can define it as a custom function, 
        and then pass-in the function to a module, allowing the
        same module to produce various transforms for its children, based
        on the supplied/ passed-in transform function.
        
        You could not do this before, since you cannot pass modules as
        parameters into other modules.
        
      - * Mapping a child at a certain index to a specific transformation.
      
        Imagine that you wanted each child within your module to
        do something different. Maybe you want the first to be rotated,
        second one to be translated, third one to be scaled.
        
        You can do that now more easily, since you can map each
        child index to a matrix (a custom transform matrix) or even a
        function and then simply reference the child with that 
        associated transformation. 
                
      - * More specific examples can be found below as well as in:
            custom_transformations_examples.scad.            
     
*/


// Functions

// General function for calculating length of a side for any regular
//  polygon (if given height (aka: radius*2 in the case of a polygon
//  cylinder) and number of sides)
function side_length(height, sides) = 2*height*sin(180/sides);

// General function to get total degrees of any regular polygon
function total_degrees(sides) = 180*(sides-2); 

/*
Multimatrix Functions

--> where Multimatrix:

[Scale X]	[Shear X along Y]	[Shear X along Z]	[Translate X]
[Shear Y along X]	[Scale Y]	[Shear Y along Z]	[Translate Y]
[Shear Z along X]	[Shear Z along Y]	[Scale Z]	[Translate Z]

Example of usage:
        // --> same as:  rotate([30,45,90])
        multmatrix(mrot(30,45,90))
            obj();
            
---> The point of this is to be able to stack them in a final matrix    
        function, and then call:
            multmatrix( final_matrix_function(p1, p2, p3...) )
                obj();
*/


// default matrix (no transformation is done to an object; can be used
//      for default initilizations of parameters or other things)
function mdefault() = [ 
                         [1, 0, 0, 0],
                         [0, 1, 0, 0],
                         [0, 0, 1, 0],
                         [0, 0, 0, 1]
                      ];

// scale([scale_x, scale_y, scale_z])
function mscale(scale_x=1, scale_y=1, scale_z=1) = 
                  [ 
                     [scale_x,       0,       0, 0],
                     [      0, scale_y,       0, 0],
                     [      0,       0, scale_z, 0],
                     [      0,       0,       0, 1]
                  ];
                                

// rotate([0, 0, z])
function mrot_z(z_ang) = [   [cos(z_ang), -sin(z_ang), 0, 0],
                             [sin(z_ang),  cos(z_ang), 0, 0],
                             [         0,           0, 1, 0],
                             [         0,           0, 0, 1]
                         ];


// rotate([0, y, 0])
function mrot_y(y_ang)=[   [ cos(y_ang), 0,  sin(y_ang), 0],
                           [          0, 1,           0, 0],
                           [-sin(y_ang), 0,  cos(y_ang), 0],
                           [          0, 0,           0, 1]
                       ];
         
   
// rotate([x, 0, 0])
function mrot_x(x_ang) = [  [1,          0,           0, 0],
                            [0, cos(x_ang), -sin(x_ang), 0],
                            [0, sin(x_ang),  cos(x_ang), 0],
                            [0,          0,           0, 1]
                         ];   


// translate([dist_x, dist_y, dist_z]
function mtrans(dist_x=0, dist_y=0, dist_z=0) = [  [1, 0, 0, dist_x],
                                                   [0, 1, 0, dist_y],
                                                   [0, 0, 1, dist_z],
                                                   [0, 0, 0,  1]
                                                ];
       
// skew along a set of possible axis       
function mskew(xy = 0, xz = 0, yx = 0, yz = 0, zx = 0, zy = 0) =  
                [
                    [      1, tan(xy), tan(xz), 0],
                    [tan(yx),       1, tan(yz), 0],
                    [tan(zx), tan(zy),       1, 0],
                    [      0,       0,       0, 1]
                ];                                          
     
     
// multimatrix transformation reproduction of rotate([x,y,z])    
function mrot(x_ang=0, y_ang=0, z_ang=0) =
        let (mrot_x = mrot_x(x_ang))
        let (mrot_y = mrot_y(y_ang))
        let (mrot_z = mrot_z(z_ang))
        
        // Order matters for matrix multiplication, so it's "backwards"
        //   in this case (instead of mrot_x*mrot_y*mrot_z...)
        mrot_z*mrot_y*mrot_x;
  
  
// -------------------------------------------------------------

// General custom functions that can be created utilizing 
//  custom matrix transform functions:
  
/*  
 Using multimatrix transformations, we can reproduce the 
      transformations we would use to otherwise get the result of
      appending an object to the side of a polygon prism cylinder,
      given some radius, the side number, and the number of sides.
      --> This appends it to the center of the chosen side
 Example of usage:
      multmatrix(add_object_to_side(side_number, sides,radius))
              obj();
*/
function add_object_to_side(side_number, sides, radius) =
        
    let (side_to_add_obj = side_number % sides)
    let (x = (radius) * cos(360/sides * side_to_add_obj))
    let (y = (radius) * sin(360/sides * side_to_add_obj))
    
    let (m_translate = mtrans(x,y,0))
    let (m_rotateZ = mrot_z(360*(0.25 + (side_number+0.5)/sides)) )
    let (m_translate_center = mtrans(side_length(radius, sides)/2,0,0))
    
    let(final_matrix = m_translate*m_rotateZ*m_translate_center)
    
    final_matrix; 
  
  
//    
// Similar to above, except more general and also allows to
//      translate on the z-axis via the translate_z parameter
function add_object_to_side_trans_z(side_number, sides, radius,                                 translate_z=0) =
        
    let (side_to_add_obj = side_number % sides)
    let (x = (radius) * cos(360/sides * side_to_add_obj))
    let (y = (radius) * sin(360/sides * side_to_add_obj))
    
    let (m_translate = mtrans(x,y,translate_z))
    let (m_rotateZ = mrot_z(side_number*360/sides))
    
    let(final_matrix = m_translate*m_rotateZ)
    
    final_matrix;     
     
// -----------------------------------------------------------------

// Modules

// Custom "transformation modules" using custom transformations:

// add object to side
module add_object_to_side(side_number, sides, radius) {
    multmatrix(add_object_to_side(side_number, sides,radius))
        children();
}


// add object to side (more general + z-axis translation)
module add_object_to_side_trans_z(side_number, sides, radius, z=0) {
    multmatrix(add_object_to_side_trans_z(side_number, sides, radius, z))
        children();
}


// rotate([x,y,z]) without [] brackets
module mrot(x=0,y=0,z=0) {
     multmatrix(mrot(x,y,z)) 
        children();        
}


// translate([x,y,z]) without [] brackets
module mtrans(x=0,y=0,z=0) {
    multmatrix(mtrans(x,y,z)) 
        children();   
}


// Skew object along a set of possible axis
    /*  xy: skew towards X along Y axis.
        xz: skew towards X along Z axis.
        yx: skew towards Y along X axis.
        yz: skew towards Y along Z axis.
        zx: skew towards Z along X axis.
        zy: skew towards Z along Y axis.
    */
module mskew(xy = 0, xz = 0, yx = 0, yz = 0, zx = 0, zy = 0) {
	multmatrix(mskew(xy, xz, yx, yz, zx, zy) )
        children();
}



// Other useful transformation-modules:

// Rotate around a specific point in space --> 
//      ie:  rotate_around_pt(45,0, 0, [0,0,0]) { obj(); }
module rotate_around_pt(z, y, x, pt) {
    translate(pt)
        rotate([x, y, z]) 
            translate(-pt)
                children();   
}


// Rotate around a specific point in space (*custom transform version) --> 
//      ie:  mrotate_around_pt(45,0, 0, [0,0,0]) { obj(); }
module mrotate_around_pt(z, y, x, pt=[0,0,0]) {
    translation = mtrans(pt[0], pt[1], pt[2]);
    multmatrix(translation*mrot(x,y,z)*(-translation))
        children();   
}

