// generate with /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/ \
// usr/llvm-gcc-4.2/bin/arm-apple-darwin10-llvm-gcc-4.2 -mthumb -c test.S -o test.o && otool -tVVB test.o

.syntax unified
.thumb

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

////

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

////
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

////

//ldr r3, L0 // 4b01 ldr r3, [pc, #4]	(0x8c)
//mov pc, lr
//mov r1, r2
//L0:
//.long 256

////

//b L0 // e7fa b.n 0x7e
