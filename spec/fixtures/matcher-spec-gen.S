// generate with /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/ \
// usr/llvm-gcc-4.2/bin/arm-apple-darwin10-llvm-gcc-4.2 -mthumb -c test.S -o test.o && otool -tVVB test.o

.syntax unified
.thumb

lsls r0, r1, #5 // A8.8.94
//lsls r0, r1, #0 TODO: otool generates assembly, that is inconsistent with UAL
lsls r7, r2, #31

lsrs r0, r1, #5 // A8.8.96
//lsrs r0, r1, #0 TODO: this one produces lsls o_O
lsrs r7, r2, #31

asrs r0, r1, #5 // A8.8.16
//asrs r0, r1, #0 TODO: this one produces lsls o_O
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

eors r6, r0