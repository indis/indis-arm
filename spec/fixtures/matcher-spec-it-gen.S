.syntax unified
.thumb

beq L1
cbz r1, L1

it ne
movne r1, r2
b L1

bne L1
bgt L1

itt gt
movgt r1, r2
movgt r4, r6

ite vs
movvs r1, r2
movvc r7, r0

L1:
itete ls
movls r0, r1
movhi r2, r3
movls r4, r5
movhi r6, r7
mov r0, r7

bhi L1

////
itttt ne
lslne r0, r1, #5 // A8.8.94
asrne r0, r1, #5 // A8.8.16
addne r0, r5, r7 // A8.8.6
subne r0, r5, r7 // A8.8.223
itttt lo
addlo r1, r7, #7 // A8.8.4
sublo r3, r7, #0
movlo r1, #1 // A8.8.102
cmplo r5, #253 // A8.8.37
itt hi
addhi r5, #223 // A8.8.4
subhi r5, #100 // A8.8.221
