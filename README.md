# custom-transformations

Created 2023-2024 by Dan Brown

--------------------------------------
A general purpose OpenScad framework for functions pertaining to object manipulation and/ or transformations.
      
 - This is intended to be used as a sort-of small library or framework component in other designs.
    - As such, this work is released with CC0 into the public domain.
      https://creativecommons.org/publicdomain/zero/1.0/

 - The purpose of this is to expand upon the posibilities of what can be done for transformations of objects 
   as well as to do so in potentially shorter amounts of code.
    - It is designed to compliment the already existing ability of creating 
      "transformation-modules", supplying the transformations, and calling `children();`

--------------------------------------      

 - To give an idea as to what this is talking about, have a look at the following code sample (this is also in the examples.scad file):
 ```
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
```

  - All the above is doing is aligning children in some way. 
    - But, look at that second parameter -- it's a function.
      - But, not just any function -- it's a function parameter that returns a transformation matrix!
      - That's right. We can supply any matrix transformation to all those children objects.

  So, if we had something like this:
```
funcky_transform = function(i) customTranslateHorizontally(i);
color("red")
align_children(dist=x_displacement, func = funcky_transform) { 
        cube(size=cube_size);             
        cube(size=cube_size);    
        cube(size=cube_size);                            
        cube(size=cube_size); ; 
}
```
Then, if we wanted to do something else to all those cubes, like stack them vertically instead of horizontally, all 
we would have to do is supply it with a different function that would return a different transformation matrix! 
- Like so:
```
funcky_transform = function(i) customTranslateVertically(i);
color("red")
align_children(dist=x_displacement, func = funcky_transform) { 
        cube(size=cube_size);             
        cube(size=cube_size);    
        cube(size=cube_size);                            
        cube(size=cube_size); ; 
}
```

--------------------------------------
Interesting idea. 
.... Except that would mean making a function that would return a transformation matrix for each custom transform, right?

- Wrong! That's where this framework comes in!
  - Well, sort of. 
  - Instead of doing that by hand and defining a specific matrix for each transformation, you can simply 
    call functions that build it through matrix multiplications.

    - So, if you wanted a transformation that would translate by x and then rotate by a certain amount, you can define it like so:
    ```
    function customTranslateAndRotate(x) = mtrans(x,0,0) * mrot(30,45,90);
    ```
    - Both `mtrans(x,y,z)` and `mrot(x,y,z)` are actually already defined within the framework. 
    - Both of them are functions that return a transformation matrix (and are defined as such).  
  
 - The way this works is by allowing users to create/ define a final matrix transform that can then be referenced
   in various ways. 
      - The finalized matrix itself is created by muiltiplying stacks of other more 
        "basic" matrix transforms - sort of like building block transformation matricies. 
      
      - Already "basic" matrix functions are defined within the framework already - these essentially mimic 
        already defined transformations such as `rotate`, `translate`, `scale`, but I also added `skew` in as well. 
        - These are what can be used to construct various new final custom matrices.

      - Once a final custom matrix is defined, it is then used in combination with a module that calls the
        `multmatrix` function to actually perform the transformation on an object or child (or set of children).

  --------------------------------------    
 # Utilizing this framework can lead to powerful outcomes. 
 --------------------------------------
      
  For example: 
  - Passing in a custom transformation as a parameter to a module becomes possible now. 

      - Since all you are actually doing is passing in a matrix 
        (and then invoking it via the multmatrix method). 
        *OR* better yet, you can define it as a custom function, 
        and then pass-in the function to a module, allowing the
        same module to produce various transformations for its children, based
        on the supplied/ passed-in transform function.
    
      - You could not do this before, since you cannot pass modules as
        parameters into other modules.

    
  - Mapping a child at a certain index to a specific transformation.

    - Imagine that you wanted each child within your module to
      do something different. Maybe you want the first to be rotated,
      second one to be translated, third one to be scaled.
    
      - You can do that now more easily, since you can map each
        child index to a matrix (a custom transform matrix) or even a
        function and then simply reference the child with that 
        associated transformation. 

--------------------------------------  
            
- More specific examples can be found in:
    - `custom_transformations_examples.scad`            
     
