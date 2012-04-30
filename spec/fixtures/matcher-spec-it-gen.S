.syntax unified
.thumb

beq L1
cbz r1, L1

it ne
movne r1, r2

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
