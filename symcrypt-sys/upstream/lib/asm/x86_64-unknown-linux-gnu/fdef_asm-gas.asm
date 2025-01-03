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
.intel_syntax noprefix
.macro MULT_SINGLEADD_128 index, src_reg, dst_reg, Q0, QH, mul_word, even_carry, odd_carry
        mov \Q0, [\src_reg + 8*\index]
        mul \mul_word
        mov \odd_carry, \QH
        add \Q0, \even_carry
        mov [\dst_reg + 8*\index], \Q0
        adc \odd_carry, 0
        mov \Q0, [\src_reg + 8*(\index+1)]
        mul \mul_word
        mov \even_carry, \QH
        add \Q0, \odd_carry
        mov [\dst_reg + 8*(\index+1)], \Q0
        adc \even_carry, 0
.endm
.macro MULT_DOUBLEADD_128 index, src_reg, dst_reg, Q0, QH, mul_word, even_carry, odd_carry
        mov \Q0, [\src_reg + 8*\index]
        mul \mul_word
        mov \odd_carry, \QH
        add \Q0, [\dst_reg + 8*\index]
        adc \odd_carry, 0
        add \Q0, \even_carry
        mov [\dst_reg + 8*\index], \Q0
        adc \odd_carry, 0
        mov \Q0, [\src_reg + 8*(\index+1)]
        mul \mul_word
        mov \even_carry, \QH
        add \Q0, [\dst_reg + 8*(\index+1)]
        adc \even_carry, 0
        add \Q0, \odd_carry
        mov [\dst_reg + 8*(\index+1)], \Q0
        adc \even_carry, 0
.endm
.macro SQR_SINGLEADD_64 index, src_reg, dst_reg, Q0, QH, mul_word, src_carry, dst_carry
        mov \Q0, [\src_reg + 8*\index]
        mul \mul_word
        mov \dst_carry, \QH
        add \Q0, \src_carry
        mov [\dst_reg + 8*\index], \Q0
        adc \dst_carry, 0
.endm
.macro SQR_DOUBLEADD_64 index, src_reg, dst_reg, Q0, QH, mul_word, src_carry, dst_carry
        mov \Q0, [\src_reg + 8*\index]
        mul \mul_word
        mov \dst_carry, \QH
        add \Q0, [\dst_reg + 8*\index]
        adc \dst_carry, 0
        add \Q0, \src_carry
        mov [\dst_reg + 8*\index], \Q0
        adc \dst_carry, 0
.endm
.macro SQR_SHIFT_LEFT index, Q0, src_reg
    mov \Q0, [\src_reg + 8*\index]
    adc \Q0, \Q0
    mov [\src_reg + 8*\index], \Q0
.endm
.macro SQR_DIAGONAL_PROP index, src_reg, dst_reg, Q0, QH, carry
    mov \Q0, [\src_reg + 8*\index]
    mul \Q0
    add \Q0, [\dst_reg + 16*\index]
    adc \QH, 0
    add \Q0, \carry
    adc \QH, 0
    mov [\dst_reg + 16*\index], \Q0
    mov \Q0, \QH
    xor \QH, \QH
    add \Q0, [\dst_reg + 16*\index + 8]
    adc \QH, 0
    mov [\dst_reg + 16*\index + 8], \Q0
    mov \carry, \QH
.endm
.macro MONTGOMERY14 Q0, QH, mul_word, pA, R0, R1, R2, R3, Cy
    mov \Q0, [\pA]
    mul \mul_word
    add \R0, -1
    adc \QH, 0
    mov \Cy, \QH
    mov \Q0, [\pA + 8]
    mul \mul_word
    add \R1, \Q0
    adc \QH, 0
    add \R1, \Cy
    adc \QH, 0
    mov \Cy, \QH
    mov \Q0, [\pA + 16]
    mul \mul_word
    add \R2, \Q0
    adc \QH, 0
    add \R2, \Cy
    adc \QH, 0
    mov \Cy, \QH
    mov \Q0, [\pA + 24]
    mul \mul_word
    add \R3, \Q0
    adc \QH, 0
    add \R3, \Cy
    adc \QH, 0
.endm
.macro MUL14 Q0, QH, mul_word, pA, R0, R1, R2, R3, Cy
    mov \Q0, [\pA]
    mul \mul_word
    add \R0, \Q0
    adc \QH, 0
    mov \Cy, \QH
    mov \Q0, [\pA + 8]
    mul \mul_word
    add \R1, \Q0
    adc \QH, 0
    add \R1, \Cy
    adc \QH, 0
    mov \Cy, \QH
    mov \Q0, [\pA + 16]
    mul \mul_word
    add \R2, \Q0
    adc \QH, 0
    add \R2, \Cy
    adc \QH, 0
    mov \Cy, \QH
    mov \Q0, [\pA + 24]
    mul \mul_word
    add \R3, \Q0
    adc \QH, 0
    add \R3, \Cy
    adc \QH, 0
.endm
.macro SQR_DOUBLEADD_64_2 index, src_reg, dst_reg, Q0, QH, mul_word, src_carry, dst_carry
    SQR_DOUBLEADD_64 (\index), \src_reg, \dst_reg, \Q0, \QH, \mul_word, \src_carry, \dst_carry
    SQR_DOUBLEADD_64 (\index + 1), \src_reg, \dst_reg, \Q0, \QH, \mul_word, \dst_carry, \src_carry
.endm
.macro SQR_DOUBLEADD_64_4 index, src_reg, dst_reg, Q0, QH, mul_word, src_carry, dst_carry
    SQR_DOUBLEADD_64_2 (\index), \src_reg, \dst_reg, \Q0, \QH, \mul_word, \src_carry, \dst_carry
    SQR_DOUBLEADD_64_2 (\index + 2), \src_reg, \dst_reg, \Q0, \QH, \mul_word, \src_carry, \dst_carry
.endm
.macro SQR_DOUBLEADD_64_8 index, src_reg, dst_reg, Q0, QH, mul_word, src_carry, dst_carry
    SQR_DOUBLEADD_64_4 (\index), \src_reg, \dst_reg, \Q0, \QH, \mul_word, \src_carry, \dst_carry
    SQR_DOUBLEADD_64_4 (\index + 4), \src_reg, \dst_reg, \Q0, \QH, \mul_word, \src_carry, \dst_carry
.endm
.macro SQR_SIZE_SPECIFIC_INIT outer_src_reg, outer_dst_reg, inner_src_reg, inner_dst_reg, mul_word
    lea \outer_src_reg, [\outer_src_reg + 8]
    lea \outer_dst_reg, [\outer_dst_reg + 16]
    mov \inner_src_reg, \outer_src_reg
    mov \inner_dst_reg, \outer_dst_reg
    mov \mul_word, [\outer_src_reg]
    lea \inner_src_reg, [\inner_src_reg + 8]
.endm
SymCryptFdefRawAddAsm: .global SymCryptFdefRawAddAsm
.type SymCryptFdefRawAddAsm, %function
        add ecx, ecx
        xor rax, rax
SymCryptFdefRawAddAsmLoop:
        mov rax,[rdi]
        adc rax,[rsi]
        mov [rdx],rax
        mov rax,[rdi + 8]
        adc rax,[rsi + 8]
        mov [rdx + 8], rax
        mov rax,[rdi + 16]
        adc rax,[rsi + 16]
        mov [rdx + 16], rax
        mov rax,[rdi + 24]
        adc rax,[rsi + 24]
        mov [rdx + 24], rax
        lea rdi, [rdi + 32]
        lea rsi, [rsi + 32]
        lea rdx, [rdx + 32]
        dec ecx
        jnz SymCryptFdefRawAddAsmLoop
        mov rax, 0
        adc rax, rax
ret
SymCryptFdefRawSubAsm: .global SymCryptFdefRawSubAsm
.type SymCryptFdefRawSubAsm, %function
        add ecx, ecx
        xor rax, rax
SymCryptFdefRawSubAsmLoop:
        mov rax,[rdi]
        sbb rax,[rsi]
        mov [rdx],rax
        mov rax,[rdi + 8]
        sbb rax,[rsi + 8]
        mov [rdx + 8], rax
        mov rax,[rdi + 16]
        sbb rax,[rsi + 16]
        mov [rdx + 16], rax
        mov rax,[rdi + 24]
        sbb rax,[rsi + 24]
        mov [rdx + 24], rax
        lea rdi,[rdi + 32]
        lea rsi,[rsi + 32]
        lea rdx,[rdx + 32]
        dec ecx
        jnz SymCryptFdefRawSubAsmLoop
        mov rax, 0
        adc rax, rax
ret
SymCryptFdefMaskedCopyAsm: .global SymCryptFdefMaskedCopyAsm
.type SymCryptFdefMaskedCopyAsm, %function
        add edx, edx
        movd xmm0, ecx
        pcmpeqd xmm1, xmm1
        pshufd xmm0, xmm0, 0
        pxor xmm1, xmm0
SymCryptFdefMaskedCopyAsmLoop:
        movdqa xmm2, [rdi]
        movdqa xmm3, [rsi]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [rsi], xmm2
        movdqa xmm2, [rdi + 16]
        movdqa xmm3, [rsi + 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [rsi + 16], xmm2
        add rdi, 32
        add rsi, 32
        dec edx
        jnz SymCryptFdefMaskedCopyAsmLoop
ret
SymCryptFdefRawMulAsm: .global SymCryptFdefRawMulAsm
.type SymCryptFdefRawMulAsm, %function
push rbx
push rbp
push r12
push r13
mov r10, rdx
        shl rsi, 3
        mov r9, r10
        mov r11, r8
        mov rbx, [rdi]
        xor rbp, rbp
        mov r12, rcx
.align 16
SymCryptFdefRawMulAsmLoop1:
        MULT_SINGLEADD_128 0, r9, r11, rax, rdx, rbx, rbp, r13
        MULT_SINGLEADD_128 2, r9, r11, rax, rdx, rbx, rbp, r13
        MULT_SINGLEADD_128 4, r9, r11, rax, rdx, rbx, rbp, r13
        MULT_SINGLEADD_128 6, r9, r11, rax, rdx, rbx, rbp, r13
        lea r9,[r9 + 64]
        lea r11,[r11 + 64]
        dec r12
        jnz SymCryptFdefRawMulAsmLoop1
        mov [r11], rbp
        dec rsi
.align 16
SymCryptFdefRawMulAsmLoopOuter:
        add rdi, 8
        add r8, 8
        mov rbx, [rdi]
        mov r9, r10
        mov r11, r8
        xor rbp, rbp
        mov r12, rcx
.align 16
SymCryptFdefRawMulAsmLoop2:
        MULT_DOUBLEADD_128 0, r9, r11, rax, rdx, rbx, rbp, r13
        MULT_DOUBLEADD_128 2, r9, r11, rax, rdx, rbx, rbp, r13
        MULT_DOUBLEADD_128 4, r9, r11, rax, rdx, rbx, rbp, r13
        MULT_DOUBLEADD_128 6, r9, r11, rax, rdx, rbx, rbp, r13
        lea r9,[r9 + 64]
        lea r11,[r11 + 64]
        dec r12
        jnz SymCryptFdefRawMulAsmLoop2
        mov [r11], rbp
        dec rsi
        jnz SymCryptFdefRawMulAsmLoopOuter
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefRawSquareAsm: .global SymCryptFdefRawSquareAsm
.type SymCryptFdefRawSquareAsm, %function
push rbx
push rbp
push r12
push r13
push r14
mov r10, rdx
        mov [rsp + -8 ], rdi
        mov r12, rsi
        shl r12, 3
        mov rbp, r10
        mov rcx, rdi
        mov r8, r10
        mov r9, [rdi]
        xor r11, r11
        xor rbx, rbx
        mov r13, r12
        mov [r8], r11
        jmp SymCryptFdefRawSquareAsmInnerLoopInit_Word1
.align 16
SymCryptFdefRawSquareAsmInnerLoopInit_Word0:
        SQR_SINGLEADD_64 0, rcx, r8, rax, rdx, r9, r11, rbx
.align 16
SymCryptFdefRawSquareAsmInnerLoopInit_Word1:
        SQR_SINGLEADD_64 1, rcx, r8, rax, rdx, r9, rbx, r11
        SQR_SINGLEADD_64 2, rcx, r8, rax, rdx, r9, r11, rbx
        SQR_SINGLEADD_64 3, rcx, r8, rax, rdx, r9, rbx, r11
        lea rcx, [rcx + 32]
        lea r8, [r8 + 32]
        sub r13, 4
        jnz SymCryptFdefRawSquareAsmInnerLoopInit_Word0
        mov [r8], r11
        dec r12
        mov r14, 1
.align 16
SymCryptFdefRawSquareAsmLoopOuter:
        add rbp, 8
        mov rcx, rdi
        mov r8, rbp
        mov r9, [rdi + 8*r14]
        inc r14b
        mov r13, r12
        add r13, 2
        and r13, -4
        xor r11, r11
        xor rbx, rbx
        cmp r14b, 3
        je SymCryptFdefRawSquareAsmInnerLoop_Word3
        cmp r14b, 2
        je SymCryptFdefRawSquareAsmInnerLoop_Word2
        cmp r14b, 1
        je SymCryptFdefRawSquareAsmInnerLoop_Word1
        xor r14b, r14b
        add rdi, 32
        add rbp, 32
        mov rcx, rdi
        mov r8, rbp
.align 16
SymCryptFdefRawSquareAsmInnerLoop_Word0:
        SQR_DOUBLEADD_64 0, rcx, r8, rax, rdx, r9, r11, rbx
.align 16
SymCryptFdefRawSquareAsmInnerLoop_Word1:
        SQR_DOUBLEADD_64 1, rcx, r8, rax, rdx, r9, rbx, r11
.align 16
SymCryptFdefRawSquareAsmInnerLoop_Word2:
        SQR_DOUBLEADD_64 2, rcx, r8, rax, rdx, r9, r11, rbx
.align 16
SymCryptFdefRawSquareAsmInnerLoop_Word3:
        SQR_DOUBLEADD_64 3, rcx, r8, rax, rdx, r9, rbx, r11
        lea rcx, [rcx + 32]
        lea r8, [r8 + 32]
        sub r13, 4
        jnz SymCryptFdefRawSquareAsmInnerLoop_Word0
        mov [r8], r11
        dec r12
        cmp r12, 1
        jne SymCryptFdefRawSquareAsmLoopOuter
        xor rdx, rdx
        mov [rbp + 40], rdx
        mov r12, rsi
        mov r8, r10
        shl r12, 1
.align 16
SymCryptFdefRawSquareAsmSecondPass:
        SQR_SHIFT_LEFT 0, rax, r8
        SQR_SHIFT_LEFT 1, rax, r8
        SQR_SHIFT_LEFT 2, rax, r8
        SQR_SHIFT_LEFT 3, rax, r8
        SQR_SHIFT_LEFT 4, rax, r8
        SQR_SHIFT_LEFT 5, rax, r8
        SQR_SHIFT_LEFT 6, rax, r8
        SQR_SHIFT_LEFT 7, rax, r8
        lea r8, [r8 + 64]
        dec r12
        jnz SymCryptFdefRawSquareAsmSecondPass
        mov rdi, [rsp + -8 ]
SymCryptFdefRawSquareAsmThirdPass:
        SQR_DIAGONAL_PROP 0, rdi, r10, rax, rdx, r12
        SQR_DIAGONAL_PROP 1, rdi, r10, rax, rdx, r12
        SQR_DIAGONAL_PROP 2, rdi, r10, rax, rdx, r12
        SQR_DIAGONAL_PROP 3, rdi, r10, rax, rdx, r12
        SQR_DIAGONAL_PROP 4, rdi, r10, rax, rdx, r12
        SQR_DIAGONAL_PROP 5, rdi, r10, rax, rdx, r12
        SQR_DIAGONAL_PROP 6, rdi, r10, rax, rdx, r12
        SQR_DIAGONAL_PROP 7, rdi, r10, rax, rdx, r12
        add rdi, 64
        add r10, 128
        dec rsi
        jnz SymCryptFdefRawSquareAsmThirdPass
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefMontgomeryReduceAsm: .global SymCryptFdefMontgomeryReduceAsm
.type SymCryptFdefMontgomeryReduceAsm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
mov r10, rdx
        mov ecx, [rdi + SymCryptModulusNdigitsOffsetAmd64]
        mov r8, [rdi + SymCryptModulusInv64OffsetAmd64]
        lea rdi, [rdi + SymCryptModulusValueOffsetAmd64]
        mov r15d, ecx
        shl r15d, 3
        xor ebp, ebp
.align 16
SymCryptFdefMontgomeryReduceAsmOuterLoop:
        mov r9, [rsi]
        mov r13, rsi
        mov r12, rdi
        imul r9, r8
        mov r14d, ecx
        xor r11d, r11d
.align 16
SymCryptFdefMontgomeryReduceAsmInnerloop:
        MULT_DOUBLEADD_128 0, r12, r13, rax, rdx, r9, r11, rbx
        MULT_DOUBLEADD_128 2, r12, r13, rax, rdx, r9, r11, rbx
        MULT_DOUBLEADD_128 4, r12, r13, rax, rdx, r9, r11, rbx
        MULT_DOUBLEADD_128 6, r12, r13, rax, rdx, r9, r11, rbx
        lea r12,[r12 + 64]
        lea r13,[r13 + 64]
        dec r14d
        jnz SymCryptFdefMontgomeryReduceAsmInnerloop
        add r11, rbp
        mov ebp, 0
        adc rbp, 0
        add r11, [r13]
        adc rbp, 0
        mov [r13], r11
        lea rsi,[rsi + 8]
        dec r15d
        jnz SymCryptFdefMontgomeryReduceAsmOuterLoop
        mov r14d, ecx
        mov r13, rsi
        mov r12, rdi
        mov r11, r10
.align 16
SymCryptFdefMontgomeryReduceAsmSubLoop:
        mov rax,[r13]
        sbb rax,[r12]
        mov [r11], rax
        mov rax,[r13 + 8]
        sbb rax,[r12 + 8]
        mov [r11 + 8], rax
        mov rax,[r13 + 16]
        sbb rax,[r12 + 16]
        mov [r11 + 16], rax
        mov rax,[r13 + 24]
        sbb rax,[r12 + 24]
        mov [r11 + 24], rax
        mov rax,[r13 + 32]
        sbb rax,[r12 + 32]
        mov [r11 + 32], rax
        mov rax,[r13 + 40]
        sbb rax,[r12 + 40]
        mov [r11 + 40], rax
        mov rax,[r13 + 48]
        sbb rax,[r12 + 48]
        mov [r11 + 48], rax
        mov rax,[r13 + 56]
        sbb rax,[r12 + 56]
        mov [r11 + 56], rax
        lea r13,[r13 + 64]
        lea r12,[r12 + 64]
        lea r11,[r11 + 64]
        dec r14d
        jnz SymCryptFdefMontgomeryReduceAsmSubLoop
        sbb ebp, 0
        movd xmm0, ebp
        pcmpeqd xmm1, xmm1
        pshufd xmm0, xmm0, 0
        pxor xmm1, xmm0
.align 16
SymCryptFdefMontgomeryReduceAsmMaskedCopyLoop:
        movdqa xmm2, [rsi]
        movdqa xmm3, [r10]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10], xmm2
        movdqa xmm2, [rsi + 16]
        movdqa xmm3, [r10 + 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10 + 16], xmm2
        movdqa xmm2, [rsi + 32]
        movdqa xmm3, [r10 + 32]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10 + 32], xmm2
        movdqa xmm2, [rsi + 48]
        movdqa xmm3, [r10 + 48]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10 + 48], xmm2
        lea rsi,[rsi + 64]
        lea r10,[r10 + 64]
        dec ecx
        jnz SymCryptFdefMontgomeryReduceAsmMaskedCopyLoop
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefModSub256Asm: .global SymCryptFdefModSub256Asm
.type SymCryptFdefModSub256Asm, %function
        add rdi, SymCryptModulusValueOffsetAmd64
        mov rax, [rsi + 0*8]
        sub rax, [rdx + 0*8]
        mov r8, [rsi + 1*8]
        sbb r8, [rdx + 1*8]
        mov r9, [rsi + 2*8]
        sbb r9, [rdx + 2*8]
        mov r10, [rsi + 3*8]
        sbb r10, [rdx + 3*8]
        mov rsi, 0
        cmovb rsi, [rdi + 0*8]
        mov rdx, 0
        cmovb rdx, [rdi + 1*8]
        mov r11, 0
        cmovb r11, [rdi + 2*8]
        mov rdi, [rdi + 3*8]
        cmovnb rdi, rsi
        add rax, rsi
        adc r8, rdx
        adc r9, r11
        adc r10, rdi
        mov [rcx + 0*8], rax
        mov [rcx + 1*8], r8
        mov [rcx + 2*8], r9
        mov [rcx + 3*8], r10
ret
SymCryptFdefModSub384Asm: .global SymCryptFdefModSub384Asm
.type SymCryptFdefModSub384Asm, %function
push rbx
push rbp
push r12
push r13
        add rdi, SymCryptModulusValueOffsetAmd64
        mov rax, [rsi + 0*8]
        sub rax, [rdx + 0*8]
        mov r8, [rsi + 1*8]
        sbb r8, [rdx + 1*8]
        mov r9, [rsi + 2*8]
        sbb r9, [rdx + 2*8]
        mov r10, [rsi + 3*8]
        sbb r10, [rdx + 3*8]
        mov r11, [rsi + 4*8]
        sbb r11, [rdx + 4*8]
        mov rbx, [rsi + 5*8]
        sbb rbx, [rdx + 5*8]
        mov rsi, 0
        cmovb rsi, [rdi + 0*8]
        mov rdx, 0
        cmovb rdx, [rdi + 1*8]
        mov rbp, 0
        cmovb rbp, [rdi + 2*8]
        mov r12, 0
        cmovb r12, [rdi + 3*8]
        mov r13, 0
        cmovb r13, [rdi + 4*8]
        mov rdi, [rdi + 5*8]
        cmovnb rdi, rsi
        add rax, rsi
        adc r8, rdx
        adc r9, rbp
        adc r10, r12
        adc r11, r13
        adc rbx, rdi
        mov [rcx + 0*8], rax
        mov [rcx + 1*8], r8
        mov [rcx + 2*8], r9
        mov [rcx + 3*8], r10
        mov [rcx + 4*8], r11
        mov [rcx + 5*8], rbx
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefModMulMontgomery256Asm: .global SymCryptFdefModMulMontgomery256Asm
.type SymCryptFdefModMulMontgomery256Asm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
mov r10, rdx
        mov r8, [rsi]
        xor rbx, rbx
        xor rbp, rbp
        xor r12, r12
        mov rax, [r10]
        mul r8
        mov r9, rax
        mov r11, rdx
        mov rax, [r10 + 8]
        mul r8
        add r11, rax
        adc rbx, rdx
        mov rax, [r10 + 16]
        mul r8
        add rbx, rax
        adc rbp, rdx
        mov rax, [r10 + 24]
        mul r8
        add rbp, rax
        adc r12, rdx
        mov r8, [rsi + 8]
        MUL14 rax, rdx, r8, r10, r11, rbx, rbp, r12, r15
        mov r13, rdx
        mov r8, [rsi + 16]
        MUL14 rax, rdx, r8, r10, rbx, rbp, r12, r13, r15
        mov r14, rdx
        mov r8, [rsi + 24]
        MUL14 rax, rdx, r8, r10, rbp, r12, r13, r14, r15
        mov r15, rdx
SymCryptFdefMontgomeryReduce256AsmInternal: .global SymCryptFdefMontgomeryReduce256AsmInternal
        mov r10, [rdi + SymCryptModulusInv64OffsetAmd64]
        add rdi, SymCryptModulusValueOffsetAmd64
        mov r8, r9
        imul r8, r10
        MONTGOMERY14 rax, rdx, r8, rdi, r9, r11, rbx, rbp, r9
        mov r9, rdx
        mov r8, r11
        imul r8, r10
        MONTGOMERY14 rax, rdx, r8, rdi, r11, rbx, rbp, r12, r11
        mov r11, rdx
        mov r8, rbx
        imul r8, r10
        MONTGOMERY14 rax, rdx, r8, rdi, rbx, rbp, r12, r13, rbx
        mov rbx, rdx
        mov r8, rbp
        imul r8, r10
        MONTGOMERY14 rax, rdx, r8, rdi, rbp, r12, r13, r14, rbp
        add r12, r9
        adc r13, r11
        adc r14, rbx
        adc r15, rdx
        sbb r8, r8
        mov r9, r12
        sub r9, [rdi]
        mov r11, r13
        sbb r11, [rdi + 8]
        mov rbx, r14
        sbb rbx, [rdi + 16]
        mov rbp, r15
        sbb rbp, [rdi + 24]
        sbb rdi, rdi
        xor rdi, r8
        cmovz r12, r9
        cmovz r13, r11
        cmovz r14, rbx
        cmovz r15, rbp
        mov [rcx + 0], r12
        mov [rcx + 8], r13
        mov [rcx + 16], r14
        mov [rcx + 24], r15
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefMontgomeryReduce256Asm: .global SymCryptFdefMontgomeryReduce256Asm
.type SymCryptFdefMontgomeryReduce256Asm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
mov r10, rdx
        mov rcx, r10
        mov r9, [rsi + 0]
        mov r11, [rsi + 8]
        mov rbx, [rsi + 16]
        mov rbp, [rsi + 24]
        mov r12, [rsi + 32]
        mov r13, [rsi + 40]
        mov r14, [rsi + 48]
        mov r15, [rsi + 56]
        test rsp,rsp
        jne SymCryptFdefMontgomeryReduce256AsmInternal
        int 3
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
