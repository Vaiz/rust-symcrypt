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
SymCryptFdef369RawAddAsm: .global SymCryptFdef369RawAddAsm
.type SymCryptFdef369RawAddAsm, %function
    ldp x4, x6, [x0]
    ldp x5, x7, [x1]
    adds x4, x4, x5
    adcs x6, x6, x7
    stp x4, x6, [x2]
    ldr x4, [x0, #16]
    sub x3, x3, #1
    ldr x5, [x1, #16]
    adcs x4, x4, x5
    str x4, [x2, #16]
    cbz x3, SymCryptFdef369RawAddAsmEnd
SymCryptFdef369RawAddAsmLoop:
    ldp x4, x6, [x0, #24]!
    ldp x5, x7, [x1, #24]!
    adcs x4, x4, x5
    adcs x6, x6, x7
    stp x4, x6, [x2, #24]!
    ldr x4, [x0, #16]
    sub x3, x3, #1
    ldr x5, [x1, #16]
    adcs x4, x4, x5
    str x4, [x2, #16]
    cbnz x3, SymCryptFdef369RawAddAsmLoop
    .align 4
SymCryptFdef369RawAddAsmEnd:
    cset x0, cs
    ret
SymCryptFdef369RawSubAsm: .global SymCryptFdef369RawSubAsm
.type SymCryptFdef369RawSubAsm, %function
    ldp x4, x6, [x0]
    ldp x5, x7, [x1]
    subs x4, x4, x5
    sbcs x6, x6, x7
    stp x4, x6, [x2]
    ldr x4, [x0, #16]
    sub x3, x3, #1
    ldr x5, [x1, #16]
    sbcs x4, x4, x5
    str x4, [x2, #16]
    cbz x3, SymCryptFdef369RawSubAsmEnd
SymCryptFdef369RawSubAsmLoop:
    ldp x4, x6, [x0, #24]!
    ldp x5, x7, [x1, #24]!
    sbcs x4, x4, x5
    sbcs x6, x6, x7
    stp x4, x6, [x2, #24]!
    ldr x4, [x0, #16]
    sub x3, x3, #1
    ldr x5, [x1, #16]
    sbcs x4, x4, x5
    str x4, [x2, #16]
    cbnz x3, SymCryptFdef369RawSubAsmLoop
    .align 4
SymCryptFdef369RawSubAsmEnd:
    cset x0, cc
    ret
SymCryptFdef369MaskedCopyAsm: .global SymCryptFdef369MaskedCopyAsm
.type SymCryptFdef369MaskedCopyAsm, %function
    subs xzr, xzr, x3
    ldp x3, x5, [x0]
    ldp x4, x6, [x1]
    csel x3, x3, x4, cc
    csel x5, x5, x6, cc
    stp x3, x5, [x1]
    ldr x3, [x0, #16]
    sub x2, x2, #1
    ldr x4, [x1, #16]
    csel x3, x3, x4, cc
    str x3, [x1, #16]
    cbz x2, SymCryptFdef369MaskedCopyAsmEnd
SymCryptFdef369MaskedCopyAsmLoop:
    ldp x3, x5, [x0, #24]!
    ldp x4, x6, [x1, #24]!
    csel x3, x3, x4, cc
    csel x5, x5, x6, cc
    stp x3, x5, [x1]
    ldr x3, [x0, #16]
    sub x2, x2, #1
    ldr x4, [x1, #16]
    csel x3, x3, x4, cc
    str x3, [x1, #16]
    cbnz x2, SymCryptFdef369MaskedCopyAsmLoop
SymCryptFdef369MaskedCopyAsmEnd:
    ret
SymCryptFdef369RawMulAsm: .global SymCryptFdef369RawMulAsm
.type SymCryptFdef369RawMulAsm, %function
    add x1, x1, x1, LSL #1
    sub x2, x2, #24
    sub x4, x4, #24
    mov x5, x4
    mov x13, x2
    mov x14, x3
    ands x12, x12, xzr
    ldr x6, [x0]
SymCryptFdef369RawMulAsmLoopInner1:
    sub x3, x3, #1
    ldp x7, x8, [x2, #24]!
    mul x11, x6, x7
    adcs x11, x11, x12
    umulh x12, x6, x7
    mul x15, x6, x8
    adcs x15, x15, x12
    umulh x12, x6, x8
    stp x11, x15, [x4, #24]!
    ldr x7, [x2, #16]
    mul x11, x6, x7
    adcs x11, x11, x12
    umulh x12, x6, x7
    str x11, [x4, #16]
    cbnz x3, SymCryptFdef369RawMulAsmLoopInner1
    adc x12, x12, xzr
    str x12, [x4, #24]
    sub x1, x1, #1
    add x0, x0, #8
    add x5, x5, #8
SymCryptFdef369RawMulAsmLoopOuter:
    mov x3, x14
    mov x2, x13
    mov x4, x5
    ands x12, x12, xzr
    ldr x6, [x0]
SymCryptFdef369RawMulAsmLoopInner:
    sub x3, x3, #1
    ldp x7, x8, [x2, #24]!
    ldp x9, x10, [x4, #24]!
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
    ldr x7, [x2, #16]
    ldr x9, [x4, #16]
    adcs x9, x9, x12
    umulh x12, x6, x7
    adc x12, x12, xzr
    mul x11, x6, x7
    adds x9, x9, x11
    str x9, [x4, #16]
    cbnz x3, SymCryptFdef369RawMulAsmLoopInner
    adc x12, x12, xzr
    str x12, [x4, #24]
    subs x1, x1, #1
    add x0, x0, #8
    add x5, x5, #8
    bne SymCryptFdef369RawMulAsmLoopOuter
    ret
SymCryptFdef369MontgomeryReduceAsm: .global SymCryptFdef369MontgomeryReduceAsm
.type SymCryptFdef369MontgomeryReduceAsm, %function
    ldr w3, [x0, #SymCryptModulusNdigitsOffsetArm64]
    ldr x5, [x0, #SymCryptModulusInv64OffsetArm64]
    add x0, x0, #SymCryptModulusValueOffsetArm64
    add x4, x3, x3, LSL #1
    sub x0, x0, #24
    sub x1, x1, #24
    sub x2, x2, #24
    mov x15, x3
    mov x16, x0
    mov x17, x1
    and x7, x7, xzr
SymCryptFdef369MontgomeryReduceAsmOuter:
    ldr x8, [x1, #24]
    mul x6, x8, x5
    and x12, x12, xzr
SymCryptFdef369MontgomeryReduceAsmInner:
    ldp x10, x11, [x0, #24]!
    ldp x8, x9, [x1, #24]!
    mul x14, x6, x10
    adds x14, x14, x8
    umulh x13, x6, x10
    adc x13, x13, xzr
    adds x12, x12, x14
    adc x13, x13, xzr
    str x12, [x1]
    mov x12, x13
    mul x14, x6, x11
    adds x14, x14, x9
    umulh x13, x6, x11
    adc x13, x13, xzr
    adds x12, x12, x14
    adc x13, x13, xzr
    str x12, [x1, #8]
    mov x12, x13
    ldr x10, [x0, #16]
    ldr x8, [x1, #16]
    mul x14, x6, x10
    adds x14, x14, x8
    umulh x13, x6, x10
    adc x13, x13, xzr
    adds x12, x12, x14
    adc x13, x13, xzr
    str x12, [x1, #16]
    mov x12, x13
    subs x3, x3, #1
    bne SymCryptFdef369MontgomeryReduceAsmInner
    ldr x8, [x1, #24]
    adds x12, x12, x8
    adc x13, xzr, xzr
    adds x12, x12, x7
    adc x7, x13, xzr
    str x12, [x1, #24]
    subs x4, x4, #1
    add x17, x17, #8
    mov x0, x16
    mov x1, x17
    mov x3, x15
    bne SymCryptFdef369MontgomeryReduceAsmOuter
    mov x14, x2
    mov x0, x17
    mov x1, x16
    mov x10, x7
    mov x3, x15
    subs x4, x4, x4
SymCryptFdef369MontgomeryReduceRawSubAsmLoop:
    sub x3, x3, #1
    ldp x4, x6, [x0, #24]!
    ldp x5, x7, [x1, #24]!
    sbcs x4, x4, x5
    sbcs x6, x6, x7
    stp x4, x6, [x2, #24]!
    ldr x4, [x0, #16]
    ldr x5, [x1, #16]
    sbcs x4, x4, x5
    str x4, [x2, #16]
    cbnz x3, SymCryptFdef369MontgomeryReduceRawSubAsmLoop
    cset x0, cc
    orr x11, x10, x0
    mov x0, x17
    mov x1, x14
    mov x2, x15
    subs x4, x10, x11
SymCryptFdef369MontgomeryReduceMaskedCopyAsmLoop:
    sub x2, x2, #1
    ldp x4, x6, [x0, #24]!
    ldp x5, x7, [x1, #24]!
    csel x4, x4, x5, cc
    csel x6, x6, x7, cc
    stp x4, x6, [x1]
    ldr x4, [x0, #16]
    ldr x5, [x1, #16]
    csel x4, x4, x5, cc
    str x4, [x1, #16]
    cbnz x2, SymCryptFdef369MontgomeryReduceMaskedCopyAsmLoop
    ret
