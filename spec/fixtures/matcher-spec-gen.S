// generate with /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/ \
// usr/llvm-gcc-4.2/bin/arm-apple-darwin10-llvm-gcc-4.2 -mthumb -c test.S -o test.o && otool -tVVB test.o

.syntax unified
.thumb

//// Shift (immediate), add, subtract, move, and compare on page A6-222

lsls r0, r1, #5 // A8.8.94
//lsls r0, r3, #0 // outputs 0018 lsls r0, r3, #0, while mov_reg is expected
lsls r7, r2, #31

lsrs r0, r1, #5 // A8.8.96
//lsrs r0, r1, #0 // outputs 0008 lsls r0, r1, #0
lsrs r7, r2, #31

asrs r0, r1, #5 // A8.8.16
//asrs r0, r1, #0 // outputs 0008 lsls r0, r1, #0
asrs r7, r2, #31

adds r0, r5, r7 // A8.8.6

subs r0, r5, r7 // A8.8.223

adds r1, r7, #7 // A8.8.4
adds r4, r2, #0

subs r7, r7, #7 // A8.8.221
subs r3, r7, #0

movs r1, #1 // A8.8.102
movs r6, #128
movs r3, #255

cmp r5, #253 // A8.8.37
cmp r5, #14

adds r5, #223 // A8.8.4
adds r5, #13

subs r5, #100 // A8.8.221
subs r5, #12

//// Data-processing on page A6-223

ands r3, r5
ands r2, r7

eors r6, r0
eors r1, r4

lsls r4, r6
lsrs r3, r7

asrs r0, r2
asrs r1, r5

adcs r4, r7
adcs r2, r4

sbcs r0, r6
sbcs r1, r2

rors r7, r3
rors r2, r6

tst r4, r1
tst r3, r0

//rsbs r6, r4, #0 // outputs pre-ual 4266 negs r6, r4
//rsbs r1, r7, #0

cmp r3, r0
cmp r6, r5

cmn r3, r2
cmn r6, r1

orrs r4, r2
orrs r1, r0

//muls r3, r6, r3 // outputs 4373 muls r3, r6
//muls r2, r0, r2

bics r1, r5
bics r3, r7

mvns r5, r1
mvns r6, r2

//// Special data instructions and branch and exchange on page A6-224

adds r1, r2, r3
adds r4, r5, r6

add r9, r10
add r9, r11
add r9, r12
add r9, r13
add r9, r14
add r9, r15
add r10, r3
add r8, sp

cmp r11, r15
cmp r9, r10

movs r1, r2
movs r7, r6

mov pc, lr
mov r3, sp
L0:
bx lr
bx r3

blx lr
blx r5

//// Load from Literal Pool, see LDR (literal) on page A8-408

//ldr r3, L0 // 4b01 ldr r3, [pc, #4]	(0x8c)
//mov pc, lr
//mov r1, r2
//L0:
//.long 256

//// Load/store single data item on page A6-225

str r0, [r1, r2]
strh r3, [r4, r5]
strb r6, [r7, r0]
ldrsb r1, [r2, r3]
ldr r4, [r5, r6]
ldrh r7, [r0, r1]
ldrb r2, [r3, r4]
ldrsh r5, [r6, r7]

str r0, [r1, #124]
ldr r2, [r3, #60]
strb r4, [r5, #24]
ldrb r6, [r7, #30]
strh r0, [r1, #60]
ldrh r2, [r3, #32]
str r4, [sp, #1020]
ldr r5, [sp, #220]

//// Generate PC-relative address, see ADR on page A8-320

// adr r0, L0 // outputs f2af002a subw r0, pc, #42

//// Generate SP-relative address, see ADD (SP plus immediate) on page A8-314

add r0, sp, 1020

//// Miscellaneous 16-bit instructions on page A6-226
//add sp, sp, 508 // outputs b07f add sp, #508
//sub sp, sp, 100
//cbz r1, L1 // integration test, outputs b109 cbz r1, 0xb2
//cbnz r2, L1
sxth r3, r4
sxtb r5, r6
uxth r7, r0
uxtb r1, r2
push {r1, r2, r3, lr}
push {r3-r7}
setend be
setend le

//// Store multiple registers, see STM (STMIA, STMEA) on page A8-662



//// Load multiple registers, see LDM/LDMIA/LDMFD (Thumb) on page A8-394

//// Conditional branch, and Supervisor Call on page A6-227

//b L0 // e7fa b.n 0x7e

// udf 3
// udf 250

svc 215
svc 12

//// Unconditional Branch, see B on page A8-332

