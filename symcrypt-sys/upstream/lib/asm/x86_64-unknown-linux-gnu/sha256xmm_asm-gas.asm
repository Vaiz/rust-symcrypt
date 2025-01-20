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

.extern SymCryptSha256K:DWORD
.extern BYTE_REVERSE_32:DWORD
.extern XMM_PACKLOW:DWORD
.extern XMM_PACKHIGH:DWORD
.set SHA2_INPUT_BLOCK_BYTES_LOG2, 6
.set SHA2_INPUT_BLOCK_BYTES, 64
.set SHA2_ROUNDS, 64
.set SHA2_BYTES_PER_WORD, 4
.set SHA2_SIMD_REG_SIZE, 16
.set SHA2_SINGLE_BLOCK_THRESHOLD, (3 * SHA2_INPUT_BLOCK_BYTES)
.set SHA2_SIMD_LANES, ((SHA2_SIMD_REG_SIZE) / (SHA2_BYTES_PER_WORD))
.set SHA2_EXPANDED_MESSAGE_SIZE, ((SHA2_ROUNDS) * (SHA2_SIMD_REG_SIZE))
.macro LOAD_MSG_WORD ptr, res, ind
        mov \res, [\ptr + (\ind) * SHA2_BYTES_PER_WORD]
        bswap \res
        mov [rsp + (\ind) * SHA2_BYTES_PER_WORD], \res
.endm
.macro GET_SIMD_BLOCK_COUNT cbMsg, t
        shr \cbMsg, SHA2_INPUT_BLOCK_BYTES_LOG2
        mov \t, SHA2_SIMD_LANES
        cmp \cbMsg, \t
        cmova \cbMsg, \t
.endm
.macro GET_PROCESSED_BYTES cbMsg, cbProcessed, t
        mov \cbProcessed, \cbMsg
        mov \t, SHA2_SIMD_LANES * SHA2_INPUT_BLOCK_BYTES
        cmp \cbProcessed, \t
        cmova \cbProcessed, \t
        and \cbProcessed, -SHA2_INPUT_BLOCK_BYTES
.endm
.macro ROUND_T5_BMI2_V1 a, b, c, d, e, f, g, h, rnd, t1, t2, t3, t4, t5, Wk, scale, c0_r1, c0_r2, c0_r3, c1_r1, c1_r2, c1_r3
                                                         rorx \t5, \e, \c1_r1
                                                         rorx \t4, \e, \c1_r2
                        mov \t1, \f
                        andn \t2, \e, \g
                                                         rorx \t3, \e, \c1_r3
        add \h, [\Wk + (\rnd) * (\scale)]
                        and \t1, \e
                                                         xor \t5, \t4
                        xor \t1, \t2
                                                         xor \t5, \t3
        add \h, \t1
                                         rorx \t2, \a, \c0_r1
                                                                        mov \t3, \b
                                                                        mov \t4, \b
                                         rorx \t1, \a, \c0_r2
        add \h, \t5
                                                                        or \t3, \c
                                                                        and \t4, \c
                                                                        and \t3, \a
                                                                        or \t4, \t3
        add \d, \h
                                         xor \t2, \t1
                                         rorx \t5, \a, \c0_r3
                                         xor \t2, \t5
        add \h, \t4
        add \h, \t2
.endm
.macro ROUND_T5_BMI2_V2 a, b, c, d, e, f, g, h, rnd, t1, t2, t3, t4, t5, Wk, scale, c0_r1, c0_r2, c0_r3, c1_r1, c1_r2, c1_r3
                        mov \t1, \f
                        andn \t2, \e, \g
                                                         rorx \t5, \e, \c1_r1
                        and \t1, \e
                                                         rorx \t4, \e, \c1_r2
                                                         rorx \t3, \e, \c1_r3
        add \h, [\Wk + (\rnd) * (\scale)]
                                                         xor \t5, \t4
                        xor \t1, \t2
                                                         xor \t5, \t3
        add \h, \t1
        add \h, \t5
                                                                        mov \t3, \b
                                         rorx \t1, \a, \c0_r2
                                         rorx \t2, \a, \c0_r1
                                                                        mov \t4, \b
                                                                        or \t3, \c
                                                                        and \t4, \c
        add \d, \h
                                                                        and \t3, \a
                                                                        or \t4, \t3
                                         xor \t2, \t1
                                         rorx \t5, \a, \c0_r3
                                         xor \t2, \t5
        add \h, \t4
        add \h, \t2
.endm
.macro ROUND_256 a, b, c, d, e, f, g, h, rnd, t1, t2, t3, t4, t5, Wk, scale
    ROUND_T5_BMI2_V1 \a, \b, \c, \d, \e, \f, \g, \h, \rnd, \t1, \t2, \t3, \t4, \t5, \Wk, \scale, 2, 13, 22, 6, 11, 25
.endm
.macro ROUND_512 a, b, c, d, e, f, g, h, rnd, t1, t2, t3, t4, t5, Wk, scale
    ROUND_T5_BMI2_V1 \a, \b, \c, \d, \e, \f, \g, \h, \rnd, \t1, \t2, \t3, \t4, \t5, \Wk, \scale, 28, 34, 39, 14, 18, 41
.endm
.macro SHA2_UPDATE_CV_HELPER rcv, r0, r1, r2, r3, r4, r5, r6, r7
        add \r0, [\rcv + 0 * SHA2_BYTES_PER_WORD]
        mov [\rcv + 0 * SHA2_BYTES_PER_WORD], \r0
        add \r1, [\rcv + 1 * SHA2_BYTES_PER_WORD]
        mov [\rcv + 1 * SHA2_BYTES_PER_WORD], \r1
        add \r2, [\rcv + 2 * SHA2_BYTES_PER_WORD]
        mov [\rcv + 2 * SHA2_BYTES_PER_WORD], \r2
        add \r3, [\rcv + 3 * SHA2_BYTES_PER_WORD]
        mov [\rcv + 3 * SHA2_BYTES_PER_WORD], \r3
        add \r4, [\rcv + 4 * SHA2_BYTES_PER_WORD]
        mov [\rcv + 4 * SHA2_BYTES_PER_WORD], \r4
        add \r5, [\rcv + 5 * SHA2_BYTES_PER_WORD]
        mov [\rcv + 5 * SHA2_BYTES_PER_WORD], \r5
        add \r6, [\rcv + 6 * SHA2_BYTES_PER_WORD]
        mov [\rcv + 6 * SHA2_BYTES_PER_WORD], \r6
        add \r7, [\rcv + 7 * SHA2_BYTES_PER_WORD]
        mov [\rcv + 7 * SHA2_BYTES_PER_WORD], \r7
.endm
.macro SHA512_MSG_LOAD_TRANSPOSE_YMM P, N, t, v, ind, kreverse, y1, y2, y3, y4, t1, t2, t3, t4
        mov \t, 2 * SHA2_INPUT_BLOCK_BYTES + (\ind) * 32
        mov \v, 3 * SHA2_INPUT_BLOCK_BYTES + (\ind) * 32
        cmp \N, 4
        cmove \t, \v
        vmovdqu \y1, YMMWORD ptr [\P + 0 * SHA2_INPUT_BLOCK_BYTES + (\ind) * 32]
        vpshufb \y1, \y1, \kreverse
        vmovdqu \y2, YMMWORD ptr [\P + 1 * SHA2_INPUT_BLOCK_BYTES + (\ind) * 32]
        vpshufb \y2, \y2, \kreverse
        vmovdqu \y3, YMMWORD ptr [\P + 2 * SHA2_INPUT_BLOCK_BYTES + (\ind) * 32]
        vpshufb \y3, \y3, \kreverse
        vmovdqu \y4, YMMWORD ptr [\P + \t]
        vpshufb \y4, \y4, \kreverse
        SHA512_MSG_TRANSPOSE_YMM \ind, \y1, \y2, \y3, \y4, \t1, \t2, \t3, \t4
.endm
.macro SHA512_MSG_TRANSPOSE_YMM ind, y1, y2, y3, y4, t1, t2, t3, t4
        vpunpcklqdq \t1, \y1, \y2
        vpunpcklqdq \t2, \y3, \y4
        vpunpckhqdq \t3, \y1, \y2
        vpunpckhqdq \t4, \y3, \y4
        vperm2i128 \y1, \t1, \t2, 0x20
        vperm2i128 \y2, \t3, \t4, 0x20
        vperm2i128 \y3, \t1, \t2, 0x31
        vperm2i128 \y4, \t3, \t4, 0x31
        vmovdqu YMMWORD ptr [rsp + (\ind) * 128 + 0 * 32], \y1
        vmovdqu YMMWORD ptr [rsp + (\ind) * 128 + 1 * 32], \y2
        vmovdqu YMMWORD ptr [rsp + (\ind) * 128 + 2 * 32], \y3
        vmovdqu YMMWORD ptr [rsp + (\ind) * 128 + 3 * 32], \y4
.endm
.macro SHA256_MSG_LOAD_TRANSPOSE_XMM P, N, t1, t2, ind, kreverse, x0, x1, x2, x3, xt0, xt1, xt2, xt3
        mov \t2, 2 * SHA2_INPUT_BLOCK_BYTES + (\ind) * 16
        mov \t1, 3 * SHA2_INPUT_BLOCK_BYTES + (\ind) * 16
        cmp \N, 4
        cmove \t2, \t1
        movdqu \x0, XMMWORD ptr [\P + 0 * SHA2_INPUT_BLOCK_BYTES + (\ind) * 16]
        pshufb \x0, \kreverse
        movdqu \x1, XMMWORD ptr [\P + 1 * SHA2_INPUT_BLOCK_BYTES + (\ind) * 16]
        pshufb \x1, \kreverse
        movdqu \x2, XMMWORD ptr [\P + 2 * SHA2_INPUT_BLOCK_BYTES + (\ind) * 16]
        pshufb \x2, \kreverse
        movdqu \x3, XMMWORD ptr [\P + \t2]
        pshufb \x3, \kreverse
        SHA256_MSG_TRANSPOSE_XMM \ind, \x0, \x1, \x2, \x3, \xt0, \xt1, \xt2, \xt3
.endm
.macro SHA256_MSG_TRANSPOSE_XMM ind, x0, x1, x2, x3, t0, t1, t2, t3
        movdqa \t0, \x0
        punpckhdq \t0, \x1
        punpckldq \x0, \x1
        movdqa \t1, \x2
        punpckhdq \t1, \x3
        punpckldq \x2, \x3
        movdqa \x1, \x0
        punpckhqdq \x1, \x2
        punpcklqdq \x0, \x2
        movdqa XMMWORD ptr [rsp + 64 * (\ind) + 0 * 16], \x0
        movdqa XMMWORD ptr [rsp + 64 * (\ind) + 1 * 16], \x1
        movdqa \x3, \t0
        punpckhqdq \x3, \t1
        punpcklqdq \t0, \t1
        movdqa XMMWORD ptr [rsp + 64 * (\ind) + 2 * 16], \t0
        movdqa XMMWORD ptr [rsp + 64 * (\ind) + 3 * 16], \x3
.endm
.macro ROR32_XMM x, c, res, t1
    movdqa \res, \x
    movdqa \t1, \x
    psrld \res, \c
    pslld \t1, 32 - \c
    pxor \res, \t1
.endm
.macro LSIGMA_XMM x, c1, c2, c3, res, t1, t2
        ROR32_XMM \x, \c1, \res, \t1
        ROR32_XMM \x, \c2, \t2, \t1
        movdqa \t1, \x
        psrld \t1, \c3
        pxor \res, \t2
        pxor \res, \t1
.endm
.macro SHA256_MSG_EXPAND_4BLOCKS y0, y1, y9, y14, rnd, t1, t2, t3, t4, t5, t6, Wx, k256
        movd \t1, DWORD ptr [\k256 + 4 * (\rnd - 16)]
        pshufd \t1, \t1, 0
        paddd \t1, \y0
        movdqa XMMWORD ptr [\Wx + (\rnd - 16) * 16], \t1
        LSIGMA_XMM \y14, 17, 19, 10, \t4, \t5, \t3
        LSIGMA_XMM \y1, 7, 18, 3, \t1, \t5, \t3
        paddd \y0, \y9
        paddd \t1, \y0
        paddd \t1, \t4
        movdqa \y0, XMMWORD ptr [\Wx + (\rnd - 14) * 16]
        movdqa XMMWORD ptr [\Wx + (\rnd) * 16], \t1
.endm
.macro SHA256_MSG_EXPAND_1BLOCK x0, x1, x2, x3, t1, t2, t3, t4, t5, t6, karr, ind, packlow, packhigh
        movdqa \t2, \x1
        palignr \t2, \x0, 4
        pshufd \t1, \x3, 0x0fa
        movdqa \t5, \t1
        movdqa \t3, \t1
        psrlq \t5, 17
        psrlq \t3, 19
        pxor \t5, \t3
        psrld \t1, 10
        pxor \t5, \t1
        pshufb \t5, \packlow
        LSIGMA_XMM \t2, 7, 18, 3, \t3, \t1, \t6
        paddd \x0, \t5
        movdqa \t4, \x3
        palignr \t4, \x2, 4
        paddd \t4, \t3
        paddd \x0, \t4
        pshufd \t1, \x0, 0x50
        movdqa \t2, \t1
        movdqa \t3, \t1
        psrlq \t2, 17
        psrlq \t3, 19
        pxor \t2, \t3
        psrld \t1, 10
        pxor \t2, \t1
        pshufb \t2, \packhigh
        movdqa \t6, XMMWORD ptr [\karr + \ind * 16]
        paddd \x0, \t2
        paddd \t6, \x0
        movdqa XMMWORD ptr [rsp + \ind * 16], \t6
.endm
.macro SHA256_MSG_ADD_CONST rnd, t1, t2, Wx, k256
        movd \t1, DWORD ptr [\k256 + 4 * (\rnd)]
        pshufd \t1, \t1, 0
        movdqa \t2, XMMWORD ptr [\Wx + 16 * (\rnd)]
        paddd \t1, \t2
        movdqa XMMWORD ptr [\Wx + (\rnd) * 16], \t1
.endm
SymCryptSha256AppendBlocks_xmm_ssse3_asm: .global SymCryptSha256AppendBlocks_xmm_ssse3_asm
.type SymCryptSha256AppendBlocks_xmm_ssse3_asm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
sub rsp, 1048
        mov [rsp + -8 ], rdi
        mov [rsp + -16 ], rsi
        mov [rsp + -24 ], rdx
        mov [rsp + -32 ], rcx
        mov r11d, 16 * SHA2_BYTES_PER_WORD
        mov ebx, SHA2_EXPANDED_MESSAGE_SIZE
        cmp rdx, SHA2_SINGLE_BLOCK_THRESHOLD
        cmovae r11d, ebx
        mov [((rsp + SHA2_EXPANDED_MESSAGE_SIZE) + 1 * 8)], r11d
        mov rbp, rdi
        mov eax, DWORD ptr [rbp + 0]
        mov edi, DWORD ptr [rbp + 4]
        mov esi, DWORD ptr [rbp + 8]
        mov edx, DWORD ptr [rbp + 12]
        mov ecx, DWORD ptr [rbp + 16]
        mov r8d, DWORD ptr [rbp + 20]
        mov r9d, DWORD ptr [rbp + 24]
        mov r10d, DWORD ptr [rbp + 28]
        mov r11, [rsp + -24 ]
        cmp r11, SHA2_SINGLE_BLOCK_THRESHOLD
        jb single_block_entry
        .align 16
process_blocks:
        GET_SIMD_BLOCK_COUNT r11, rbx
        mov [((rsp + SHA2_EXPANDED_MESSAGE_SIZE) + 0 * 8)], r11
        mov rbx, [rsp + -16 ]
        movdqa xmm8, XMMWORD ptr [BYTE_REVERSE_32@plt+rip]
        SHA256_MSG_LOAD_TRANSPOSE_XMM rbx, r11, rbp, r12, 0, xmm8, xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7
        SHA256_MSG_LOAD_TRANSPOSE_XMM rbx, r11, rbp, r12, 1, xmm8, xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7
        SHA256_MSG_LOAD_TRANSPOSE_XMM rbx, r11, rbp, r12, 2, xmm8, xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7
        SHA256_MSG_LOAD_TRANSPOSE_XMM rbx, r11, rbp, r12, 3, xmm8, xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7
        movdqa xmm0, XMMWORD ptr [rsp + 16 * 0]
        movdqa xmm1, XMMWORD ptr [rsp + 16 * 1]
        movdqa xmm2, XMMWORD ptr [rsp + 16 * 9]
        movdqa xmm3, XMMWORD ptr [rsp + 16 * 10]
        movdqa xmm4, XMMWORD ptr [rsp + 16 * 11]
        movdqa xmm5, XMMWORD ptr [rsp + 16 * 12]
        movdqa xmm6, XMMWORD ptr [rsp + 16 * 13]
        movdqa xmm7, XMMWORD ptr [rsp + 16 * 14]
        movdqa xmm8, XMMWORD ptr [rsp + 16 * 15]
        lea r14, [rsp]
        lea r15, [SymCryptSha256K@plt+rip]
expand_process_first_block:
        SHA256_MSG_EXPAND_4BLOCKS xmm0, xmm1, xmm2, xmm7, (16 + 0), xmm9, xmm10, xmm11, xmm12, xmm13, xmm14, r14, r15
        SHA256_MSG_EXPAND_4BLOCKS xmm1, xmm0, xmm3, xmm8, (16 + 1), xmm2, xmm10, xmm11, xmm12, xmm13, xmm14, r14, r15
        SHA256_MSG_EXPAND_4BLOCKS xmm0, xmm1, xmm4, xmm9, (16 + 2), xmm3, xmm10, xmm11, xmm12, xmm13, xmm14, r14, r15
        SHA256_MSG_EXPAND_4BLOCKS xmm1, xmm0, xmm5, xmm2, (16 + 3), xmm4, xmm10, xmm11, xmm12, xmm13, xmm14, r14, r15
        SHA256_MSG_EXPAND_4BLOCKS xmm0, xmm1, xmm6, xmm3, (16 + 4), xmm5, xmm10, xmm11, xmm12, xmm13, xmm14, r14, r15
        SHA256_MSG_EXPAND_4BLOCKS xmm1, xmm0, xmm7, xmm4, (16 + 5), xmm6, xmm10, xmm11, xmm12, xmm13, xmm14, r14, r15
        SHA256_MSG_EXPAND_4BLOCKS xmm0, xmm1, xmm8, xmm5, (16 + 6), xmm7, xmm10, xmm11, xmm12, xmm13, xmm14, r14, r15
        SHA256_MSG_EXPAND_4BLOCKS xmm1, xmm0, xmm9, xmm6, (16 + 7), xmm8, xmm10, xmm11, xmm12, xmm13, xmm14, r14, r15
        ROUND_256 eax, edi, esi, edx, ecx, r8d, r9d, r10d, 0, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 r10d, eax, edi, esi, edx, ecx, r8d, r9d, 1, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 r9d, r10d, eax, edi, esi, edx, ecx, r8d, 2, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 r8d, r9d, r10d, eax, edi, esi, edx, ecx, 3, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 ecx, r8d, r9d, r10d, eax, edi, esi, edx, 4, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 edx, ecx, r8d, r9d, r10d, eax, edi, esi, 5, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 esi, edx, ecx, r8d, r9d, r10d, eax, edi, 6, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 edi, esi, edx, ecx, r8d, r9d, r10d, eax, 7, r11d, ebx, ebp, r12d, r13d, r14, 16
        lea r11, [SymCryptSha256K@plt+rip + 48 * 4]
        add r14, 8 * 16
        add r15, 8 * 4
        cmp r15, r11
        jb expand_process_first_block
final_rounds:
        SHA256_MSG_ADD_CONST 0, xmm1, xmm2, r14, r15
        SHA256_MSG_ADD_CONST 1, xmm1, xmm2, r14, r15
        SHA256_MSG_ADD_CONST 2, xmm1, xmm2, r14, r15
        SHA256_MSG_ADD_CONST 3, xmm1, xmm2, r14, r15
        SHA256_MSG_ADD_CONST 4, xmm1, xmm2, r14, r15
        SHA256_MSG_ADD_CONST 5, xmm1, xmm2, r14, r15
        SHA256_MSG_ADD_CONST 6, xmm1, xmm2, r14, r15
        SHA256_MSG_ADD_CONST 7, xmm1, xmm2, r14, r15
        ROUND_256 eax, edi, esi, edx, ecx, r8d, r9d, r10d, 0, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 r10d, eax, edi, esi, edx, ecx, r8d, r9d, 1, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 r9d, r10d, eax, edi, esi, edx, ecx, r8d, 2, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 r8d, r9d, r10d, eax, edi, esi, edx, ecx, 3, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 ecx, r8d, r9d, r10d, eax, edi, esi, edx, 4, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 edx, ecx, r8d, r9d, r10d, eax, edi, esi, 5, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 esi, edx, ecx, r8d, r9d, r10d, eax, edi, 6, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 edi, esi, edx, ecx, r8d, r9d, r10d, eax, 7, r11d, ebx, ebp, r12d, r13d, r14, 16
        lea r11, [SymCryptSha256K@plt+rip + 64 * 4]
        add r14, 8 * 16
        add r15, 8 * 4
        cmp r15, r11
        jb final_rounds
        mov r11, [rsp + -8 ]
        SHA2_UPDATE_CV_HELPER r11, eax, edi, esi, edx, ecx, r8d, r9d, r10d
        dec qword ptr [((rsp + SHA2_EXPANDED_MESSAGE_SIZE) + 0 * 8)]
        lea r14, [rsp + 4]
block_begin:
        mov r15d, 64 / 8
        .align 16
inner_loop:
        ROUND_256 eax, edi, esi, edx, ecx, r8d, r9d, r10d, 0, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 r10d, eax, edi, esi, edx, ecx, r8d, r9d, 1, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 r9d, r10d, eax, edi, esi, edx, ecx, r8d, 2, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 r8d, r9d, r10d, eax, edi, esi, edx, ecx, 3, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 ecx, r8d, r9d, r10d, eax, edi, esi, edx, 4, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 edx, ecx, r8d, r9d, r10d, eax, edi, esi, 5, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 esi, edx, ecx, r8d, r9d, r10d, eax, edi, 6, r11d, ebx, ebp, r12d, r13d, r14, 16
        ROUND_256 edi, esi, edx, ecx, r8d, r9d, r10d, eax, 7, r11d, ebx, ebp, r12d, r13d, r14, 16
        add r14, 8 * 16
        sub r15d, 1
        jnz inner_loop
        add r14, (4 - 64 * 16)
        mov r11, [rsp + -8 ]
        SHA2_UPDATE_CV_HELPER r11, eax, edi, esi, edx, ecx, r8d, r9d, r10d
        dec QWORD ptr [((rsp + SHA2_EXPANDED_MESSAGE_SIZE) + 0 * 8)]
        jnz block_begin
        mov r11, [rsp + -24 ]
        GET_PROCESSED_BYTES r11, rbx, rbp
        sub r11, rbx
        add QWORD ptr [rsp + -16 ], rbx
        mov QWORD ptr [rsp + -24 ], r11
        cmp r11, SHA2_SINGLE_BLOCK_THRESHOLD
        jae process_blocks
        .align 16
single_block_entry:
        cmp r11, SHA2_INPUT_BLOCK_BYTES
        jb done
        movdqa xmm13, XMMWORD ptr [BYTE_REVERSE_32@plt+rip]
        movdqa xmm14, XMMWORD ptr [XMM_PACKLOW@plt+rip]
        movdqa xmm15, XMMWORD ptr [XMM_PACKHIGH@plt+rip]
single_block_start:
        mov r14, [rsp + -16 ]
        lea r15, [SymCryptSha256K@plt+rip]
        movdqu xmm0, XMMWORD ptr [r14 + 0 * 16]
        movdqu xmm1, XMMWORD ptr [r14 + 1 * 16]
        movdqu xmm2, XMMWORD ptr [r14 + 2 * 16]
        movdqu xmm3, XMMWORD ptr [r14 + 3 * 16]
        pshufb xmm0, xmm13
        pshufb xmm1, xmm13
        pshufb xmm2, xmm13
        pshufb xmm3, xmm13
        movdqa xmm8, XMMWORD ptr [r15 + 0 * 16]
        movdqa xmm9, XMMWORD ptr [r15 + 1 * 16]
        movdqa xmm10, XMMWORD ptr [r15 + 2 * 16]
        movdqa xmm11, XMMWORD ptr [r15 + 3 * 16]
        paddd xmm8, xmm0
        paddd xmm9, xmm1
        paddd xmm10, xmm2
        paddd xmm11, xmm3
        movdqa XMMWORD ptr [rsp + 0 * 16], xmm8
        movdqa XMMWORD ptr [rsp + 1 * 16], xmm9
        movdqa XMMWORD ptr [rsp + 2 * 16], xmm10
        movdqa XMMWORD ptr [rsp + 3 * 16], xmm11
inner_loop_single:
        add r15, 16 * 4
        ROUND_256 eax, edi, esi, edx, ecx, r8d, r9d, r10d, 0, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 r10d, eax, edi, esi, edx, ecx, r8d, r9d, 1, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 r9d, r10d, eax, edi, esi, edx, ecx, r8d, 2, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 r8d, r9d, r10d, eax, edi, esi, edx, ecx, 3, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 0, xmm14, xmm15
        ROUND_256 ecx, r8d, r9d, r10d, eax, edi, esi, edx, 4, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 edx, ecx, r8d, r9d, r10d, eax, edi, esi, 5, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 esi, edx, ecx, r8d, r9d, r10d, eax, edi, 6, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 edi, esi, edx, ecx, r8d, r9d, r10d, eax, 7, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK xmm1, xmm2, xmm3, xmm0, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 1, xmm14, xmm15
        ROUND_256 eax, edi, esi, edx, ecx, r8d, r9d, r10d, 8, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 r10d, eax, edi, esi, edx, ecx, r8d, r9d, 9, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 r9d, r10d, eax, edi, esi, edx, ecx, r8d, 10, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 r8d, r9d, r10d, eax, edi, esi, edx, ecx, 11, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK xmm2, xmm3, xmm0, xmm1, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 2, xmm14, xmm15
        ROUND_256 ecx, r8d, r9d, r10d, eax, edi, esi, edx, 12, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 edx, ecx, r8d, r9d, r10d, eax, edi, esi, 13, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 esi, edx, ecx, r8d, r9d, r10d, eax, edi, 14, r11d, ebx, ebp, r12d, r13d, rsp, 4
        ROUND_256 edi, esi, edx, ecx, r8d, r9d, r10d, eax, 15, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK xmm3, xmm0, xmm1, xmm2, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 3, xmm14, xmm15
        lea r11, [SymCryptSha256K@plt+rip + 48 * 4]
        cmp r15, r11
        jb inner_loop_single
        lea r14, [rsp]
        lea r15, [rsp + 16 * 4]
single_block_final_rounds:
        ROUND_256 eax, edi, esi, edx, ecx, r8d, r9d, r10d, 0, r11d, ebx, ebp, r12d, r13d, r14, 4
        ROUND_256 r10d, eax, edi, esi, edx, ecx, r8d, r9d, 1, r11d, ebx, ebp, r12d, r13d, r14, 4
        ROUND_256 r9d, r10d, eax, edi, esi, edx, ecx, r8d, 2, r11d, ebx, ebp, r12d, r13d, r14, 4
        ROUND_256 r8d, r9d, r10d, eax, edi, esi, edx, ecx, 3, r11d, ebx, ebp, r12d, r13d, r14, 4
        ROUND_256 ecx, r8d, r9d, r10d, eax, edi, esi, edx, 4, r11d, ebx, ebp, r12d, r13d, r14, 4
        ROUND_256 edx, ecx, r8d, r9d, r10d, eax, edi, esi, 5, r11d, ebx, ebp, r12d, r13d, r14, 4
        ROUND_256 esi, edx, ecx, r8d, r9d, r10d, eax, edi, 6, r11d, ebx, ebp, r12d, r13d, r14, 4
        ROUND_256 edi, esi, edx, ecx, r8d, r9d, r10d, eax, 7, r11d, ebx, ebp, r12d, r13d, r14, 4
        add r14, 8 * 4
        cmp r14, r15
        jb single_block_final_rounds
        mov r11, [rsp + -8 ]
        SHA2_UPDATE_CV_HELPER r11, eax, edi, esi, edx, ecx, r8d, r9d, r10d
        mov r11, [rsp + -24 ]
        sub r11, SHA2_INPUT_BLOCK_BYTES
        add QWORD ptr [rsp + -16 ], SHA2_INPUT_BLOCK_BYTES
        mov QWORD ptr [rsp + -24 ], r11
        cmp r11, SHA2_INPUT_BLOCK_BYTES
        jae single_block_start
done:
        mov rbx, [rsp + -32 ]
        mov QWORD ptr [rbx], r11
        xor rax, rax
        mov rdi, rsp
        mov ecx, [((rsp + SHA2_EXPANDED_MESSAGE_SIZE) + 1 * 8)]
        pxor xmm0, xmm0
        movaps [rdi + 0 * 16], xmm0
        movaps [rdi + 1 * 16], xmm0
        movaps [rdi + 2 * 16], xmm0
        movaps [rdi + 3 * 16], xmm0
        add rdi, 4 * 16
        sub ecx, 4 * 16
        jz nowipe
        rep stosb
nowipe:
add rsp, 1048
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
