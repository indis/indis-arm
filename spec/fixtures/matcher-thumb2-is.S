.syntax unified
.thumb

//srsdb sp, 1
//srsdb sp!, 2

rfedb r2!
rfeia r3

// stm.w r1, {r2-r10}
// stm.w r2!, {r3-r5}

// ldm.w r3, {r0-r2}
// ldm.w r4!, {r5-r12}