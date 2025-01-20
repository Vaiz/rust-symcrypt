.set SymCryptModulusNdigitsOffsetAmd64, 4;
.set SymCryptModulusInv64OffsetAmd64, 24;
.set SymCryptModulusValueOffsetAmd64, 128;
.set SymCryptNegDivisorSingleDigitOffsetAmd64, 256;
.set SymCryptModulusNdigitsOffsetX86, 4;
.set SymCryptModulusInv64OffsetX86, 24;
.set SymCryptModulusValueOffsetX86, 96;
.set SymCryptModulusNdigitsOffsetArm64, 4;
.set SymCryptModulusInv64OffsetArm64, 24;
.set SymCryptModulusValueOffsetArm64, 128;
.set SymCryptModulusNdigitsOffsetArm, 4;
.set SymCryptModulusInv64OffsetArm, 24;
.set SymCryptModulusValueOffsetArm, 96;
SymCryptFdefRawAddAsm: .global SymCryptFdefRawAddAsm
.type SymCryptFdefRawAddAsm, %function
    ldp x4, x6, [x0]
    ldp x5, x7, [x1]
    adds x4, x4, x5
    adcs x6, x6, x7
    stp x4, x6, [x2]
    ldp x4, x6, [x0, #16]
    sub x3, x3, #1
    ldp x5, x7, [x1, #16]
    adcs x4, x4, x5
    adcs x6, x6, x7
    stp x4, x6, [x2, #16]
    cbz x3, SymCryptFdefRawAddAsmEnd
SymCryptFdefRawAddAsmLoop:
    ldp x4, x6, [x0, #32]!
    ldp x5, x7, [x1, #32]!
    adcs x4, x4, x5
    adcs x6, x6, x7
    stp x4, x6, [x2, #32]!
    ldp x4, x6, [x0, #16]
    sub x3, x3, #1
    ldp x5, x7, [x1, #16]
    adcs x4, x4, x5
    adcs x6, x6, x7
    stp x4, x6, [x2, #16]
    cbnz x3, SymCryptFdefRawAddAsmLoop
    .align 4
SymCryptFdefRawAddAsmEnd:
    cset x0, cs
    ret
SymCryptFdefRawSubAsm: .global SymCryptFdefRawSubAsm
.type SymCryptFdefRawSubAsm, %function
    ldp x4, x6, [x0]
    ldp x5, x7, [x1]
    subs x4, x4, x5
    sbcs x6, x6, x7
    stp x4, x6, [x2]
    ldp x4, x6, [x0, #16]
    sub x3, x3, #1
    ldp x5, x7, [x1, #16]
    sbcs x4, x4, x5
    sbcs x6, x6, x7
    stp x4, x6, [x2, #16]
    cbz x3, SymCryptFdefRawSubAsmEnd
SymCryptFdefRawSubAsmLoop:
    ldp x4, x6, [x0, #32]!
    ldp x5, x7, [x1, #32]!
    sbcs x4, x4, x5
    sbcs x6, x6, x7
    stp x4, x6, [x2, #32]!
    ldp x4, x6, [x0, #16]
    sub x3, x3, #1
    ldp x5, x7, [x1, #16]
    sbcs x4, x4, x5
    sbcs x6, x6, x7
    stp x4, x6, [x2, #16]
    cbnz x3, SymCryptFdefRawSubAsmLoop
    .align 4
SymCryptFdefRawSubAsmEnd:
    cset x0, cc
    ret
SymCryptFdefMaskedCopyAsm: .global SymCryptFdefMaskedCopyAsm
.type SymCryptFdefMaskedCopyAsm, %function
    dup v0.4s, w3
SymCryptFdefMaskedCopyAsmLoop:
    ldp q1, q3, [x0], #32
    ldp q2, q4, [x1]
    bit v2.16b, v1.16b, v0.16b
    bit v4.16b, v3.16b, v0.16b
    stp q2, q4, [x1], #32
    sub x2, x2, #1
    cbnz x2, SymCryptFdefMaskedCopyAsmLoop
    ret
SymCryptFdefRawMulAsm: .global SymCryptFdefRawMulAsm
.type SymCryptFdefRawMulAsm, %function
    lsl x1, x1, #2
    sub x2, x2, #32
    sub x4, x4, #32
    mov x5, x4
    mov x13, x2
    mov x14, x3
    ands x12, x12, xzr
    ldr x6, [x0]
SymCryptFdefRawMulAsmLoopInner1:
    sub x3, x3, #1
    ldp x7, x8, [x2, #32]!
    mul x11, x6, x7
    adcs x11, x11, x12
    umulh x12, x6, x7
    mul x15, x6, x8
    adcs x15, x15, x12
    umulh x12, x6, x8
    stp x11, x15, [x4, #32]!
    ldp x7, x8, [x2, #16]
    mul x11, x6, x7
    adcs x11, x11, x12
    umulh x12, x6, x7
    mul x15, x6, x8
    adcs x15, x15, x12
    umulh x12, x6, x8
    stp x11, x15, [x4, #16]
    cbnz x3, SymCryptFdefRawMulAsmLoopInner1
    adc x12, x12, xzr
    str x12, [x4, #32]
    sub x1, x1, #1
    add x0, x0, #8
    add x5, x5, #8
SymCryptFdefRawMulAsmLoopOuter:
    mov x3, x14
    mov x2, x13
    mov x4, x5
    ands x12, x12, xzr
    ldr x6, [x0]
SymCryptFdefRawMulAsmLoopInner:
    sub x3, x3, #1
    ldp x7, x8, [x2, #32]!
    ldp x9, x10, [x4, #32]!
    adcs x9, x9, x12
    umulh x11, x6, x7
    adcs x10, x11, x10
    umulh x12, x6, x8
    adc x12, x12, xzr
    mul x11, x6, x7
    adds x9, x9, x11
    mul x11, x6, x8
    adcs x10, x10, x11
    stp x9, x10, [x4]
    ldp x7, x8, [x2, #16]
    ldp x9, x10, [x4, #16]
    adcs x9, x9, x12
    umulh x11, x6, x7
    adcs x10, x11, x10
    umulh x12, x6, x8
    adc x12, x12, xzr
    mul x11, x6, x7
    adds x9, x9, x11
    mul x11, x6, x8
    adcs x10, x10, x11
    stp x9, x10, [x4, #16]
    cbnz x3, SymCryptFdefRawMulAsmLoopInner
    adc x12, x12, xzr
    str x12, [x4, #32]
    subs x1, x1, #1
    add x0, x0, #8
    add x5, x5, #8
    bne SymCryptFdefRawMulAsmLoopOuter
    ret
.macro SQR_SINGLEADD_64 index, src_reg, dst_reg, mul_word, src_carry, dst_carry, scratch0, scratch1
    ldr \scratch0, [\src_reg, #8*\index]
    mul \scratch1, \mul_word, \scratch0
    adds \scratch1, \scratch1, \src_carry
    umulh \dst_carry, \mul_word, \scratch0
    adc \dst_carry, \dst_carry, xzr
    str \scratch1, [\dst_reg, #8*\index]
.endm
.macro SQR_DOUBLEADD_64 index, src_reg, dst_reg, mul_word, src_carry, dst_carry, scratch0, scratch1, scratch2
    ldr \scratch0, [\src_reg, #8*\index]
    ldr \scratch2, [\dst_reg, #8*\index]
    mul \scratch1, \mul_word, \scratch0
    adds \scratch1, \scratch1, \src_carry
    umulh \dst_carry, \mul_word, \scratch0
    adc \dst_carry, \dst_carry, xzr
    adds \scratch1, \scratch1, \scratch2
    adc \dst_carry, \dst_carry, xzr
    str \scratch1, [\dst_reg, #8*\index]
.endm
.macro SQR_DIAGONAL_PROP index, src_reg, dst_reg, squarelo, squarehi, scratch0, scratch1
    ldr \squarehi, [\src_reg, #8*\index]
    mul \squarelo, \squarehi, \squarehi
    umulh \squarehi, \squarehi, \squarehi
    ldp \scratch0, \scratch1, [\dst_reg, #16*\index]
    adcs \squarelo, \squarelo, \scratch0
    adcs \squarehi, \squarehi, \scratch1
    stp \squarelo, \squarehi, [\dst_reg, #16*\index]
.endm
SymCryptFdefRawSquareAsm: .global SymCryptFdefRawSquareAsm
.type SymCryptFdefRawSquareAsm, %function
    mov x3, x1
    lsl x1, x1, #2
    mov x4, x2
    mov x5, x2
    mov x16, x2
    mov x13, x0
    mov x2, x0
    mov x14, x3
    mov x15, x3
    ands x12, x12, xzr
    ldr x6, [x0]
    str x12, [x4]
    b SymCryptFdefRawSquareAsmInnerLoopInit_Word1
SymCryptFdefRawSquareAsmInnerLoopInit_Word0:
    SQR_SINGLEADD_64 0, x2, x4, x6, x12, x12, x7, x8
SymCryptFdefRawSquareAsmInnerLoopInit_Word1:
    SQR_SINGLEADD_64 1, x2, x4, x6, x12, x12, x7, x8
    SQR_SINGLEADD_64 2, x2, x4, x6, x12, x12, x7, x8
    SQR_SINGLEADD_64 3, x2, x4, x6, x12, x12, x7, x8
    sub x3, x3, #1
    add x2, x2, #32
    add x4, x4, #32
    cbnz x3, SymCryptFdefRawSquareAsmInnerLoopInit_Word0
    str x12, [x4]
    sub x1, x1, #2
    mov x8, #1
SymCryptFdefRawSquareAsmOuterLoop:
    add x5, x5, #8
    mov x3, x14
    mov x2, x0
    mov x4, x5
    ands x12, x12, xzr
    ldr x6, [x0, x8, LSL #3]
    add x8, x8, #1
    cmp x8, #1
    beq SymCryptFdefRawSquareAsmInnerLoop_Word1
    cmp x8, #2
    beq SymCryptFdefRawSquareAsmInnerLoop_Word2
    cmp x8, #3
    beq SymCryptFdefRawSquareAsmInnerLoop_Word3
    mov x8, xzr
    add x0, x0, #32
    add x5, x5, #32
    mov x2, x0
    mov x4, x5
    sub x14, x14, #1
    mov x3, x14
SymCryptFdefRawSquareAsmInnerLoop_Word0:
    SQR_DOUBLEADD_64 0, x2, x4, x6, x12, x12, x7, x9, x10
SymCryptFdefRawSquareAsmInnerLoop_Word1:
    SQR_DOUBLEADD_64 1, x2, x4, x6, x12, x12, x7, x9, x10
SymCryptFdefRawSquareAsmInnerLoop_Word2:
    SQR_DOUBLEADD_64 2, x2, x4, x6, x12, x12, x7, x9, x10
SymCryptFdefRawSquareAsmInnerLoop_Word3:
    SQR_DOUBLEADD_64 3, x2, x4, x6, x12, x12, x7, x9, x10
    sub x3, x3, #1
    add x2, x2, #32
    add x4, x4, #32
    cbnz x3, SymCryptFdefRawSquareAsmInnerLoop_Word0
    str x12, [x4]
    sub x1, x1, #1
    cbnz x1, SymCryptFdefRawSquareAsmOuterLoop
    ands x12, x12, xzr
    str x12, [x5, #40]
    mov x3, x15
    lsl x3, x3, #1
    mov x4, x16
    ands x7, x7, xzr
SymCryptFdefRawSquareAsmSecondPass:
    sub x3, x3, #1
    ldp x7, x8, [x4]
    adcs x7, x7, x7
    adcs x8, x8, x8
    stp x7, x8, [x4], #16
    ldp x9, x10, [x4]
    adcs x9, x9, x9
    adcs x10, x10, x10
    stp x9, x10, [x4], #16
    cbnz x3, SymCryptFdefRawSquareAsmSecondPass
    ands x7, x7, xzr
    mov x0, x13
    mov x4, x16
    mov x3, x15
SymCryptFdefRawSquareAsmThirdPass:
    SQR_DIAGONAL_PROP 0, x0, x4, x6, x7, x8, x9
    SQR_DIAGONAL_PROP 1, x0, x4, x6, x7, x8, x9
    SQR_DIAGONAL_PROP 2, x0, x4, x6, x7, x8, x9
    SQR_DIAGONAL_PROP 3, x0, x4, x6, x7, x8, x9
    sub x3, x3, #1
    add x0, x0, #32
    add x4, x4, #64
    cbnz x3, SymCryptFdefRawSquareAsmThirdPass
    ret
SymCryptFdefModAdd256Asm: .global SymCryptFdefModAdd256Asm
.type SymCryptFdefModAdd256Asm, %function
    add x0, x0, #SymCryptModulusValueOffsetArm64
    ldp x4, x5, [x1]
    ldp x8, x9, [x2]
    adds x4, x4, x8
    adcs x5, x5, x9
    ldp x6, x7, [x1, #16]
    ldp x8, x9, [x2, #16]
    adcs x6, x6, x8
    adcs x7, x7, x9
    cset x1, cs
    ldp x2, x8, [x0]
    subs x2, x4, x2
    sbcs x8, x5, x8
    ldp x9, x0, [x0, #16]
    sbcs x9, x6, x9
    sbcs x0, x7, x0
    sbcs x1, x1, XZR
    csel x4, x4, x2, cc
    csel x5, x5, x8, cc
    stp x4, x5, [x3]
    csel x6, x6, x9, cc
    csel x7, x7, x0, cc
    stp x6, x7, [x3, #16]
    ret
SymCryptFdefModSub256Asm: .global SymCryptFdefModSub256Asm
.type SymCryptFdefModSub256Asm, %function
    add x0, x0, #SymCryptModulusValueOffsetArm64
    ldp x4, x5, [x1]
    ldp x8, x9, [x2]
    subs x4, x4, x8
    sbcs x5, x5, x9
    ldp x6, x7, [x1, #16]
    ldp x8, x9, [x2, #16]
    sbcs x6, x6, x8
    sbcs x7, x7, x9
    ldp x1, x2, [x0]
    csel x1, x1, XZR, cc
    csel x2, x2, XZR, cc
    ldp x8, x9, [x0, #16]
    csel x8, x8, XZR, cc
    csel x9, x9, XZR, cc
    adds x4, x4, x1
    adcs x5, x5, x2
    stp x4, x5, [x3]
    adcs x6, x6, x8
    adc x7, x7, x9
    stp x6, x7, [x3, #16]
    ret
.macro MUL_AND_MONTGOMERY_REDUCE14_INTERLEAVE T0, T1, Ai, pB, pM, K, Inv64, R0, R1, R2, R3, R4, R5
    ldr \T0, [\pB]
    mul \T1, \Ai, \T0
    adds \R1, \R1, \T1
    umulh \T0, \Ai, \T0
    adcs \R2, \R2, \T0
    ldr \T0, [\pB, #16]
    mul \T1, \Ai, \T0
    adcs \R3, \R3, \T1
    umulh \T0, \Ai, \T0
    adcs \R4, \R4, \T0
    adc \R5, \R5, XZR
    ldr \T0, [\pB, #8]
    mul \T1, \Ai, \T0
    adds \R2, \R2, \T1
    umulh \T0, \Ai, \T0
    adcs \R3, \R3, \T0
    ldr \T0, [\pB, #24]
    mul \T1, \Ai, \T0
    adcs \R4, \R4, \T1
    umulh \Ai, \Ai, \T0
    adc \Ai, \Ai, XZR
    ldr \T0, [\pM]
    mul \T1, \K, \T0
    adds \R0, \R0, \T1
    umulh \T0, \K, \T0
    adcs \R1, \R1, \T0
    ldr \T0, [\pM, #16]
    mul \T1, \K, \T0
    adcs \R2, \R2, \T1
    umulh \T0, \K, \T0
    adcs \R3, \R3, \T0
    adcs \R4, \R4, XZR
    adc \R5, \R5, XZR
    ldr \T0, [\pM, #8]
    mul \T1, \K, \T0
    adds \R1, \R1, \T1
    umulh \T0, \K, \T0
    adcs \R2, \R2, \T0
    ldr \T0, [\pM, #24]
    mul \T1, \K, \T0
    adcs \R3, \R3, \T1
    umulh \T0, \K, \T0
    adcs \R4, \R4, \T0
    mul \K, \R1, \Inv64
    adcs \R5, \R5, \Ai
    cset \R0, cs
.endm
SymCryptFdefModMulMontgomery256Asm: .global SymCryptFdefModMulMontgomery256Asm
.type SymCryptFdefModMulMontgomery256Asm, %function
SymCryptFdefModMulMontgomery256AsmInternal: .global SymCryptFdefModMulMontgomery256AsmInternal
    ldr x4, [x1]
    ldp x10, x11, [x2]
    mul x9, x4, x10
    umulh x10, x4, x10
    mul x5, x4, x11
    adds x10, x10, x5
    umulh x11, x4, x11
    ldp x12, x13, [x2, #16]
    mul x5, x4, x12
    adcs x11, x11, x5
    umulh x12, x4, x12
    mul x5, x4, x13
    adcs x12, x12, x5
    umulh x13, x4, x13
    adc x13, x13, XZR
    eor x14, x14, x14
    ldr x7, [x0, #SymCryptModulusInv64OffsetArm64]
    mul x8, x9, x7
    add x0, x0, #SymCryptModulusValueOffsetArm64
    ldr x4, [x1, #8]
    MUL_AND_MONTGOMERY_REDUCE14_INTERLEAVE x5, x6, x4, x2, x0, x8, x7, x9, x10, x11, x12, x13, x14
    ldr x4, [x1, #16]
    MUL_AND_MONTGOMERY_REDUCE14_INTERLEAVE x5, x6, x4, x2, x0, x8, x7, x10, x11, x12, x13, x14, x9
    ldr x4, [x1, #24]
    MUL_AND_MONTGOMERY_REDUCE14_INTERLEAVE x5, x6, x4, x2, x0, x8, x7, x11, x12, x13, x14, x9, x10
    ldp x4, x5, [x0]
    mul x1, x8, x4
    adds x12, x12, x1
    umulh x2, x8, x4
    adcs x13, x13, x2
    ldp x6, x7, [x0, #16]
    mul x1, x8, x6
    adcs x14, x14, x1
    umulh x2, x8, x6
    adcs x9, x9, x2
    adcs x10, x10, XZR
    adc x11, x11, XZR
    mul x1, x8, x5
    adds x13, x13, x1
    umulh x2, x8, x5
    adcs x14, x14, x2
    mul x1, x8, x7
    adcs x9, x9, x1
    umulh x2, x8, x7
    adcs x10, x10, x2
    adc x11, x11, XZR
    subs x4, x13, x4
    sbcs x5, x14, x5
    sbcs x6, x9, x6
    sbcs x7, x10, x7
    sbcs x11, x11, XZR
    csel x13, x13, x4, cc
    csel x14, x14, x5, cc
    stp x13, x14, [x3]
    csel x9, x9, x6, cc
    csel x10, x10, x7, cc
    stp x9, x10, [x3, #16]
    ret
SymCryptFdefModSquareMontgomery256Asm: .global SymCryptFdefModSquareMontgomery256Asm
.type SymCryptFdefModSquareMontgomery256Asm, %function
    mov x3, x2
    mov x2, x1
    b SymCryptFdefModMulMontgomery256AsmInternal
    ret
SymCryptFdefModAdd384Asm: .global SymCryptFdefModAdd384Asm
.type SymCryptFdefModAdd384Asm, %function
    add x0, x0, #SymCryptModulusValueOffsetArm64
    ldp x4, x5, [x1]
    ldp x10, x11, [x2]
    adds x4, x4, x10
    adcs x5, x5, x11
    ldp x6, x7, [x1, #16]
    ldp x10, x11, [x2, #16]
    adcs x6, x6, x10
    adcs x7, x7, x11
    ldp x8, x9, [x1, #32]
    ldp x10, x11, [x2, #32]
    adcs x8, x8, x10
    adcs x9, x9, x11
    cset x1, cs
    ldp x2, x10, [x0]
    subs x2, x4, x2
    sbcs x10, x5, x10
    ldp x11, x12, [x0, #16]
    sbcs x11, x6, x11
    sbcs x12, x7, x12
    ldp x13, x0, [x0, #32]
    sbcs x13, x8, x13
    sbcs x0, x9, x0
    sbcs x1, x1, XZR
    csel x4, x4, x2, cc
    csel x5, x5, x10, cc
    stp x4, x5, [x3]
    csel x6, x6, x11, cc
    csel x7, x7, x12, cc
    stp x6, x7, [x3, #16]
    csel x8, x8, x13, cc
    csel x9, x9, x0, cc
    stp x8, x9, [x3, #32]
    ret
SymCryptFdefModSub384Asm: .global SymCryptFdefModSub384Asm
.type SymCryptFdefModSub384Asm, %function
    add x0, x0, #SymCryptModulusValueOffsetArm64
    ldp x4, x5, [x1]
    ldp x10, x11, [x2]
    subs x4, x4, x10
    sbcs x5, x5, x11
    ldp x6, x7, [x1, #16]
    ldp x10, x11, [x2, #16]
    sbcs x6, x6, x10
    sbcs x7, x7, x11
    ldp x8, x9, [x1, #32]
    ldp x10, x11, [x2, #32]
    sbcs x8, x8, x10
    sbcs x9, x9, x11
    ldp x1, x2, [x0]
    csel x1, x1, XZR, cc
    csel x2, x2, XZR, cc
    ldp x10, x11, [x0, #16]
    csel x10, x10, XZR, cc
    csel x11, x11, XZR, cc
    ldp x12, x0, [x0, #32]
    csel x12, x12, XZR, cc
    csel x0, x0, XZR, cc
    adds x4, x4, x1
    adcs x5, x5, x2
    stp x4, x5, [x3]
    adcs x6, x6, x10
    adcs x7, x7, x11
    stp x6, x7, [x3, #16]
    adcs x8, x8, x12
    adc x9, x9, x0
    stp x8, x9, [x3, #32]
    ret
.macro MUL_AND_MONTGOMERY_REDUCE16_P384_INTERLEAVE T0, T1, Ai, pB, K, N3, R0, R1, R2, R3, R4, R5, R6, R7
    ldr \T0, [\pB]
    mul \T1, \Ai, \T0
    adds \R1, \R1, \T1
    umulh \T0, \Ai, \T0
    adcs \R2, \R2, \T0
    ldr \T0, [\pB, #16]
    mul \T1, \Ai, \T0
    adcs \R3, \R3, \T1
    umulh \T0, \Ai, \T0
    adcs \R4, \R4, \T0
    ldr \T0, [\pB, #32]
    mul \T1, \Ai, \T0
    adcs \R5, \R5, \T1
    umulh \T0, \Ai, \T0
    adcs \R6, \R6, \T0
    adc \R7, \R7, XZR
    ldr \T0, [\pB, #8]
    mul \T1, \Ai, \T0
    adds \R2, \R2, \T1
    umulh \T0, \Ai, \T0
    adcs \R3, \R3, \T0
    ldr \T0, [\pB, #24]
    mul \T1, \Ai, \T0
    adcs \R4, \R4, \T1
    umulh \T0, \Ai, \T0
    adcs \R5, \R5, \T0
    ldr \T0, [\pB, #40]
    mul \T1, \Ai, \T0
    adcs \R6, \R6, \T1
    umulh \Ai, \Ai, \T0
    adc \Ai, \Ai, XZR
    lsl \T0, \R0, #32
    adds \K, \R0, \T0
    lsr \T1, \K, #32
    adcs \R1, \R1, \T1
    add \T1, \T1, \N3
    adcs \R2, \R2, XZR
    csetm \N3, cs
    subs \R1, \R1, \T0
    sbcs \R2, \R2, \T1
    cinc \N3, \N3, cc
    subs \R2, \R2, \K
    cinc \N3, \N3, cc
    adds \R6, \R6, \K
    adcs \R7, \R7, \Ai
    cset \R0, cs
.endm
SymCryptFdefModMulMontgomeryP384Asm: .global SymCryptFdefModMulMontgomeryP384Asm
.type SymCryptFdefModMulMontgomeryP384Asm, %function
SymCryptFdefModMulMontgomeryP384AsmInternal: .global SymCryptFdefModMulMontgomeryP384AsmInternal
    ldr x4, [x1]
    ldp x10, x11, [x2]
    mul x9, x4, x10
    umulh x10, x4, x10
    mul x5, x4, x11
    adds x10, x10, x5
    umulh x11, x4, x11
    ldp x12, x13, [x2, #16]
    mul x5, x4, x12
    adcs x11, x11, x5
    umulh x12, x4, x12
    mul x5, x4, x13
    adcs x12, x12, x5
    umulh x13, x4, x13
    ldp x14, x15, [x2, #32]
    mul x5, x4, x14
    adcs x13, x13, x5
    umulh x14, x4, x14
    mul x5, x4, x15
    adcs x14, x14, x5
    umulh x15, x4, x15
    adc x15, x15, XZR
    eor x16, x16, x16
    eor x7, x7, x7
    ldr x4, [x1, #8]
    MUL_AND_MONTGOMERY_REDUCE16_P384_INTERLEAVE x5, x6, x4, x2, x8, x7, x9, x10, x11, x12, x13, x14, x15, x16
    ldr x4, [x1, #16]
    MUL_AND_MONTGOMERY_REDUCE16_P384_INTERLEAVE x5, x6, x4, x2, x8, x7, x10, x11, x12, x13, x14, x15, x16, x9
    ldr x4, [x1, #24]
    MUL_AND_MONTGOMERY_REDUCE16_P384_INTERLEAVE x5, x6, x4, x2, x8, x7, x11, x12, x13, x14, x15, x16, x9, x10
    ldr x4, [x1, #32]
    MUL_AND_MONTGOMERY_REDUCE16_P384_INTERLEAVE x5, x6, x4, x2, x8, x7, x12, x13, x14, x15, x16, x9, x10, x11
    ldr x4, [x1, #40]
    MUL_AND_MONTGOMERY_REDUCE16_P384_INTERLEAVE x5, x6, x4, x2, x8, x7, x13, x14, x15, x16, x9, x10, x11, x12
    lsl x5, x14, #32
    adds x8, x14, x5
    lsr x6, x8, #32
    adcs x15, x15, x6
    add x6, x6, x7
    adcs x16, x16, XZR
    csetm x7, cs
    subs x15, x15, x5
    sbcs x16, x16, x6
    cinc x7, x7, cc
    subs x16, x16, x8
    sbcs x9, x9, x7
    sbcs x10, x10, XZR
    sbcs x11, x11, XZR
    sbcs x12, x12, XZR
    sbc x13, x13, XZR
    adds x12, x12, x8
    adc x13, x13, XZR
    mov x4, 0x00000000ffffffff
    mov x5, 0xffffffff00000000
    mov x6, 0xfffffffffffffffe
    mov x0, 0xffffffffffffffff
    subs x4, x15, x4
    sbcs x5, x16, x5
    sbcs x6, x9, x6
    sbcs x7, x10, x0
    sbcs x14, x11, x0
    sbcs x0, x12, x0
    sbcs x13, x13, XZR
    csel x15, x15, x4, cc
    csel x16, x16, x5, cc
    stp x15, x16, [x3]
    csel x9, x9, x6, cc
    csel x10, x10, x7, cc
    stp x9, x10, [x3, #16]
    csel x11, x11, x14, cc
    csel x12, x12, x0, cc
    stp x11, x12, [x3, #32]
    ret
SymCryptFdefModSquareMontgomeryP384Asm: .global SymCryptFdefModSquareMontgomeryP384Asm
.type SymCryptFdefModSquareMontgomeryP384Asm, %function
    mov x3, x2
    mov x2, x1
    b SymCryptFdefModMulMontgomeryP384AsmInternal
    ret
SymCryptFdefMontgomeryReduceAsm: .global SymCryptFdefMontgomeryReduceAsm
.type SymCryptFdefMontgomeryReduceAsm, %function
    ldr w3, [x0, #SymCryptModulusNdigitsOffsetArm64]
    ldr x5, [x0, #SymCryptModulusInv64OffsetArm64]
    add x0, x0, #SymCryptModulusValueOffsetArm64
    lsl x4, x3, #2
    sub x0, x0, #32
    sub x1, x1, #32
    sub x2, x2, #32
    mov x15, x3
    mov x16, x0
    mov x17, x1
    and x7, x7, xzr
SymCryptFdefMontgomeryReduceAsmOuter:
    ldr x8, [x1, #32]
    mul x6, x8, x5
    and x12, x12, xzr
SymCryptFdefMontgomeryReduceAsmInner:
    ldp x10, x11, [x0, #32]!
    ldp x8, x9, [x1, #32]!
    mul x14, x6, x10
    adds x14, x14, x8
    umulh x13, x6, x10
    adc x13, x13, xzr
    adds x12, x12, x14
    adc x13, x13, xzr
    str x12, [x1]
    mul x14, x6, x11
    adds x14, x14, x9
    umulh x12, x6, x11
    adc x12, x12, xzr
    adds x13, x13, x14
    adc x12, x12, xzr
    str x13, [x1, #8]
    ldp x10, x11, [x0, #16]
    ldp x8, x9, [x1, #16]
    mul x14, x6, x10
    adds x14, x14, x8
    umulh x13, x6, x10
    adc x13, x13, xzr
    adds x12, x12, x14
    adc x13, x13, xzr
    str x12, [x1, #16]
    mul x14, x6, x11
    adds x14, x14, x9
    umulh x12, x6, x11
    adc x12, x12, xzr
    adds x13, x13, x14
    adc x12, x12, xzr
    str x13, [x1, #24]
    subs x3, x3, #1
    bne SymCryptFdefMontgomeryReduceAsmInner
    ldr x8, [x1, #32]
    adds x12, x12, x8
    adc x13, xzr, xzr
    adds x12, x12, x7
    adc x7, x13, xzr
    str x12, [x1, #32]
    subs x4, x4, #1
    add x17, x17, #8
    mov x0, x16
    mov x1, x17
    mov x3, x15
    bne SymCryptFdefMontgomeryReduceAsmOuter
    mov x14, x2
    mov x0, x17
    mov x1, x16
    mov x10, x7
    mov x3, x15
    subs x4, x4, x4
SymCryptFdefMontgomeryReduceRawSubAsmLoop:
    sub x3, x3, #1
    ldp x4, x6, [x0, #32]!
    ldp x5, x7, [x1, #32]!
    sbcs x4, x4, x5
    sbcs x6, x6, x7
    stp x4, x6, [x2, #32]!
    ldp x4, x6, [x0, #16]
    ldp x5, x7, [x1, #16]
    sbcs x4, x4, x5
    sbcs x6, x6, x7
    stp x4, x6, [x2, #16]
    cbnz x3, SymCryptFdefMontgomeryReduceRawSubAsmLoop
    cset x0, cc
    orr x11, x10, x0
    mov x0, x17
    mov x1, x14
    mov x2, x15
    subs x4, x10, x11
SymCryptFdefMontgomeryReduceMaskedCopyAsmLoop:
    sub x2, x2, #1
    ldp x4, x6, [x0, #32]!
    ldp x5, x7, [x1, #32]!
    csel x4, x4, x5, cc
    csel x6, x6, x7, cc
    stp x4, x6, [x1]
    ldp x4, x6, [x0, #16]
    ldp x5, x7, [x1, #16]
    csel x4, x4, x5, cc
    csel x6, x6, x7, cc
    stp x4, x6, [x1, #16]
    cbnz x2, SymCryptFdefMontgomeryReduceMaskedCopyAsmLoop
    ret
.macro MULADD_LOADSTORE18 pS, pM, pD, K, Tc, T0, T1, T2, T3, T4, T5
    ldp \T2, \T3, [\pS]
    adds \T2, \T2, \Tc
    ldr \T0, [\pM, #8]
    mul \T1, \K, \T0
    adcs \T3, \T3, \T1
    umulh \T0, \K, \T0
    ldp \T4, \T5, [\pS, #16]
    adcs \T4, \T4, \T0
    ldr \T0, [\pM, #24]
    mul \T1, \K, \T0
    adcs \T5, \T5, \T1
    umulh \Tc, \K, \T0
    adc \Tc, \Tc, XZR
    ldr \T0, [\pM]
    mul \T1, \K, \T0
    adds \T2, \T2, \T1
    umulh \T0, \K, \T0
    adcs \T3, \T3, \T0
    stp \T2, \T3, [\pD]
    ldr \T0, [\pM, #16]
    mul \T1, \K, \T0
    adcs \T4, \T4, \T1
    umulh \T0, \K, \T0
    adcs \T5, \T5, \T0
    stp \T4, \T5, [\pD, #16]
    adc \Tc, \Tc, XZR
.endm
.macro SHIFTRIGHT2 pD, index, shrVal, shrMask, shlVal, Tcin, Tcout, T0, T1
    ldp \Tcout, \T0, [\pD, #(\index*8)]
    lsr \T1, \T0, \shrVal
    lsl \Tcin, \Tcin, \shlVal
    and \T1, \T1, \shrMask
    orr \T1, \T1, \Tcin
    lsr \Tcin, \Tcout, \shrVal
    lsl \T0, \T0, \shlVal
    and \Tcin, \Tcin, \shrMask
    orr \Tcin, \Tcin, \T0
    stp \Tcin, \T1, [\pD, #(\index*8)]
.endm
SymCryptFdefModDivSmallPow2Asm: .global SymCryptFdefModDivSmallPow2Asm
.type SymCryptFdefModDivSmallPow2Asm, %function
    ldr x7, [x1]
    ldr x5, [x0, #SymCryptModulusInv64OffsetArm64]
    mul x7, x7, x5
    mov x6, #-1
    neg x5, x2
    lsr x6, x6, x5
    and x7, x7, x6
    ldr w4, [x0, #SymCryptModulusNdigitsOffsetArm64]
    add x5, x0, #SymCryptModulusValueOffsetArm64
    eor x6, x6, x6
SymCryptFdefModDivSmallPow2AsmMulAddLoop:
    MULADD_LOADSTORE18 x1, x5, x3, x7, x6, x8, x9, X10, x11, x12, x13
    add x1, x1, #32
    add x5, x5, #32
    add x3, x3, #32
    sub w4, w4, #1
    cbnz w4, SymCryptFdefModDivSmallPow2AsmMulAddLoop
    ldr w0, [x0, #SymCryptModulusNdigitsOffsetArm64]
    mov x1, #64
    subs x1, x1, x2
    csetm x4, ne
    sub x3, x3, #32
SymCryptFdefModDivSmallPow2AsmShiftRightLoop:
    SHIFTRIGHT2 x3, 2, x2, x4, x1, x6, x7, x8, x9
    SHIFTRIGHT2 x3, 0, x2, x4, x1, x7, x6, x8, x9
    sub x3, x3, #32
    sub w0, w0, #1
    cbnz w0, SymCryptFdefModDivSmallPow2AsmShiftRightLoop
    ret
