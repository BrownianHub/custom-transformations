// Created 2023-2024 by Dan Brown

include <custom_transformations.scad>;

/*
Further Examples of utilizing custom_transformations. 

Again, this work is released with CC0 into the public domain.
    https://creativecommons.org/publicdomain/zero/1.0/
*/


// Create cube without doing anything to it for reference
cube_size = 10;
cube([cube_size,cube_size,cube_size]);


// The following is all the same (except the full x-displacement):
x_displacement = 20;

color("white")
translate([x_displacement,0,0])
rotate([30,45,90])
cube([cube_size,cube_size,cube_size]);

color("white")
translate([2*x_displacement,0,0])
multmatrix(mrot(30,45,90))
cube([cube_size,cube_size,cube_size]);

color("white")
multmatrix( mtrans(3*x_displacement,0,0) * mrot(30,45,90) )
cube([cube_size,cube_size,cube_size]);


// We can now define a function that simply returns a final matrix
//      that can be reused for other objects with the same needed
//      transformation -- so, for the above, it could look like so:
function customTranslateAndRotate(x) = mtrans(x,0,0) * mrot(30,45,90);

// Call the function via multmatrix:
color("white")
multmatrix( customTranslateAndRotate(4*x_displacement) )
    cube([cube_size,cube_size,cube_size]);
    
// --------------------------------------------------------    
// Now, this is where it gets interesting...

/* Suppose we create the following module which aligns all children 
    in a line and rotates them using customTranslateAndRotate()

  - What if we want to pass-in an adddtional transformation to be applied
     to all its children on a whim?  
    -> Well, actually, we can -- like so:
*/
module align_children_line(dist, transform = mdefault() ) {
    
    loop_start = 0;
    loop_end = $children-1; 
    
    // Loop through children
    for ( i = [loop_start:1:loop_end] ) {  
      // original transformation for all children  
      translate_child = customTranslateAndRotate(dist*(i+1));  
      // plus the passed-in parameter transformation  
      final_transform = transform*translate_child;
        
      multmatrix(final_transform) {   // apply the final transform
            children(i);    // display the current child
      }   
    }
}

// Now we can recreate everything we did above, and more importantly,
//  even pass-in an additional transform to move the cubes up in the 
//  y-direction
y_displacement = 30;
trans_y = mtrans(0,y_displacement,0);

// Now we call the align children line method with the passed in
//   transform parameter, like so:
color("green")
align_children_line(dist=x_displacement, transform = trans_y) {
        // Child 1                    
        cube([cube_size,cube_size,cube_size]);        
        // Child 2       
        cube([cube_size,cube_size,cube_size]);                   
        // Child 3                              
        cube([cube_size,cube_size,cube_size]);                           
        // Child 4
        cube([cube_size,cube_size,cube_size]); 
}

// What if we wanted to also move them in the z-direction 
//  (after moving in the y-direction)?  Aka: stacking more transformations?
// We can do something like this:
z_displacement= 25;
trans_z = mtrans(0,0,z_displacement);
fin_transform = trans_z * trans_y;

color("blue")
align_children_line(dist=x_displacement, transform = fin_transform) { 
        cube([cube_size,cube_size,cube_size]);             
        cube([cube_size,cube_size,cube_size]);    
        cube([cube_size,cube_size,cube_size]);                           
        cube([cube_size,cube_size,cube_size]); 
}


// -------------------------------------------------------- 

// With passing in functions as parameters, this becomes even more powerful:

// similar align children module, but now, we have a function parameter
module align_children(dist=1, func = function(q) mdefault() )  {
    
    loop_start = 0;
    loop_end = $children-1; 
    
    // Loop through children
    for ( i = [loop_start:1:loop_end] ) {   
      // use the passed-in function parameter transformation  
      final_transform = func((i+1)*dist);  
      multmatrix(final_transform) {   // apply the final transform
            children(i);    // display the current child
      }   
    }
}

// transform here is the original translateAndRotate plus a move up in Z-axis
funcky_transform = function(i) trans_z * customTranslateAndRotate(i);
color("red")
align_children(dist=x_displacement, func = funcky_transform) { 
        cube([cube_size,cube_size,cube_size]);             
        cube([cube_size,cube_size,cube_size]);    
        cube([cube_size,cube_size,cube_size]);                           
        cube([cube_size,cube_size,cube_size]); 
}


// ** But check out what we can do as a result of this change: **

/* same transform module, but a different transformation for each child!
    - This time, our transform moves each child (i) in the z-axis based
      on dist*i, and then moves it in the y-axis by an exact amount 
      (the y-translation is not based on the child index (i) )
*/      
funky_transform_z = function(i) trans_y * mtrans(0,0,i);
color("magenta")
align_children(dist=z_displacement, func = funky_transform_z) { 
        cube([cube_size,cube_size,cube_size]);             
        cube([cube_size,cube_size,cube_size]);    
        cube([cube_size,cube_size,cube_size]);                           
        cube([cube_size,cube_size,cube_size]);   
}




// --------------------------------------------------------

// Now, some regular polygon cylinder prism examples:

cube_size_new = 4;      // create new cube size to not get confused

// create new polygon cylinder prism example module:
module polygon_example(example_sides) {
    color("grey")
    cylinder(h = 10, d = 2 * 5, $fn = example_sides);
    
    // add_object_to_side(side_number, sides, radius)
    add_object_to_side(side_number=2, sides=example_sides,
                                    radius=5) 
        translate([0,0,5])
        color("purple")
        cube(size=cube_size_new, center = true);
    
    // add_object_to_side_trans_z(side_number, sides,  
    //                              radius, translate_z)
    add_object_to_side_trans_z(1, 4, example_sides, 5) 
        color("lightgreen")
        cube(size=cube_size_new, center = true);
}

/*
--> Notice how no matter what shape, the first add_object_to_side()
        multimatrix function always puts the object in the center
        of a specific side (and always sticking out the same way)
*/
align_children(dist=-x_displacement, func = function(x) mtrans(x,0,0) ) { 
    polygon_example(6);
    polygon_example(5);
    polygon_example(4);
    polygon_example(3);   
}

// --------------------------------------------------------

// Now, let's combine some of these concepts:
// - Let's make something that looks like a lame spiral staircase 
//   --> (when number of children <= example_sides)

example_sides=10;       // number of sides for polygon prism
radius = 5;     // Radius of polygon prism

mtrans(-5*x_displacement,0,0) {     // move whole thing to new location
    
    // base regular polygon cylinder prism
    color("lightgrey")
    cylinder(h = 10, d = 2 * radius, $fn = example_sides);
    
    /* same transform module as before, but again, now a different 
       transform function is passed in... 
     - New transform is (adding an object to a side + increase z by some 
         i based value) 
    */
    color("purple")
    align_children(func = function(i) 
                            mtrans(0,0,i+1)*add_object_to_side(i,
                                                example_sides, radius)) 
    {
       cube(size=cube_size_new, center = true);
       cube(size=cube_size_new, center = true);
       cube(size=cube_size_new, center = true);
       cube(size=cube_size_new, center = true);
       cube(size=cube_size_new, center = true);
       cube(size=cube_size_new, center = true);   
       cube(size=cube_size_new, center = true);         
    }

}

// --------------------------------------------------------

// Now, imagine we have a set of transformations that we want children 
//  to cycle through. We can do that like so:

// Create array of functions (specifically transformation functions)
transformations = [ function(x) mtrans(x,0,0), 
                    function(y) mtrans(0,y,0),
                    function(z) mtrans(0,0,z),
                    function(x) mtrans(-x,0,0),
                    function(y) mtrans(0,-y,0),
                    function(z) mtrans(0,0,-z)
                  ];

                  
/* Transformation module that aligns children based on their index and 
    maps them to the same index that corresponds to a transform function.

 --> If we have done all transformations in the array, then loop through
     the transform again and for the remaining set of children, apply a 
     distance multiplier to separate them each time.
*/     
module transform_array_align_children(dist=1, transforms=[], 
                                        num_children=1 )  {
    loop_start = 0;
    loop_end = num_children-1; 
    transformation_array_length = len(transforms);     
    
    // Loop through children
    for ( i = [loop_start:1:loop_end] ) {  
        
      // Distance multiplier between sets of children.
      // -> Each time we cycle through all transformations,
      //    we increase the distance for the next set of children
      dist_multipler = ceil(i / transformation_array_length); 
  
      // Get specific function depending on child's index (i) 
      // -> modulus the size of the transform array to keep cycling through.
      func = transforms[i % transformation_array_length];  
        
      final_transform = func( dist_multipler*dist );  
      multmatrix(final_transform) {   // apply the final transform
            children();    // create and display the current new child
      }   
    }
}


// Now, let's put it all together:

r=5;    // Radius of sphere children
distance_between_children = 10;     // Distance between children
num_children = 13;      // Total number of children

// Move the entire thing to somewhere not already occupied by other 
//  examples above
mtrans(-6*x_displacement,2*y_displacement,0) {
    // Call the transform array align children module for a set of children
    //  --> In this case, all children are the same sphere with radius r.
    //  --> This creates a 3D cross made of spheres.
    color("orange")
    transform_array_align_children(dist=distance_between_children,
                                   transforms=transformations, 
                                   num_children=num_children) {
        sphere(r=r);
    }
}

// --------------------------------------------------------

// Now, what if want a different set of transformations?
// And, what if we want it for a different number of children (say >25)?
// And also, something other than spheres and cubes?

//  -> No problem! We can do that like so:

// Create new module  --> let's call it a snowflake
module snowflake(h=7,r=1, center=true,  $fn = 10) {
    
    cylinder(h=h,r=r,center=center, $fn =$fn);
    mrot(0,60,0)
    cylinder(h=h,r=r,center=center, $fn =$fn);
    mrot(0,-60,0)
    cylinder(h=h,r=r,center=center, $fn =$fn);
    mrot(60,0,0)
    cylinder(h=h,r=r,center=center, $fn =$fn);
    mrot(-60,0,0)
    cylinder(h=h,r=r,center=center, $fn =$fn);   
}

// *New Functions - Spirals (because I felt like it)
rot_angle = 10;     // rotation angle of each child after previous one
dist=30;   // max distance between children

// Spiral functions for translating
function spiral_translate(a, d=dist) = mtrans(d*sin(a), d*cos(a), 0);
function spiral_translate_neg(a, d=dist) = mtrans(-d*sin(a), -d*cos(a), 0);

// Spiral functions for rotating
function spiral_rotatex(a, rot_angle=rot_angle) = mrot(rot_angle*a,0,0);
function spiral_rotatey(a, rot_angle=rot_angle) = mrot(0,rot_angle*a,0);
function spiral_rotatez(a, rot_angle=rot_angle) = mrot(0,0,rot_angle*a);

// new transforms function array
new_transformations = [ 
                    function(a) spiral_rotatex(a)*spiral_translate_neg(a),
                    function(a) spiral_rotatey(a)*spiral_translate_neg(a),
                    function(a) spiral_rotatez(a)*spiral_translate_neg(a),
                    function(a) spiral_rotatex(a)*spiral_translate(a),
                    function(a) spiral_rotatey(a)*spiral_translate(a),
                    function(a) spiral_rotatez(a)*spiral_translate(a),
                      ];

// Again, move the entire thing to somewhere not already occupied by other 
//  examples above
mtrans(-2*x_displacement,3*y_displacement,0) {
    /* Call the transform array align children module for a set of children
      --> In this case, all children are the same snowflake module
      --> When children = ~600, this creates a sphere-like object made 
          from spirals of snowflakes
              --> death-star made of snowflake spirals?
    */
    color("lightblue")
    transform_array_align_children(transforms=new_transformations, 
                                   num_children=600) {
        snowflake();                              
    }
}

// --------------------------------------------------------

// ** How about a recursive module using custom-transformations?
//  Sure! How about the simple-tree example from the OpenScad docs?

//  We can re-create it, using what we learned before like so:

// Function for transforming leaves
function transform_leaf(size) = 
                        mscale(1,1,3)*mtrans(0,0,size/6)*mrot(90,0,0);

// Function for transforming branches
function transform_branch(angx, angz) = mrot(angx,0,angz);

/* Tree transform array
    --> maps to values of n (number of branches)
    --> n = 0, then use leaf transform function
    --> n=len(tree_transforms), then use branch transfrm function
    ---> Also maps colors as well (leaves are darkgreen, branches are brown)
*/
tree_transforms = [
[function(size, angx, angz) transform_leaf(size), "darkgreen" ],
[function(size, angx, angz) transform_branch(angx, angz) , "brown"]
];                   
     
/* Recreation of the simple-tree module:

    The way this works is we first get a min() index between the current 
    value of n (num of branches) and the size of the transforms array. 
    
    -- Such that we get an index which maps to the branches transform 
    which is at the end of the transforms array OR a different index
    corresponding to n, and then have that map to a different transform
    function. 
    
    - In the case that n=0, then it uses the transform leaf function instead.
    --> But we can also add another for n=1 (branches right before the
    leaves) or functions for n=2,3,4, etc.
    --> What's interesting is that, in this case, if we do add another
        transformation to the array, then this will cause it to "bleed-down"
        its transformation to the next branch call 
        (so leaves are affected by it as well)
*/
module simple_tree_new(size, dna, n, transforms=[]) {   
        // trunk
        transform_index = min(n+1 , len(transforms)-1);  // get color index
        color(transforms[transform_index][1])      // get color
        cylinder(r1=size/10, r2=size/12, h=size, $fn=24);
        
        // branches
        mtrans(0,0,size)
            for(bd = dna) {
                angx = bd[0];
                angz = bd[1];
                scal = bd[2];
                
                // Get associated transform matrix depending on value of n
                transform_index = min(n , len(transforms)-1);
                transform_func = transforms[transform_index][0];
                final_transform = transform_func(size, angx, angz);
                // Apply the transformation
                multmatrix( final_transform ) 
                    if (n > 0) {    // branches or other (recursively)
                        simple_tree_new(scal*size, dna, n-1, transforms);
                    }
                    else{   // leaves
                        color(transforms[transform_index][1])
                        cylinder(r=size/6,h=size/10);
                    }
            }
}


/* dna is a list of branching data bd of the tree:
          bd[0] - inclination of the branch
          bd[1] - Z rotation angle of the branch
          bd[2] - relative scale of the branch
*/
dna = [ [12,  80, 0.85], [55,    0, 0.6], 
        [62, 125, 0.6] , [57, -125, 0.6] ];


// Again, move the entire thing to somewhere not already occupied by other 
//  examples above
mtrans(3*x_displacement,3*y_displacement,0) 
     // Call the new simple tree module
     simple_tree_new(30, dna, 5, transforms=tree_transforms);

// --------------------------------------------------------

// Just for completeness, we can take the above new simple tree and 
//  add an  extra custom transform for its last branch (right before the
//  leaf), like so:

// Function for transforming "last" branch before leaves 
//  --> (scale them down)
function transform_last_branch(angx, angz) = 
                                mscale(0.5,0.5,0.75)*mrot(angx,0,angz);
                                    

// Create new tree_transform array with the added last branch function
//  --> new colors this time; reminds me of santa for some reason...
tree_transforms_new = [
[function(size, angx, angz) transform_leaf(size), "lightgreen" ],
[function(size, angx, angz) transform_last_branch(angx, angz), "red" ],
[function(size, angx, angz) transform_branch(angx, angz) , "white"]
];   

// Again, move entire thing to somewhere not already occupied by other 
//  examples above
mtrans(9*x_displacement,3*y_displacement,0) 
     // Call the new simple tree module
     simple_tree_new(30, dna, 5, transforms=tree_transforms_new);

// --------------------------------------------------------



// *** That should be enough examples for now. Have fun!