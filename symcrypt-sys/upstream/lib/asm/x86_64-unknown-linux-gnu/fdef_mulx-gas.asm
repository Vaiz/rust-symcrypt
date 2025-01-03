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

.macro ZEROREG R
        xor \R,\R
.endm
.macro ZEROREG_8 R0, R1, R2, R3, R4, R5, R6, R7
    ZEROREG \R0
    ZEROREG \R1
    ZEROREG \R2
    ZEROREG \R3
    ZEROREG \R4
    ZEROREG \R5
    ZEROREG \R6
    ZEROREG \R7
.endm
.macro MULADD18 R0, R1, R2, R3, R4, R5, R6, R7, pD, pA, pB, T0, T1, QH
    xor \T0, \T0
    mov \QH, [\pB]
    adox \R0, [\pD]
    mulx \T1, \T0, [\pA + 0 * 8]
    adcx \R0, \T0
    adox \R1, \T1
    mov [\pD], \R0
    mulx \T1, \T0, [\pA + 1 * 8]
    adcx \R1, \T0
    adox \R2, \T1
    mulx \T1, \T0, [\pA + 2 * 8]
    adcx \R2, \T0
    adox \R3, \T1
    mulx \T1, \T0, [\pA + 3 * 8]
    adcx \R3, \T0
    adox \R4, \T1
    mulx \T1, \T0, [\pA + 4 * 8]
    adcx \R4, \T0
    adox \R5, \T1
    mulx \T1, \T0, [\pA + 5 * 8]
    adcx \R5, \T0
    adox \R6, \T1
    mulx \T1, \T0, [\pA + 6 * 8]
    adcx \R6, \T0
    adox \R7, \T1
    mulx \T1, \T0, [\pA + 7 * 8]
    adcx \R7, \T0
    mov \R0, 0
    adox \R0, \R0
    adcx \R0, \T1
.endm
.macro MULADD88 R0, R1, R2, R3, R4, R5, R6, R7, pD, pA, pB, T0, T1, QH
    MULADD18 \R0, \R1, \R2, \R3, \R4, \R5, \R6, \R7, \pD , \pA, \pB , \T0, \T1, \QH
    MULADD18 \R1, \R2, \R3, \R4, \R5, \R6, \R7, \R0, \pD + 8, \pA, \pB + 8, \T0, \T1, \QH
    MULADD18 \R2, \R3, \R4, \R5, \R6, \R7, \R0, \R1, \pD + 16, \pA, \pB + 16, \T0, \T1, \QH
    MULADD18 \R3, \R4, \R5, \R6, \R7, \R0, \R1, \R2, \pD + 24, \pA, \pB + 24, \T0, \T1, \QH
    MULADD18 \R4, \R5, \R6, \R7, \R0, \R1, \R2, \R3, \pD + 32, \pA, \pB + 32, \T0, \T1, \QH
    MULADD18 \R5, \R6, \R7, \R0, \R1, \R2, \R3, \R4, \pD + 40, \pA, \pB + 40, \T0, \T1, \QH
    MULADD18 \R6, \R7, \R0, \R1, \R2, \R3, \R4, \R5, \pD + 48, \pA, \pB + 48, \T0, \T1, \QH
    MULADD18 \R7, \R0, \R1, \R2, \R3, \R4, \R5, \R6, \pD + 56, \pA, \pB + 56, \T0, \T1, \QH
.endm
.macro HALF_SQUARE_NODIAG8 R0, R1, R2, R3, R4, R5, R6, R7, pD, pA, T0, T1, QH
    mov \QH, [\pA + 0 * 8]
    mov \R1, [\pD + 1 * 8]
    mov \R2, [\pD + 2 * 8]
    mov \R3, [\pD + 3 * 8]
    mov \R4, [\pD + 4 * 8]
    mov \R5, [\pD + 5 * 8]
    mov \R6, [\pD + 6 * 8]
    mov \R7, [\pD + 7 * 8]
    xor \R0, \R0
    mulx \T1, \T0, [\pA + 1 * 8]
    adcx \R1, \T0
    adox \R2, \T1
    mulx \T1, \T0, [\pA + 2 * 8]
    adcx \R2, \T0
    adox \R3, \T1
    mulx \T1, \T0, [\pA + 3 * 8]
    adcx \R3, \T0
    adox \R4, \T1
    mulx \T1, \T0, [\pA + 4 * 8]
    adcx \R4, \T0
    adox \R5, \T1
    mulx \T1, \T0, [\pA + 5 * 8]
    adcx \R5, \T0
    adox \R6, \T1
    mulx \T1, \T0, [\pA + 6 * 8]
    adcx \R6, \T0
    adox \R7, \T1
    mulx \T1, \T0, [\pA + 7 * 8]
    adcx \R7, \T0
    mov [\pD + 1 * 8], \R1
    adox \R0, \R0
    adcx \R0, \T1
    mov [\pD + 2 * 8], \R2
    mov \QH, [\pA + 1 * 8]
    xor \T0, \T0
    mulx \T1, \T0, [\pA + 2 * 8]
    adcx \R3, \T0
    adox \R4, \T1
    mulx \T1, \T0, [\pA + 3 * 8]
    adcx \R4, \T0
    adox \R5, \T1
    mulx \T1, \T0, [\pA + 4 * 8]
    adcx \R5, \T0
    adox \R6, \T1
    mulx \T1, \T0, [\pA + 5 * 8]
    adcx \R6, \T0
    adox \R7, \T1
    mulx \T1, \T0, [\pA + 6 * 8]
    adcx \R7, \T0
    adox \R0, \T1
    mov \QH, [\pA + 7 * 8]
    mov \R1, 0
    mov \R2, 0
    mov [\pD + 3 * 8], \R3
    mulx \T1, \T0, [\pA + 1 * 8]
    adcx \R0, \T0
    adox \R1, \T1
    mulx \T1, \T0, [\pA + 2 * 8]
    adcx \R1, \T0
    mov [\pD + 4 * 8], \R4
    adcx \R2, \T1
    mov \QH, [\pA + 2 * 8]
    xor \T0, \T0
    mulx \T1, \T0, [\pA + 3 * 8]
    adcx \R5, \T0
    adox \R6, \T1
    mulx \T1, \T0, [\pA + 4 * 8]
    adcx \R6, \T0
    adox \R7, \T1
    mulx \T1, \T0, [\pA + 5 * 8]
    adcx \R7, \T0
    adox \R0, \T1
    mulx \T1, \T0, [\pA + 6 * 8]
    adcx \R0, \T0
    adox \R1, \T1
    mov \QH, [\pA + 4 * 8]
    mov \R3, 0
    mov \R4, 0
    mulx \T1, \T0, [\pA + 5 * 8]
    adcx \R1, \T0
    adox \R2, \T1
    mulx \T1,\T0, [\pA + 6 * 8]
    adcx \R2, \T0
    adox \R3, \T1
    mov \QH, [\pA + 5 * 8]
    mov [\pD + 5 * 8], \R5
    mulx \T1, \T0, [\pA + 6 * 8]
    adcx \R3, \T0
    adcx \R4, \T1
    mov \QH, [\pA + 3 * 8]
    mov [\pD + 6 * 8], \R6
    xor \T0, \T0
    mulx \T1, \T0, [\pA + 4 * 8]
    adcx \R7, \T0
    adox \R0, \T1
    mulx \T1, \T0, [\pA + 5 * 8]
    adcx \R0, \T0
    adox \R1, \T1
    mulx \T1, \T0, [\pA + 6 * 8]
    adcx \R1, \T0
    adox \R2, \T1
    mulx \T1, \T0, [\pA + 7 * 8]
    adcx \R2, \T0
    adox \R3, \T1
    mov \QH, [\pA + 7 * 8]
    mov \R5, 0
    mov \R6, 0
    mov [\pD + 7 * 8], \R7
    mulx \T1, \T0, [\pA + 4 * 8]
    adcx \R3, \T0
    adox \R4, \T1
    mulx \T1, \T0, [\pA + 5 * 8]
    adcx \R4, \T0
    adox \R5, \T1
    mulx \T1, \T0, [\pA + 6 * 8]
    adcx \R5, \T0
    adcx \R6, \T1
    xor \R7, \R7
.endm
.macro MONTGOMERY18 R0, R1, R2, R3, R4, R5, R6, R7, modInv, pMod, pMont, T0, T1, QH
    mov \QH, \R0
    imul \QH, \modInv
    or \T0, -1
    adcx \R0, \T0
    mov \R0, 0
    mov [\pMont], \QH
    mulx \T1, \T1, [\pMod + 0 * 8]
    adox \R1, \T1
    mulx \T1, \T0, [\pMod + 1 * 8]
    adcx \R1, \T0
    adox \R2, \T1
    mulx \T1, \T0, [\pMod + 2 * 8]
    adcx \R2, \T0
    adox \R3, \T1
    mulx \T1, \T0, [\pMod + 3 * 8]
    adcx \R3, \T0
    adox \R4, \T1
    mulx \T1, \T0, [\pMod + 4 * 8]
    adcx \R4, \T0
    adox \R5, \T1
    mulx \T1, \T0, [\pMod + 5 * 8]
    adcx \R5, \T0
    adox \R6, \T1
    mulx \T1, \T0, [\pMod + 6 * 8]
    adcx \R6, \T0
    adox \R7, \T1
    mulx \T1, \T0, [\pMod + 7 * 8]
    adcx \R7, \T0
    adcx \R0, \R0
    adox \R0, \T1
.endm
.macro SYMCRYPT_SQUARE_DIAG index, src_reg, dest_reg, T0, T1, T2, T3, QH
    mov \QH, [\src_reg + 8 * \index]
    mov \T0, [\dest_reg + 16 * \index]
    mov \T1, [\dest_reg + 16 * \index + 8]
    mulx \T3, \T2, \QH
    adcx \T2, \T0
    adox \T2, \T0
    adcx \T3, \T1
    adox \T3, \T1
    mov [\dest_reg + 16 * \index], \T2
    mov [\dest_reg + 16 * \index + 8], \T3
.endm
SymCryptFdefRawMulMulx: .global SymCryptFdefRawMulMulx
.type SymCryptFdefRawMulMulx, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
mov r10, rdx
        shl rcx, 6
        mov [rsp + -8 ], rcx
        mov [rsp + -16 ], esi
        mov r9, r8
        xorps xmm0,xmm0
        mov rax, rcx
SymCryptFdefRawMulMulxWipeLoop:
        movaps [r9],xmm0
        movaps [r9+16],xmm0
        movaps [r9+32],xmm0
        movaps [r9+48],xmm0
        add r9, 64
        sub rax, 64
        jnz SymCryptFdefRawMulMulxWipeLoop
SymCryptFdefRawMulxOuterLoop:
        ZEROREG_8 r9, r11, rbx, rbp, r12, r13, r14, r15
SymCryptFdefRawMulMulxInnerLoop:
        MULADD88 r9, r11, rbx, rbp, r12, r13, r14, r15, r8, rdi, r10, rax, rsi, rdx
        add r10, 64
        add r8, 64
        sub ecx, 64
        jnz SymCryptFdefRawMulMulxInnerLoop
        mov [r8 + 0*8], r9
        mov [r8 + 1*8], r11
        mov [r8 + 2*8], rbx
        mov [r8 + 3*8], rbp
        mov [r8 + 4*8], r12
        mov [r8 + 5*8], r13
        mov [r8 + 6*8], r14
        mov [r8 + 7*8], r15
        mov rcx, [rsp + -8 ]
        sub r8, rcx
        add r8, 64
        sub r10, rcx
        add rdi, 64
        mov esi, [rsp + -16 ]
        sub esi, 1
        mov [rsp + -16 ], esi
        jnz SymCryptFdefRawMulxOuterLoop
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefRawSquareMulx: .global SymCryptFdefRawSquareMulx
.type SymCryptFdefRawSquareMulx, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
mov r10, rdx
        mov [rsp + -8 ], rdi
        mov [rsp + -16 ], rsi
        mov [rsp + -24 ], r10
        shl rsi, 6
        mov [rsp + -32 ], rsi
        xor rax, rax
        mov r8, r10
        mov rcx, rsi
SymCryptFdefRawSquareMulxWipeLoop:
        mov [r8 ], rax
        mov [r8 + 8], rax
        mov [r8 + 16], rax
        mov [r8 + 24], rax
        mov [r8 + 32], rax
        mov [r8 + 40], rax
        mov [r8 + 48], rax
        mov [r8 + 56], rax
        add r8, 64
        sub rcx, 64
        jnz SymCryptFdefRawSquareMulxWipeLoop
SymCryptFdefRawSquareMulxOuterLoop:
        HALF_SQUARE_NODIAG8 r9, r11, rbx, rbp, r12, r13, r14, r15, r10, rdi, rax, rcx, rdx
        sub rsi, 64
        jz SymCryptFdefRawSquareMulxPhase2
        lea r8, [rdi + 64]
        lea r10, [r10 + 64]
SymCryptFdefRawSquareMulxInnerLoop:
        MULADD88 r9, r11, rbx, rbp, r12, r13, r14, r15, r10, rdi, r8, rax, rcx, rdx
        add r10, 64
        add r8, 64
        sub rsi, 64
        jnz SymCryptFdefRawSquareMulxInnerLoop
        mov [r10 + 0*8], r9
        mov [r10 + 1*8], r11
        mov [r10 + 2*8], rbx
        mov [r10 + 3*8], rbp
        mov [r10 + 4*8], r12
        mov [r10 + 5*8], r13
        mov [r10 + 6*8], r14
        mov [r10 + 7*8], r15
        mov rsi, [rsp + -32 ]
        add rdi, 64
        sub r10, rsi
        add r10, 128
        sub rsi, 64
        mov [rsp + -32 ], rsi
        jmp SymCryptFdefRawSquareMulxOuterLoop
SymCryptFdefRawSquareMulxPhase2:
        mov [r10 + 8*8], r9
        mov [r10 + 9*8], r11
        mov [r10 + 10*8], rbx
        mov [r10 + 11*8], rbp
        mov [r10 + 12*8], r12
        mov [r10 + 13*8], r13
        mov [r10 + 14*8], r14
        mov [r10 + 15*8], r15
        mov rdi, [rsp + -8 ]
        mov rsi, [rsp + -16 ]
        mov r10, [rsp + -24 ]
        xor rax, rax
        xor rcx, rcx
SymCryptFdefRawSquareMulxDiagonalsLoop:
        mov rdx, [rdi]
        mov r8, [r10]
        mov r9, [r10 + 8]
        mulx rbx, r11, rdx
        adcx r11, rax
        adcx rbx, rcx
        adcx r11, r8
        adox r11, r8
        adcx rbx, r9
        adox rbx, r9
        mov [r10], r11
        mov [r10 + 8], rbx
        SYMCRYPT_SQUARE_DIAG 1, rdi, r10, r8, r9, r11, rbx, rdx
        SYMCRYPT_SQUARE_DIAG 2, rdi, r10, r8, r9, r11, rbx, rdx
        SYMCRYPT_SQUARE_DIAG 3, rdi, r10, r8, r9, r11, rbx, rdx
        SYMCRYPT_SQUARE_DIAG 4, rdi, r10, r8, r9, r11, rbx, rdx
        SYMCRYPT_SQUARE_DIAG 5, rdi, r10, r8, r9, r11, rbx, rdx
        SYMCRYPT_SQUARE_DIAG 6, rdi, r10, r8, r9, r11, rbx, rdx
        SYMCRYPT_SQUARE_DIAG 7, rdi, r10, r8, r9, r11, rbx, rdx
        mov eax, ecx
        adox eax, ecx
        lea rdi, [rdi + 64]
        lea r10, [r10 + 128]
        dec rsi
        jnz SymCryptFdefRawSquareMulxDiagonalsLoop
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefMontgomeryReduceMulx: .global SymCryptFdefMontgomeryReduceMulx
.type SymCryptFdefMontgomeryReduceMulx, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
mov r10, rdx
        mov [rsp + -8 ], rdi
        mov [rsp + -16 ], rsi
        mov [rsp + -24 ], r10
        mov eax, [rdi + SymCryptModulusNdigitsOffsetAmd64]
        mov [rsp + -32 ], eax
        xor ecx, ecx
        mov [rsp + -32 + 4], ecx
SymCryptFdefMontgomeryReduceMulxOuterLoop:
        mov r9, [rsi + 0 * 8]
        mov r11, [rsi + 1 * 8]
        mov rbx, [rsi + 2 * 8]
        mov rbp, [rsi + 3 * 8]
        mov r12, [rsi + 4 * 8]
        mov r13, [rsi + 5 * 8]
        mov r14, [rsi + 6 * 8]
        mov r15, [rsi + 7 * 8]
        mov r10, [rdi + SymCryptModulusInv64OffsetAmd64]
        mov ecx, [rdi + SymCryptModulusNdigitsOffsetAmd64]
        lea rdi, [rdi + SymCryptModulusValueOffsetAmd64]
        MONTGOMERY18 r9, r11, rbx, rbp, r12, r13, r14, r15, r10, rdi, rsi + (0 * 8), rax, r8, rdx
        MONTGOMERY18 r11, rbx, rbp, r12, r13, r14, r15, r9, r10, rdi, rsi + (1 * 8), rax, r8, rdx
        MONTGOMERY18 rbx, rbp, r12, r13, r14, r15, r9, r11, r10, rdi, rsi + (2 * 8), rax, r8, rdx
        MONTGOMERY18 rbp, r12, r13, r14, r15, r9, r11, rbx, r10, rdi, rsi + (3 * 8), rax, r8, rdx
        MONTGOMERY18 r12, r13, r14, r15, r9, r11, rbx, rbp, r10, rdi, rsi + (4 * 8), rax, r8, rdx
        MONTGOMERY18 r13, r14, r15, r9, r11, rbx, rbp, r12, r10, rdi, rsi + (5 * 8), rax, r8, rdx
        MONTGOMERY18 r14, r15, r9, r11, rbx, rbp, r12, r13, r10, rdi, rsi + (6 * 8), rax, r8, rdx
        MONTGOMERY18 r15, r9, r11, rbx, rbp, r12, r13, r14, r10, rdi, rsi + (7 * 8), rax, r8, rdx
        mov r10, rsi
        add rdi, 64
        add rsi, 64
        dec ecx
        jz SymCryptFdefMontgomeryReduceMulxInnerLoopDone
SymCryptFdefMontgomeryReduceMulxInnerLoop:
        MULADD88 r9, r11, rbx, rbp, r12, r13, r14, r15, rsi, rdi, r10, rax, r8, rdx
        add rdi, 64
        add rsi, 64
        dec ecx
        jnz SymCryptFdefMontgomeryReduceMulxInnerLoop
SymCryptFdefMontgomeryReduceMulxInnerLoopDone:
        mov r8d, [rsp + -32 + 4]
        neg r8d
        mov rax, [rsi + 0 * 8]
        adc rax, r9
        mov [rsi + 0 * 8], rax
        mov r8, [rsi + 1 * 8]
        adc r8, r11
        mov [rsi + 1 * 8], r8
        mov rax, [rsi + 2 * 8]
        adc rax, rbx
        mov [rsi + 2 * 8], rax
        mov r8, [rsi + 3 * 8]
        adc r8, rbp
        mov [rsi + 3 * 8], r8
        mov rax, [rsi + 4 * 8]
        adc rax, r12
        mov [rsi + 4 * 8], rax
        mov r8, [rsi + 5 * 8]
        adc r8, r13
        mov [rsi + 5 * 8], r8
        mov rax, [rsi + 6 * 8]
        adc rax, r14
        mov [rsi + 6 * 8], rax
        mov r8, [rsi + 7 * 8]
        adc r8, r15
        mov [rsi + 7 * 8], r8
        adc ecx, ecx
        mov [rsp + -32 + 4], ecx
        mov rsi, [rsp + -16 ]
        add rsi, 64
        mov [rsp + -16 ], rsi
        mov rdi, [rsp + -8 ]
        mov eax, [rsp + -32 ]
        dec eax
        mov [rsp + -32 ], eax
        jnz SymCryptFdefMontgomeryReduceMulxOuterLoop
        mov r9d, [rdi + SymCryptModulusNdigitsOffsetAmd64]
        lea rdi, [rdi + SymCryptModulusValueOffsetAmd64]
        mov r10, [rsp + -24 ]
        mov r11d, r9d
        mov rbx, rsi
        mov rbp, r10
SymCryptFdefMontgomeryReduceMulxSubLoop:
        mov rax,[rsi + 0 * 8]
        sbb rax,[rdi + 0 * 8]
        mov [r10 + 0 * 8], rax
        mov r8,[rsi + 1 * 8]
        sbb r8,[rdi + 1 * 8]
        mov [r10 + 1 * 8], r8
        mov rax,[rsi + 2 * 8]
        sbb rax,[rdi + 2 * 8]
        mov [r10 + 2 * 8], rax
        mov r8,[rsi + 3 * 8]
        sbb r8,[rdi + 3 * 8]
        mov [r10 + 3 * 8], r8
        mov rax,[rsi + 4 * 8]
        sbb rax,[rdi + 4 * 8]
        mov [r10 + 4 * 8], rax
        mov r8,[rsi + 5 * 8]
        sbb r8,[rdi + 5 * 8]
        mov [r10 + 5 * 8], r8
        mov rax,[rsi + 6 * 8]
        sbb rax,[rdi + 6 * 8]
        mov [r10 + 6 * 8], rax
        mov r8,[rsi + 7 * 8]
        sbb r8,[rdi + 7 * 8]
        mov [r10 + 7 * 8], r8
        lea rsi, [rsi + 64]
        lea rdi, [rdi + 64]
        lea r10, [r10 + 64]
        dec r9d
        jnz SymCryptFdefMontgomeryReduceMulxSubLoop
        sbb ecx, 0
        movd xmm0, ecx
        pcmpeqd xmm1, xmm1
        pshufd xmm0, xmm0, 0
        pxor xmm1, xmm0
SymCryptFdefMontgomeryReduceMulxMaskedCopyLoop:
        movdqa xmm2, [rbx + 0 * 16]
        movdqa xmm3, [rbp + 0 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [rbp + 0 * 16], xmm2
        movdqa xmm2, [rbx + 1 * 16]
        movdqa xmm3, [rbp + 1 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [rbp + 1 * 16], xmm2
        movdqa xmm2, [rbx + 2 * 16]
        movdqa xmm3, [rbp + 2 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [rbp + 2 * 16], xmm2
        movdqa xmm2, [rbx + 3 * 16]
        movdqa xmm3, [rbp + 3 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [rbp + 3 * 16], xmm2
        add rbx, 64
        add rbp, 64
        dec r11d
        jnz SymCryptFdefMontgomeryReduceMulxMaskedCopyLoop
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
.macro MULADD_LOADSTORE18 pS, pM, pD, rdx, Tc, T0, T1
    xor \T0, \T0
    mulx \T1, \T0, [\pM + 0 * 8]
    adox \T0, \Tc
    adcx \T0, [\pS + 0 * 8]
    mov [\pD + 0 * 8], \T0
    mulx \Tc, \T0, [\pM + 1 * 8]
    adox \T0, \T1
    adcx \T0, [\pS + 1 * 8]
    mov [\pD + 1 * 8], \T0
    mulx \T1, \T0, [\pM + 2 * 8]
    adox \T0, \Tc
    adcx \T0, [\pS + 2 * 8]
    mov [\pD + 2 * 8], \T0
    mulx \Tc, \T0, [\pM + 3 * 8]
    adox \T0, \T1
    adcx \T0, [\pS + 3 * 8]
    mov [\pD + 3 * 8], \T0
    mulx \T1, \T0, [\pM + 4 * 8]
    adox \T0, \Tc
    adcx \T0, [\pS + 4 * 8]
    mov [\pD + 4 * 8], \T0
    mulx \Tc, \T0, [\pM + 5 * 8]
    adox \T0, \T1
    adcx \T0, [\pS + 5 * 8]
    mov [\pD + 5 * 8], \T0
    mulx \T1, \T0, [\pM + 6 * 8]
    adox \T0, \Tc
    adcx \T0, [\pS + 6 * 8]
    mov [\pD + 6 * 8], \T0
    mulx \Tc, \T0, [\pM + 7 * 8]
    adox \T0, \T1
    adcx \T0, [\pS + 7 * 8]
    mov [\pD + 7 * 8], \T0
    mov \T1, 0
    adox \Tc, \T1
    adcx \Tc, \T1
.endm
.macro SHIFTRIGHT2 pD, index, shrVal, shrMask, shlVal, Tc, T0, T1
    mov \T0, [\pD + ((\index+1)*8)]
    shrx \T1, \T0, \shrVal
    shlx \Tc, \Tc, \shlVal
    and \T1, \shrMask
    or \T1, \Tc
    mov [\pD + ((\index+1)*8)], \T1
    mov \Tc, [\pD + (\index*8)]
    shrx \T1, \Tc, \shrVal
    shlx \T0, \T0, \shlVal
    and \T1, \shrMask
    or \T1, \T0
    mov [\pD + (\index*8)], \T1
.endm
SymCryptFdefModDivSmallPow2Mulx: .global SymCryptFdefModDivSmallPow2Mulx
.type SymCryptFdefModDivSmallPow2Mulx, %function
push rbx
mov r10, rdx
        mov r11, [rsi]
        mov rdx, [rdi + SymCryptModulusInv64OffsetAmd64]
        imul rdx, r11
        xor eax, eax
        mov r11, -1
        sub eax, r10d
        shrx r11, r11, rax
        and rdx, r11
        mov eax, [rdi + SymCryptModulusNdigitsOffsetAmd64]
        lea r8, [rdi + SymCryptModulusValueOffsetAmd64]
        xor r9, r9
SymCryptFdefModDivSmallPow2MulxMulAddLoop:
        MULADD_LOADSTORE18 rsi, r8, rcx, rdx, r9, r11, rbx
        add rsi, 64
        add r8, 64
        add rcx, 64
        dec eax
        jnz SymCryptFdefModDivSmallPow2MulxMulAddLoop
        mov eax, [rdi + SymCryptModulusNdigitsOffsetAmd64]
        mov edi, 64
        xor r11, r11
        sub edi, r10d
        mov rsi, -1
        cmovz rsi, r11
        sub rcx, 64
SymCryptFdefModDivSmallPow2MulxShiftRightLoop:
        SHIFTRIGHT2 rcx, 6, r10, rsi, rdi, r9, r11, rbx
        SHIFTRIGHT2 rcx, 4, r10, rsi, rdi, r9, r11, rbx
        SHIFTRIGHT2 rcx, 2, r10, rsi, rdi, r9, r11, rbx
        SHIFTRIGHT2 rcx, 0, r10, rsi, rdi, r9, r11, rbx
        sub rcx, 64
        dec eax
        jnz SymCryptFdefModDivSmallPow2MulxShiftRightLoop
pop rbx
ret
SymCryptFdefModAddMulx256Asm: .global SymCryptFdefModAddMulx256Asm
.type SymCryptFdefModAddMulx256Asm, %function
        add rdi, SymCryptNegDivisorSingleDigitOffsetAmd64
        xor rax, rax
        mov rax, [rsi + 0*8]
        adcx rax, [rdx + 0*8]
        mov r8, [rsi + 1*8]
        adcx r8, [rdx + 1*8]
        mov r9, [rsi + 2*8]
        adcx r9, [rdx + 2*8]
        mov rsi, [rsi + 3*8]
        adcx rsi, [rdx + 3*8]
        mov r10, [rdi + 0*8]
        adox r10, rax
        mov r11, [rdi + 1*8]
        adox r11, r8
        mov rdx, [rdi + 2*8]
        adox rdx, r9
        mov rdi, [rdi + 3*8]
        adox rdi, rsi
        cmovc rax, r10
        cmovc r8, r11
        cmovc r9, rdx
        cmovc rsi, rdi
        cmovo rax, r10
        cmovo r8, r11
        cmovo r9, rdx
        cmovo rsi, rdi
        mov [rcx + 0*8], rax
        mov [rcx + 1*8], r8
        mov [rcx + 2*8], r9
        mov [rcx + 3*8], rsi
ret
.macro MUL_AND_MONTGOMERY_REDUCE14_INTERLEAVE T0, T1, rdx, pA, Aoff, pB, pM, K, R0, R1, R2, R3, R4, R5
    mov \rdx, [\pA + \Aoff]
    xor \T0, \T0
    mulx \T1, \T0, [\pB + 0*8]
    adox \R1, \T0
    adcx \R2, \T1
    mulx \T1, \T0, [\pB + 1*8]
    adox \R2, \T0
    adcx \R3, \T1
    mulx \T1, \T0, [\pB + 2*8]
    adox \R3, \T0
    adcx \R4, \T1
    mulx \T1, \T0, [\pB + 3*8]
    adox \R4, \T0
    mov \T0, 0
    adcx \T1, \T0
    adox \R5, \T0
    xor \T0, \T0
    mov \rdx, \K
    mulx \K, \T0, [\pM + 0*8]
    adcx \R0, \T0
    adox \R1, \K
    mulx \K, \T0, [\pM + 1*8]
    adcx \R1, \T0
    adox \R2, \K
    mulx \K, \T0, [\pM + 2*8]
    adcx \R2, \T0
    adox \R3, \K
    mulx \K, \T0, [\pM + 3*8]
    adcx \R3, \T0
    adox \R4, \K
    adcx \R4, \R0
    adox \R5, \R0
    adc \R5, \T1
    adc \R0, \R0
    mov \K, \R1
    imul \K, [\pM - SymCryptModulusValueOffsetAmd64 + SymCryptModulusInv64OffsetAmd64]
.endm
SymCryptFdefModMulMontgomeryMulx256Asm: .global SymCryptFdefModMulMontgomeryMulx256Asm
.type SymCryptFdefModMulMontgomeryMulx256Asm, %function
push rbx
push rbp
push r12
push r13
push r14
mov r10, rdx
SymCryptFdefModMulMontgomeryMulx256AsmInternal: .global SymCryptFdefModMulMontgomeryMulx256AsmInternal
        xor r13, r13
        mov rdx, [rsi]
        mulx r11, r9, [r10 + 0*8]
        mulx rbx, rax, [r10 + 1*8]
        adc r11, rax
        mulx rbp, rax, [r10 + 2*8]
        adc rbx, rax
        mulx r12, rax, [r10 + 3*8]
        adc rbp, rax
        adc r12, r13
        mov r14, r9
        imul r14, [rdi + SymCryptModulusInv64OffsetAmd64]
        add rdi, SymCryptModulusValueOffsetAmd64
        MUL_AND_MONTGOMERY_REDUCE14_INTERLEAVE rax, r8, rdx, rsi, 8, r10, rdi, r14, r9, r11, rbx, rbp, r12, r13
        MUL_AND_MONTGOMERY_REDUCE14_INTERLEAVE rax, r8, rdx, rsi, 16, r10, rdi, r14, r11, rbx, rbp, r12, r13, r9
        MUL_AND_MONTGOMERY_REDUCE14_INTERLEAVE rax, r8, rdx, rsi, 24, r10, rdi, r14, rbx, rbp, r12, r13, r9, r11
        xor rax, rax
        mov rdx, r14
        mulx r8, rax, [rdi + 0*8]
        adcx rbp, rax
        adox r12, r8
        mulx r8, rax, [rdi + 1*8]
        adcx r12, rax
        adox r13, r8
        mulx r8, rax, [rdi + 2*8]
        adcx r13, rax
        adox r9, r8
        mulx r8, rax, [rdi + 3*8]
        adcx r9, rax
        adox r11, r8
        mov rax, 0
        adcx r11, rax
        adox rbx, rax
        adc rbx, rax
        add rdi, SymCryptNegDivisorSingleDigitOffsetAmd64 - SymCryptModulusValueOffsetAmd64
        mov rax, [rdi + 0*8]
        add rax, r12
        mov rsi, [rdi + 1*8]
        adc rsi, r13
        mov r10, [rdi + 2*8]
        adc r10, r9
        mov r8, [rdi + 3*8]
        adc r8, r11
        adc rbx, rbx
        cmovnz r12, rax
        cmovnz r13, rsi
        cmovnz r9, r10
        cmovnz r11, r8
        mov [rcx + 0*8], r12
        mov [rcx + 1*8], r13
        mov [rcx + 2*8], r9
        mov [rcx + 3*8], r11
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefModSquareMontgomeryMulx256Asm: .global SymCryptFdefModSquareMontgomeryMulx256Asm
.type SymCryptFdefModSquareMontgomeryMulx256Asm, %function
push rbx
push rbp
push r12
push r13
push r14
mov r10, rdx
        mov rcx, r10
        mov r10, rsi
        test rsp,rsp
        jne SymCryptFdefModMulMontgomeryMulx256AsmInternal
        int 3
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefModAddMulx384Asm: .global SymCryptFdefModAddMulx384Asm
.type SymCryptFdefModAddMulx384Asm, %function
push rbx
push rbp
push r12
push r13
        add rdi, SymCryptNegDivisorSingleDigitOffsetAmd64
        xor rax, rax
        mov rax, [rsi + 0*8]
        adcx rax, [rdx + 0*8]
        mov r8, [rsi + 1*8]
        adcx r8, [rdx + 1*8]
        mov r9, [rsi + 2*8]
        adcx r9, [rdx + 2*8]
        mov r10, [rsi + 3*8]
        adcx r10, [rdx + 3*8]
        mov r11, [rsi + 4*8]
        adcx r11, [rdx + 4*8]
        mov rsi, [rsi + 5*8]
        adcx rsi, [rdx + 5*8]
        mov rbx, [rdi + 0*8]
        adox rbx, rax
        mov rbp, [rdi + 1*8]
        adox rbp, r8
        mov r12, [rdi + 2*8]
        adox r12, r9
        mov r13, [rdi + 3*8]
        adox r13, r10
        mov rdx, [rdi + 4*8]
        adox rdx, r11
        mov rdi, [rdi + 5*8]
        adox rdi, rsi
        cmovc rax, rbx
        cmovc r8, rbp
        cmovc r9, r12
        cmovc r10, r13
        cmovc r11, rdx
        cmovc rsi, rdi
        cmovo rax, rbx
        cmovo r8, rbp
        cmovo r9, r12
        cmovo r10, r13
        cmovo r11, rdx
        cmovo rsi, rdi
        mov [rcx + 0*8], rax
        mov [rcx + 1*8], r8
        mov [rcx + 2*8], r9
        mov [rcx + 3*8], r10
        mov [rcx + 4*8], r11
        mov [rcx + 5*8], rsi
pop r13
pop r12
pop rbp
pop rbx
ret
.macro MUL16_P384 T0, T1, rdx, pA, Aoff, pB, R0, R1, R2, R3, R4, R5, R6, R7
    mov \rdx, [\pA + \Aoff]
    xor \R7, \R7
    mulx \T1, \T0, [\pB + 0*8]
    adcx \R0, \T0
    adox \R1, \T1
    mulx \T1, \T0, [\pB + 1*8]
    adcx \R1, \T0
    adox \R2, \T1
    mulx \T1, \T0, [\pB + 2*8]
    adcx \R2, \T0
    adox \R3, \T1
    mulx \T1, \T0, [\pB + 3*8]
    adcx \R3, \T0
    adox \R4, \T1
    mulx \T1, \T0, [\pB + 4*8]
    adcx \R4, \T0
    adox \R5, \T1
    mulx \T1, \T0, [\pB + 5*8]
    adcx \R5, \T0
    adox \R6, \R7
    adc \R6, \T1
    adc \R7, \R7
.endm
.macro MONT16_P384 T0, T1, rdx, pM, N4, R0, R1, R2, R3, R4, R5, R6, R7
    mov \rdx, \R0
    imul \rdx, [\pM - SymCryptModulusValueOffsetAmd64 + SymCryptModulusInv64OffsetAmd64]
    add \N4, -1
    sbb \R3, \rdx
    sbb \N4, \N4
    xor \T0, \T0
    mulx \T1, \T0, [\pM + 0*8]
    adcx \R0, \T0
    adox \R1, \T1
    mulx \T1, \T0, [\pM + 1*8]
    adcx \R1, \T0
    adox \R2, \T1
    mulx \T1, \T0, [\pM + 2*8]
    adcx \R2, \T0
    adox \R3, \T1
    adcx \R3, \R0
    adox \N4, \R0
    adc \N4, \R0
    add \R6, \rdx
    adc \R7, \R0
.endm
SymCryptFdefModMulMontgomeryMulxP384Asm: .global SymCryptFdefModMulMontgomeryMulxP384Asm
.type SymCryptFdefModMulMontgomeryMulxP384Asm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
mov r10, rdx
SymCryptFdefModMulMontgomeryMulxP384AsmInternal: .global SymCryptFdefModMulMontgomeryMulxP384AsmInternal
        mov [rsp + -8 ], rcx
        xor r15, r15
        mov rdx, [rsi]
        mulx r11, r9, [r10 + 0*8]
        mulx rbx, rax, [r10 + 1*8]
        adc r11, rax
        mulx rbp, rax, [r10 + 2*8]
        adc rbx, rax
        mulx r12, rax, [r10 + 3*8]
        adc rbp, rax
        mulx r13, rax, [r10 + 4*8]
        adc r12, rax
        mulx r14, rax, [r10 + 5*8]
        adc r13, rax
        adc r14, r15
        add rdi, SymCryptModulusValueOffsetAmd64
        xor rcx, rcx
        MONT16_P384 rax, r8, rdx, rdi, rcx, r9, r11, rbx, rbp, r12, r13, r14, r15
        MUL16_P384 rax, r8, rdx, rsi, 8, r10, r11, rbx, rbp, r12, r13, r14, r15, r9
        MONT16_P384 rax, r8, rdx, rdi, rcx, r11, rbx, rbp, r12, r13, r14, r15, r9
        MUL16_P384 rax, r8, rdx, rsi, 16, r10, rbx, rbp, r12, r13, r14, r15, r9, r11
        MONT16_P384 rax, r8, rdx, rdi, rcx, rbx, rbp, r12, r13, r14, r15, r9, r11
        MUL16_P384 rax, r8, rdx, rsi, 24, r10, rbp, r12, r13, r14, r15, r9, r11, rbx
        MONT16_P384 rax, r8, rdx, rdi, rcx, rbp, r12, r13, r14, r15, r9, r11, rbx
        MUL16_P384 rax, r8, rdx, rsi, 32, r10, r12, r13, r14, r15, r9, r11, rbx, rbp
        MONT16_P384 rax, r8, rdx, rdi, rcx, r12, r13, r14, r15, r9, r11, rbx, rbp
        MUL16_P384 rax, r8, rdx, rsi, 40, r10, r13, r14, r15, r9, r11, rbx, rbp, r12
        MONT16_P384 rax, r8, rdx, rdi, rcx, r13, r14, r15, r9, r11, rbx, rbp, r12
        xor rax, rax
        adox r11, rcx
        adox rbx, rcx
        adox rbp, rcx
        adox r12, rcx
        mov rsi, [rdi + SymCryptNegDivisorSingleDigitOffsetAmd64 - SymCryptModulusValueOffsetAmd64 + 0*8]
        add rsi, r14
        mov r10, [rdi + 0*8]
        adc r10, r15
        mov r8, 1
        adc r8, r9
        mov rdi, rax
        adc rax, r11
        adc rdi, rbx
        adc r13, rbp
        adc r12, r12
        cmovnz r14, rsi
        cmovnz r15, r10
        cmovnz r9, r8
        cmovnz r11, rax
        cmovnz rbx, rdi
        cmovnz rbp, r13
        mov rcx, [rsp + -8 ]
        mov [rcx + 0*8], r14
        mov [rcx + 1*8], r15
        mov [rcx + 2*8], r9
        mov [rcx + 3*8], r11
        mov [rcx + 4*8], rbx
        mov [rcx + 5*8], rbp
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefModSquareMontgomeryMulxP384Asm: .global SymCryptFdefModSquareMontgomeryMulxP384Asm
.type SymCryptFdefModSquareMontgomeryMulxP384Asm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
mov r10, rdx
        mov rcx, r10
        mov r10, rsi
        test rsp,rsp
        jne SymCryptFdefModMulMontgomeryMulxP384AsmInternal
        int 3
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefRawMulMulx1024: .global SymCryptFdefRawMulMulx1024
.type SymCryptFdefRawMulMulx1024, %function
push rbx
push rbp
push r12
push r13
push r14
mov r10, rdx
        xorps xmm0,xmm0
        movaps [rcx],xmm0
        movaps [rcx+16],xmm0
        movaps [rcx+32],xmm0
        movaps [rcx+48],xmm0
        movaps [rcx+64],xmm0
        movaps [rcx+80],xmm0
        movaps [rcx+96],xmm0
        movaps [rcx+112],xmm0
        ZEROREG_8 r8, r9, r11, rbx, rbp, r12, r13, r14
        MULADD88 r8, r9, r11, rbx, rbp, r12, r13, r14, rcx, rdi, rsi, rax, r10, rdx
        add rsi, 64
        add rcx, 64
        xor rax, rax
        MULADD88 r8, r9, r11, rbx, rbp, r12, r13, r14, rcx, rdi, rsi, rax, r10, rdx
        add rcx, 64
        mov [rcx + 0*8], r8
        mov [rcx + 1*8], r9
        mov [rcx + 2*8], r11
        mov [rcx + 3*8], rbx
        mov [rcx + 4*8], rbp
        mov [rcx + 5*8], r12
        mov [rcx + 6*8], r13
        mov [rcx + 7*8], r14
        sub rcx, 64
        sub rsi, 64
        add rdi, 64
        ZEROREG_8 r8, r9, r11, rbx, rbp, r12, r13, r14
        MULADD88 r8, r9, r11, rbx, rbp, r12, r13, r14, rcx, rdi, rsi, rax, r10, rdx
        add rsi, 64
        add rcx, 64
        xor rax, rax
        MULADD88 r8, r9, r11, rbx, rbp, r12, r13, r14, rcx, rdi, rsi, rax, r10, rdx
        add rcx, 64
        mov [rcx + 0*8], r8
        mov [rcx + 1*8], r9
        mov [rcx + 2*8], r11
        mov [rcx + 3*8], rbx
        mov [rcx + 4*8], rbp
        mov [rcx + 5*8], r12
        mov [rcx + 6*8], r13
        mov [rcx + 7*8], r14
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefRawSquareMulx1024: .global SymCryptFdefRawSquareMulx1024
.type SymCryptFdefRawSquareMulx1024, %function
push rbx
push rbp
push r12
push r13
push r14
mov r10, rdx
        xorps xmm0,xmm0
        movaps [r10],xmm0
        movaps [r10+16],xmm0
        movaps [r10+32],xmm0
        movaps [r10+48],xmm0
        movaps [r10+64],xmm0
        movaps [r10+80],xmm0
        movaps [r10+96],xmm0
        movaps [r10+112],xmm0
        xor rax, rax
        HALF_SQUARE_NODIAG8 r8, r9, r11, rbx, rbp, r12, r13, r14, r10, rdi, rax, rsi, rdx
        lea rcx, [rdi + 64]
        lea r10, [r10 + 64]
        MULADD88 r8, r9, r11, rbx, rbp, r12, r13, r14, r10, rdi, rcx, rax, rsi, rdx
        add r10, 64
        mov [r10 + 0*8], r8
        mov [r10 + 1*8], r9
        mov [r10 + 2*8], r11
        mov [r10 + 3*8], rbx
        mov [r10 + 4*8], rbp
        mov [r10 + 5*8], r12
        mov [r10 + 6*8], r13
        mov [r10 + 7*8], r14
        xor rax, rax
        HALF_SQUARE_NODIAG8 r8, r9, r11, rbx, rbp, r12, r13, r14, r10, rcx, rax, rsi, rdx
        mov [r10 + 8*8], r8
        mov [r10 + 9*8], r9
        mov [r10 + 10*8], r11
        mov [r10 + 11*8], rbx
        mov [r10 + 12*8], rbp
        mov [r10 + 13*8], r12
        mov [r10 + 14*8], r13
        mov [r10 + 15*8], r14
        sub r10, 128
        SYMCRYPT_SQUARE_DIAG 0, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 1, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 2, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 3, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 4, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 5, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 6, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 7, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 8, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 9, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 10, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 11, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 12, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 13, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 14, rdi, r10, rax, rsi, rcx, r8, rdx
        SYMCRYPT_SQUARE_DIAG 15, rdi, r10, rax, rsi, rcx, r8, rdx
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptFdefMontgomeryReduceMulx1024: .global SymCryptFdefMontgomeryReduceMulx1024
.type SymCryptFdefMontgomeryReduceMulx1024, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
mov r10, rdx
        mov [rsp + -8 ], r10
        mov eax, 2
        mov [rsp + -16 ], eax
        xor ecx, ecx
        lea rdi, [rdi + SymCryptModulusValueOffsetAmd64]
SymCryptFdefMontgomeryReduceMulx1024OuterLoop:
        mov r9, [rsi + 0 * 8]
        mov r11, [rsi + 1 * 8]
        mov rbx, [rsi + 2 * 8]
        mov rbp, [rsi + 3 * 8]
        mov r12, [rsi + 4 * 8]
        mov r13, [rsi + 5 * 8]
        mov r14, [rsi + 6 * 8]
        mov r15, [rsi + 7 * 8]
        mov r10, [rdi - SymCryptModulusValueOffsetAmd64 + SymCryptModulusInv64OffsetAmd64]
        MONTGOMERY18 r9, r11, rbx, rbp, r12, r13, r14, r15, r10, rdi, rsi + (0 * 8), rax, r8, rdx
        MONTGOMERY18 r11, rbx, rbp, r12, r13, r14, r15, r9, r10, rdi, rsi + (1 * 8), rax, r8, rdx
        MONTGOMERY18 rbx, rbp, r12, r13, r14, r15, r9, r11, r10, rdi, rsi + (2 * 8), rax, r8, rdx
        MONTGOMERY18 rbp, r12, r13, r14, r15, r9, r11, rbx, r10, rdi, rsi + (3 * 8), rax, r8, rdx
        MONTGOMERY18 r12, r13, r14, r15, r9, r11, rbx, rbp, r10, rdi, rsi + (4 * 8), rax, r8, rdx
        MONTGOMERY18 r13, r14, r15, r9, r11, rbx, rbp, r12, r10, rdi, rsi + (5 * 8), rax, r8, rdx
        MONTGOMERY18 r14, r15, r9, r11, rbx, rbp, r12, r13, r10, rdi, rsi + (6 * 8), rax, r8, rdx
        MONTGOMERY18 r15, r9, r11, rbx, rbp, r12, r13, r14, r10, rdi, rsi + (7 * 8), rax, r8, rdx
        mov r10, rsi
        add rdi, 64
        add rsi, 64
        MULADD88 r9, r11, rbx, rbp, r12, r13, r14, r15, rsi, rdi, r10, rax, r8, rdx
        add rdi, 64
        add rsi, 64
        neg ecx
        mov ecx, 0
        mov rax, [rsi + 0 * 8]
        adc rax, r9
        mov [rsi + 0 * 8], rax
        mov r8, [rsi + 1 * 8]
        adc r8, r11
        mov [rsi + 1 * 8], r8
        mov rax, [rsi + 2 * 8]
        adc rax, rbx
        mov [rsi + 2 * 8], rax
        mov r8, [rsi + 3 * 8]
        adc r8, rbp
        mov [rsi + 3 * 8], r8
        mov rax, [rsi + 4 * 8]
        adc rax, r12
        mov [rsi + 4 * 8], rax
        mov r8, [rsi + 5 * 8]
        adc r8, r13
        mov [rsi + 5 * 8], r8
        mov rax, [rsi + 6 * 8]
        adc rax, r14
        mov [rsi + 6 * 8], rax
        mov r8, [rsi + 7 * 8]
        adc r8, r15
        mov [rsi + 7 * 8], r8
        adc ecx, ecx
        sub rsi, 64
        sub rdi, 128
        mov eax, [rsp + -16 ]
        sub eax, 1
        mov [rsp + -16 ], eax
        jnz SymCryptFdefMontgomeryReduceMulx1024OuterLoop
        mov r10, [rsp + -8 ]
        mov rax,[rsi + 0 * 8]
        sbb rax,[rdi + 0 * 8]
        mov [r10 + 0 * 8], rax
        mov r8,[rsi + 1 * 8]
        sbb r8,[rdi + 1 * 8]
        mov [r10 + 1 * 8], r8
        mov rax,[rsi + 2 * 8]
        sbb rax,[rdi + 2 * 8]
        mov [r10 + 2 * 8], rax
        mov r8,[rsi + 3 * 8]
        sbb r8,[rdi + 3 * 8]
        mov [r10 + 3 * 8], r8
        mov rax,[rsi + 4 * 8]
        sbb rax,[rdi + 4 * 8]
        mov [r10 + 4 * 8], rax
        mov r8,[rsi + 5 * 8]
        sbb r8,[rdi + 5 * 8]
        mov [r10 + 5 * 8], r8
        mov rax,[rsi + 6 * 8]
        sbb rax,[rdi + 6 * 8]
        mov [r10 + 6 * 8], rax
        mov r8,[rsi + 7 * 8]
        sbb r8,[rdi + 7 * 8]
        mov [r10 + 7 * 8], r8
        mov rax,[rsi + 8 * 8]
        sbb rax,[rdi + 8 * 8]
        mov [r10 + 8 * 8], rax
        mov r8,[rsi + 9 * 8]
        sbb r8,[rdi + 9 * 8]
        mov [r10 + 9 * 8], r8
        mov rax,[rsi + 10 * 8]
        sbb rax,[rdi + 10 * 8]
        mov [r10 + 10 * 8], rax
        mov r8,[rsi + 11 * 8]
        sbb r8,[rdi + 11 * 8]
        mov [r10 + 11 * 8], r8
        mov rax,[rsi + 12 * 8]
        sbb rax,[rdi + 12 * 8]
        mov [r10 + 12 * 8], rax
        mov r8,[rsi + 13 * 8]
        sbb r8,[rdi + 13 * 8]
        mov [r10 + 13 * 8], r8
        mov rax,[rsi + 14 * 8]
        sbb rax,[rdi + 14 * 8]
        mov [r10 + 14 * 8], rax
        mov r8,[rsi + 15 * 8]
        sbb r8,[rdi + 15 * 8]
        mov [r10 + 15 * 8], r8
        sbb ecx, 0
        movd xmm0, ecx
        pcmpeqd xmm1, xmm1
        pshufd xmm0, xmm0, 0
        pxor xmm1, xmm0
        movdqa xmm2, [rsi + 0 * 16]
        movdqa xmm3, [r10 + 0 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10 + 0 * 16], xmm2
        movdqa xmm2, [rsi + 1 * 16]
        movdqa xmm3, [r10 + 1 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10 + 1 * 16], xmm2
        movdqa xmm2, [rsi + 2 * 16]
        movdqa xmm3, [r10 + 2 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10 + 2 * 16], xmm2
        movdqa xmm2, [rsi + 3 * 16]
        movdqa xmm3, [r10 + 3 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10 + 3 * 16], xmm2
        movdqa xmm2, [rsi + 4 * 16]
        movdqa xmm3, [r10 + 4 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10 + 4 * 16], xmm2
        movdqa xmm2, [rsi + 5 * 16]
        movdqa xmm3, [r10 + 5 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10 + 5 * 16], xmm2
        movdqa xmm2, [rsi + 6 * 16]
        movdqa xmm3, [r10 + 6 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10 + 6 * 16], xmm2
        movdqa xmm2, [rsi + 7 * 16]
        movdqa xmm3, [r10 + 7 * 16]
        pand xmm2, xmm0
        pand xmm3, xmm1
        por xmm2, xmm3
        movdqa [r10 + 7 * 16], xmm2
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
