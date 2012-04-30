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
itttt hi
addhi r5, #223 // A8.8.4
subhi r5, #100 // A8.8.221

andhi r3, r5
eorhi r6, r0
itttt gt
lslgt r4, r6
asrgt r1, r5
adcgt r4, r7
sbcgt r0, r6
itttt cc
rorcc r7, r3
tstcc r4, r1
cmpcc r3, r0
cmncc r3, r2
itttt vs
orrvs r4, r2
bicvs r1, r5
mvnvs r5, r1

addvs r1, r2, r3
itttt eq
addeq r10, r3
addeq r8, sp
cmpeq r11, r15
cmpeq r9, r10
ittt cs
movcs r1, r2
movcs r3, sp
movcs pc, lr

itttt cc
strcc r0, [r1, r2]
strhcc r3, [r4, r5]
strbcc r6, [r7, r0]
ldrsbcc r1, [r2, r3]
itttt ne
ldrne r4, [r5, r6]
ldrhne r7, [r0, r1]
ldrbne r2, [r3, r4]
ldrshne r5, [r6, r7]
itttt lt
strlt r0, [r1, #124]
ldrlt r2, [r3, #60]
strblt r4, [r5, #24]
ldrblt r6, [r7, #30]
itttt gt
strhgt r0, [r1, #60]
ldrhgt r2, [r3, #32]
strgt r4, [sp, #1020]
ldrgt r5, [sp, #220]

itttt cc
sxthcc r3, r4
sxtbcc r5, r6
uxthcc r7, r0
uxtbcc r1, r2
itttt eq
pusheq {r1, r2, r3, lr}
pusheq {r3-r7}
reveq r1, r3
rev16eq r4, r5
itttt cs
revshcs r7, r6
popcs {r1}
nopcs
popcs {r5-r7,pc}
itttt hi
yieldhi
wfehi
wfihi
sevhi