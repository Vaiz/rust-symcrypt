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
.extern BYTE_REVERSE_32X2:DWORD
.extern XMM_PACKLOW:DWORD
.extern XMM_PACKHIGH:DWORD
.set SHA2_INPUT_BLOCK_BYTES_LOG2, 6
.set SHA2_INPUT_BLOCK_BYTES, 64
.set SHA2_ROUNDS, 64
.set SHA2_BYTES_PER_WORD, 4
.set SHA2_SIMD_REG_SIZE, 32
.set SHA2_SINGLE_BLOCK_THRESHOLD, (5 * SHA2_INPUT_BLOCK_BYTES)
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
.macro SHA256_MSG_LOAD_TRANSPOSE_YMM P, N, t1, t2, t3, t4, Wbase
        vmovdqa ymm15, YMMWORD ptr [BYTE_REVERSE_32X2@plt+rip]
        vmovdqu ymm13, YMMWORD ptr [\P + 0 * 64]
        vpshufb ymm13, ymm13, ymm15
        vmovdqu ymm7, YMMWORD ptr [\P + 1 * 64]
        vpshufb ymm7, ymm7, ymm15
        vmovdqu ymm10, YMMWORD ptr [\P + 2 * 64]
        vpshufb ymm10, ymm10, ymm15
        vmovdqu ymm0, YMMWORD ptr [\P + 3 * 64]
        vpshufb ymm0, ymm0, ymm15
        vmovdqu ymm14, YMMWORD ptr [\P + 4 * 64]
        vpshufb ymm14, ymm14, ymm15
        lea \t1, [\P + 4 * 64]
        lea \t2, [\P + 5 * 64]
        lea \t3, [\P + 6 * 64]
        lea \t4, [\P + 7 * 64]
        cmp \N, 6
        cmovb \t2, \t1
        cmovbe \t3, \t1
        cmp \N, 8
        cmovb \t4, \t1
        vmovdqu ymm8, YMMWORD ptr [\t2]
        vpshufb ymm8, ymm8, ymm15
        vmovdqu ymm11, YMMWORD ptr [\t3]
        vpshufb ymm11, ymm11, ymm15
        vmovdqu ymm9, YMMWORD ptr [\t4]
        vpshufb ymm9, ymm9, ymm15
        SHA256_MSG_TRANSPOSE_YMM \Wbase
.endm
.macro SHA256_MSG_TRANSPOSE_YMM Wbase
        vpunpckldq ymm1, ymm13, ymm7
        vpunpckldq ymm5, ymm10, ymm0
        vpunpckldq ymm2, ymm14, ymm8
        vpunpckldq ymm6, ymm11, ymm9
        vpunpckhdq ymm12, ymm13, ymm7
        vpunpckhdq ymm3, ymm10, ymm0
        vpunpckhdq ymm4, ymm14, ymm8
        vpunpckhdq ymm15, ymm11, ymm9
        vpunpcklqdq ymm13, ymm1, ymm5
        vpunpcklqdq ymm7, ymm2, ymm6
        vpunpckhqdq ymm14, ymm1, ymm5
        vpunpckhqdq ymm8, ymm2, ymm6
        vpunpcklqdq ymm10, ymm12, ymm3
        vpunpcklqdq ymm0, ymm4, ymm15
        vpunpckhqdq ymm11, ymm12, ymm3
        vpunpckhqdq ymm9, ymm4, ymm15
        vperm2i128 ymm1, ymm13, ymm7, 0x20
        vperm2i128 ymm2, ymm14, ymm8, 0x20
        vperm2i128 ymm3, ymm10, ymm0, 0x20
        vperm2i128 ymm4, ymm11, ymm9, 0x20
        vperm2i128 ymm5, ymm13, ymm7, 0x31
        vperm2i128 ymm6, ymm14, ymm8, 0x31
        vperm2i128 ymm7, ymm10, ymm0, 0x31
        vperm2i128 ymm8, ymm11, ymm9, 0x31
        vmovdqu YMMWORD ptr [\Wbase + 0 * 32], ymm1
        vmovdqu YMMWORD ptr [\Wbase + 1 * 32], ymm2
        vmovdqu YMMWORD ptr [\Wbase + 2 * 32], ymm3
        vmovdqu YMMWORD ptr [\Wbase + 3 * 32], ymm4
        vmovdqu YMMWORD ptr [\Wbase + 4 * 32], ymm5
        vmovdqu YMMWORD ptr [\Wbase + 5 * 32], ymm6
        vmovdqu YMMWORD ptr [\Wbase + 6 * 32], ymm7
        vmovdqu YMMWORD ptr [\Wbase + 7 * 32], ymm8
.endm
.macro ROR32_YMM x, c, t1, t2
    vpsrld \t1, \x, \c
    vpslld \t2, \x, 32 - \c
    vpxor \t1, \t1, \t2
.endm
.macro LSIGMA_YMM x, c1, c2, c3, t1, t2, t3, t4
        ROR32_YMM \x, \c1, \t1, \t2
        ROR32_YMM \x, \c2, \t3, \t4
        vpsrld \t2, \x, \c3
        vpxor \t1, \t1, \t3
        vpxor \t1, \t1, \t2
.endm
.macro SHA256_MSG_EXPAND_8BLOCKS y0, y1, y9, y14, rnd, t1, t2, t3, t4, t5, t6, krot8, Wx, k256
        vpbroadcastd \t6, DWORD ptr [\k256 + 4 * (\rnd - 16)]
        vpaddd \t6, \t6, \y0
        vmovdqu YMMWORD ptr [\Wx + (\rnd - 16) * 32], \t6
        LSIGMA_YMM \y14, 17, 19, 10, \t4, \t5, \t3, \t1
        LSIGMA_YMM \y1, 7, 18, 3, \t2, \t1, \t6, \t3
        vpaddd \t5, \y9, \y0
        vpaddd \t3, \t2, \t4
        vpaddd \t1, \t3, \t5
        vmovdqu \y0, YMMWORD ptr [\Wx + (\rnd - 14) * 32]
        vmovdqu YMMWORD ptr [\Wx + \rnd * 32], \t1
.endm
.macro SHA256_MSG_EXPAND_1BLOCK_0 x0, x1, x2, x3, t1, t2, t3, t4, t5, t6, karr, ind, packlow, packhigh
        vpalignr \t2, \x1, \x0, 4
        vpshufd \t1, \x3, 0x0fa
        vpsrlq \t5, \t1, 17
        vpsrlq \t3, \t1, 19
        vpxor \t5, \t5, \t3
        vpsrld \t1, \t1, 10
        vpxor \t5, \t5, \t1
        vpshufb \t5, \t5, \packlow
        LSIGMA_YMM \t2, 7, 18, 3, \t3, \t1, \t6, \t4
.endm
.macro SHA256_MSG_EXPAND_1BLOCK_1 x0, x1, x2, x3, t1, t2, t3, t4, t5, t6, karr, ind, packlow, packhigh
        vpalignr \t4, \x3, \x2, 4
        vpaddd \x0, \x0, \t3
        vpaddd \t5, \t5, \t4
        vpaddd \x0, \x0, \t5
.endm
.macro SHA256_MSG_EXPAND_1BLOCK_2 x0, x1, x2, x3, t1, t2, t3, t4, t5, t6, karr, ind, packlow, packhigh
        vpshufd \t1, \x0, 0x50
        vpsrlq \t2, \t1, 17
        vpsrlq \t3, \t1, 19
        vpxor \t2, \t2, \t3
        vpsrld \t1, \t1, 10
        vpxor \t2, \t2, \t1
.endm
.macro SHA256_MSG_EXPAND_1BLOCK_3 x0, x1, x2, x3, t1, t2, t3, t4, t5, t6, karr, ind, packlow, packhigh
        vpshufb \t2, \t2, \packhigh
        vmovdqa \t6, XMMWORD ptr [\karr + \ind * 16]
        vpaddd \x0, \x0, \t2
        vpaddd \t6, \t6, \x0
        vmovdqa XMMWORD ptr [rsp + \ind * 16], \t6
.endm
.macro SHA256_MSG_ADD_CONST rnd, t1, t2, Wx, k256
        vpbroadcastd \t2, DWORD ptr [\k256 + 4 * (\rnd)]
        vmovdqu \t1, YMMWORD ptr [\Wx + 32 * (\rnd)]
        vpaddd \t1, \t1, \t2
        vmovdqu YMMWORD ptr [\Wx + 32 * (\rnd)], \t1
.endm
SymCryptSha256AppendBlocks_ymm_avx2_asm: .global SymCryptSha256AppendBlocks_ymm_avx2_asm
.type SymCryptSha256AppendBlocks_ymm_avx2_asm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
sub rsp, 2072
        vzeroupper
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
        mov eax, [rbp + 0]
        mov edi, [rbp + 4]
        mov esi, [rbp + 8]
        mov edx, [rbp + 12]
        mov ecx, [rbp + 16]
        mov r8d, [rbp + 20]
        mov r9d, [rbp + 24]
        mov r10d, [rbp + 28]
        mov r11, [rsp + -24 ]
        cmp r11, SHA2_SINGLE_BLOCK_THRESHOLD
        jb single_block_entry
        .align 16
process_blocks:
        GET_SIMD_BLOCK_COUNT r11, rbx
        mov [((rsp + SHA2_EXPANDED_MESSAGE_SIZE) + 0 * 8)], r11
        mov rbx, [rsp + -16 ]
        lea rbp, [rsp]
msg_transpose:
        SHA256_MSG_LOAD_TRANSPOSE_YMM rbx, r11, r12, r13, r14, r15, rbp
        add rbx, 32
        add rbp, 256
        lea r12, [rsp + 256]
        cmp rbp, r12
        jbe msg_transpose
        lea r14, [rsp]
        lea r15, [SymCryptSha256K@plt+rip]
        vmovdqu ymm0, YMMWORD ptr [rsp + 32 * 0]
        vmovdqu ymm1, YMMWORD ptr [rsp + 32 * 1]
        .align 16
expand_process_first_block:
        SHA256_MSG_EXPAND_8BLOCKS ymm0, ymm1, ymm2, ymm7, (16 + 0), ymm9, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_256 eax, edi, esi, edx, ecx, r8d, r9d, r10d, 0, r11d, ebx, ebp, r12d, r13d, r14, 32
        SHA256_MSG_EXPAND_8BLOCKS ymm1, ymm0, ymm3, ymm8, (16 + 1), ymm2, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_256 r10d, eax, edi, esi, edx, ecx, r8d, r9d, 1, r11d, ebx, ebp, r12d, r13d, r14, 32
        SHA256_MSG_EXPAND_8BLOCKS ymm0, ymm1, ymm4, ymm9, (16 + 2), ymm3, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_256 r9d, r10d, eax, edi, esi, edx, ecx, r8d, 2, r11d, ebx, ebp, r12d, r13d, r14, 32
        SHA256_MSG_EXPAND_8BLOCKS ymm1, ymm0, ymm5, ymm2, (16 + 3), ymm4, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_256 r8d, r9d, r10d, eax, edi, esi, edx, ecx, 3, r11d, ebx, ebp, r12d, r13d, r14, 32
        SHA256_MSG_EXPAND_8BLOCKS ymm0, ymm1, ymm6, ymm3, (16 + 4), ymm5, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_256 ecx, r8d, r9d, r10d, eax, edi, esi, edx, 4, r11d, ebx, ebp, r12d, r13d, r14, 32
        SHA256_MSG_EXPAND_8BLOCKS ymm1, ymm0, ymm7, ymm4, (16 + 5), ymm6, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_256 edx, ecx, r8d, r9d, r10d, eax, edi, esi, 5, r11d, ebx, ebp, r12d, r13d, r14, 32
        SHA256_MSG_EXPAND_8BLOCKS ymm0, ymm1, ymm8, ymm5, (16 + 6), ymm7, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_256 esi, edx, ecx, r8d, r9d, r10d, eax, edi, 6, r11d, ebx, ebp, r12d, r13d, r14, 32
        SHA256_MSG_EXPAND_8BLOCKS ymm1, ymm0, ymm9, ymm6, (16 + 7), ymm8, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_256 edi, esi, edx, ecx, r8d, r9d, r10d, eax, 7, r11d, ebx, ebp, r12d, r13d, r14, 32
        lea r11, [SymCryptSha256K@plt+rip + 48 * 4]
        add r14, 8 * 32
        add r15, 8 * 4
        cmp r15, r11
        jb expand_process_first_block
final_rounds:
        SHA256_MSG_ADD_CONST 0, ymm1, ymm2, r14, r15
        SHA256_MSG_ADD_CONST 1, ymm1, ymm2, r14, r15
        SHA256_MSG_ADD_CONST 2, ymm1, ymm2, r14, r15
        SHA256_MSG_ADD_CONST 3, ymm1, ymm2, r14, r15
        SHA256_MSG_ADD_CONST 4, ymm1, ymm2, r14, r15
        SHA256_MSG_ADD_CONST 5, ymm1, ymm2, r14, r15
        SHA256_MSG_ADD_CONST 6, ymm1, ymm2, r14, r15
        SHA256_MSG_ADD_CONST 7, ymm1, ymm2, r14, r15
        ROUND_256 eax, edi, esi, edx, ecx, r8d, r9d, r10d, 0, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 r10d, eax, edi, esi, edx, ecx, r8d, r9d, 1, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 r9d, r10d, eax, edi, esi, edx, ecx, r8d, 2, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 r8d, r9d, r10d, eax, edi, esi, edx, ecx, 3, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 ecx, r8d, r9d, r10d, eax, edi, esi, edx, 4, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 edx, ecx, r8d, r9d, r10d, eax, edi, esi, 5, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 esi, edx, ecx, r8d, r9d, r10d, eax, edi, 6, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 edi, esi, edx, ecx, r8d, r9d, r10d, eax, 7, r11d, ebx, ebp, r12d, r13d, r14, 32
        lea r11, [SymCryptSha256K@plt+rip + 64 * 4]
        add r14, 8 * 32
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
        ROUND_256 eax, edi, esi, edx, ecx, r8d, r9d, r10d, 0, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 r10d, eax, edi, esi, edx, ecx, r8d, r9d, 1, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 r9d, r10d, eax, edi, esi, edx, ecx, r8d, 2, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 r8d, r9d, r10d, eax, edi, esi, edx, ecx, 3, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 ecx, r8d, r9d, r10d, eax, edi, esi, edx, 4, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 edx, ecx, r8d, r9d, r10d, eax, edi, esi, 5, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 esi, edx, ecx, r8d, r9d, r10d, eax, edi, 6, r11d, ebx, ebp, r12d, r13d, r14, 32
        ROUND_256 edi, esi, edx, ecx, r8d, r9d, r10d, eax, 7, r11d, ebx, ebp, r12d, r13d, r14, 32
        add r14, 8 * 32
        sub r15d, 1
        jnz inner_loop
        add r14, (4 - 64 * 32)
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
        vmovdqa xmm13, XMMWORD ptr [BYTE_REVERSE_32X2@plt+rip]
        vmovdqa xmm14, XMMWORD ptr [XMM_PACKLOW@plt+rip]
        vmovdqa xmm15, XMMWORD ptr [XMM_PACKHIGH@plt+rip]
single_block_start:
        mov r14, [rsp + -16 ]
        lea r15, [SymCryptSha256K@plt+rip]
        vmovdqu xmm0, XMMWORD ptr [r14 + 0 * 16]
        vmovdqu xmm1, XMMWORD ptr [r14 + 1 * 16]
        vmovdqu xmm2, XMMWORD ptr [r14 + 2 * 16]
        vmovdqu xmm3, XMMWORD ptr [r14 + 3 * 16]
        vpshufb xmm0, xmm0, xmm13
        vpshufb xmm1, xmm1, xmm13
        vpshufb xmm2, xmm2, xmm13
        vpshufb xmm3, xmm3, xmm13
        vmovdqa xmm4, XMMWORD ptr [r15 + 0 * 16]
        vmovdqa xmm5, XMMWORD ptr [r15 + 1 * 16]
        vmovdqa xmm6, XMMWORD ptr [r15 + 2 * 16]
        vmovdqa xmm7, XMMWORD ptr [r15 + 3 * 16]
        vpaddd xmm4, xmm4, xmm0
        vpaddd xmm5, xmm5, xmm1
        vpaddd xmm6, xmm6, xmm2
        vpaddd xmm7, xmm7, xmm3
        vmovdqa XMMWORD ptr [rsp + 0 * 16], xmm4
        vmovdqa XMMWORD ptr [rsp + 1 * 16], xmm5
        vmovdqa XMMWORD ptr [rsp + 2 * 16], xmm6
        vmovdqa XMMWORD ptr [rsp + 3 * 16], xmm7
inner_loop_single:
        add r15, 16 * 4
        ROUND_256 eax, edi, esi, edx, ecx, r8d, r9d, r10d, 0, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_0 xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 0, xmm14, xmm15
        ROUND_256 r10d, eax, edi, esi, edx, ecx, r8d, r9d, 1, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_1 xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 0, xmm14, xmm15
        ROUND_256 r9d, r10d, eax, edi, esi, edx, ecx, r8d, 2, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_2 xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 0, xmm14, xmm15
        ROUND_256 r8d, r9d, r10d, eax, edi, esi, edx, ecx, 3, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_3 xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 0, xmm14, xmm15
        ROUND_256 ecx, r8d, r9d, r10d, eax, edi, esi, edx, 4, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_0 xmm1, xmm2, xmm3, xmm0, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 1, xmm14, xmm15
        ROUND_256 edx, ecx, r8d, r9d, r10d, eax, edi, esi, 5, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_1 xmm1, xmm2, xmm3, xmm0, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 1, xmm14, xmm15
        ROUND_256 esi, edx, ecx, r8d, r9d, r10d, eax, edi, 6, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_2 xmm1, xmm2, xmm3, xmm0, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 1, xmm14, xmm15
        ROUND_256 edi, esi, edx, ecx, r8d, r9d, r10d, eax, 7, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_3 xmm1, xmm2, xmm3, xmm0, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 1, xmm14, xmm15
        ROUND_256 eax, edi, esi, edx, ecx, r8d, r9d, r10d, 8, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_0 xmm2, xmm3, xmm0, xmm1, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 2, xmm14, xmm15
        ROUND_256 r10d, eax, edi, esi, edx, ecx, r8d, r9d, 9, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_1 xmm2, xmm3, xmm0, xmm1, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 2, xmm14, xmm15
        ROUND_256 r9d, r10d, eax, edi, esi, edx, ecx, r8d, 10, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_2 xmm2, xmm3, xmm0, xmm1, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 2, xmm14, xmm15
        ROUND_256 r8d, r9d, r10d, eax, edi, esi, edx, ecx, 11, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_3 xmm2, xmm3, xmm0, xmm1, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 2, xmm14, xmm15
        ROUND_256 ecx, r8d, r9d, r10d, eax, edi, esi, edx, 12, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_0 xmm3, xmm0, xmm1, xmm2, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 3, xmm14, xmm15
        ROUND_256 edx, ecx, r8d, r9d, r10d, eax, edi, esi, 13, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_1 xmm3, xmm0, xmm1, xmm2, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 3, xmm14, xmm15
        ROUND_256 esi, edx, ecx, r8d, r9d, r10d, eax, edi, 14, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_2 xmm3, xmm0, xmm1, xmm2, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 3, xmm14, xmm15
        ROUND_256 edi, esi, edx, ecx, r8d, r9d, r10d, eax, 15, r11d, ebx, ebp, r12d, r13d, rsp, 4
        SHA256_MSG_EXPAND_1BLOCK_3 xmm3, xmm0, xmm1, xmm2, xmm4, xmm5, xmm6, xmm7, xmm8, xmm9, r15, 3, xmm14, xmm15
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
        vzeroupper
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
add rsp, 2072
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
