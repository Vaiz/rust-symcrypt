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

.extern SymCryptSha512K:QWORD
.extern BYTE_REVERSE_64X2:QWORD
.extern BYTE_ROTATE_64:QWORD
.set SHA2_INPUT_BLOCK_BYTES_LOG2, 7
.set SHA2_INPUT_BLOCK_BYTES, 128
.set SHA2_ROUNDS, 80
.set SHA2_BYTES_PER_WORD, 8
.set SHA2_SIMD_REG_SIZE, 32
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
.macro ROR64_YMM x, c, res, t1
    vpsrlq \res, \x, \c
    vpsllq \t1, \x, 64 - \c
    vpxor \res, \res, \t1
.endm
.macro LSIGMA_YMM x, c1, c2, c3, res, t1, t2
        ROR64_YMM \x, \c1, \res, \t1
        ROR64_YMM \x, \c2, \t2, \t1
        vpsrlq \t1, \x, \c3
        vpxor \res, \res, \t2
        vpxor \res, \res, \t1
.endm
.macro LSIGMA0_YMM x, t1, t2, t3, krot8
        ROR64_YMM \x, 1, \t1, \t2
        vpsrlq \t3, \x, 7
        vpshufb \t2, \x, \krot8
        vpxor \t1, \t1, \t2
        vpxor \t1, \t1, \t3
.endm
.macro SHA512_MSG_EXPAND_4BLOCKS y0, y1, y9, y14, rnd, t1, t2, t3, t4, t5, t6, krot8, Wx, k512
        vpbroadcastq \t6, QWORD ptr [\k512 + 8 * (\rnd - 16)]
        vpaddq \t6, \t6, \y0
        vmovdqu YMMWORD ptr [\Wx + (\rnd - 16) * 32], \t6
        LSIGMA_YMM \y14, 19, 61, 6, \t4, \t5, \t3
        LSIGMA0_YMM \y1, \t2, \t1, \t6, \krot8
        vpaddq \t5, \y9, \y0
        vpaddq \t3, \t2, \t4
        vpaddq \t1, \t3, \t5
        vmovdqu \y0, YMMWORD ptr [\Wx + (\rnd - 14) * 32]
        vmovdqu YMMWORD ptr [\Wx + \rnd * 32], \t1
.endm
.macro SHA512_MSG_ADD_CONST rnd, t1, t2, Wx, k512
        vpbroadcastq \t2, QWORD ptr [\k512 + 8 * (\rnd)]
        vmovdqu \t1, YMMWORD ptr [\Wx + 32 * (\rnd)]
        vpaddq \t1, \t1, \t2
        vmovdqu YMMWORD ptr [\Wx + 32 * (\rnd)], \t1
.endm
.macro SHA512_MSG_ADD_CONST_8X rnd, t1, t2, Wx, k512
        SHA512_MSG_ADD_CONST (\rnd + 0), \t1, \t2, \Wx, \k512
        SHA512_MSG_ADD_CONST (\rnd + 1), \t1, \t2, \Wx, \k512
        SHA512_MSG_ADD_CONST (\rnd + 2), \t1, \t2, \Wx, \k512
        SHA512_MSG_ADD_CONST (\rnd + 3), \t1, \t2, \Wx, \k512
        SHA512_MSG_ADD_CONST (\rnd + 4), \t1, \t2, \Wx, \k512
        SHA512_MSG_ADD_CONST (\rnd + 5), \t1, \t2, \Wx, \k512
        SHA512_MSG_ADD_CONST (\rnd + 6), \t1, \t2, \Wx, \k512
        SHA512_MSG_ADD_CONST (\rnd + 7), \t1, \t2, \Wx, \k512
.endm
.macro SHA512_MSG_EXPAND_1BLOCK_0 y0, y1, y2, y3, t1, t2, t3, t4, t5, t6, krot8, karr, ind
        vpblendd \t1, \y1, \y0, 0x0fc
        vpblendd \t5, \y3, \y2, 0x0fc
        LSIGMA0_YMM \t1, \t2, \t3, \t6, \krot8
.endm
.macro SHA512_MSG_EXPAND_1BLOCK_1 y0, y1, y2, y3, t1, t2, t3, t4, t5, t6, krot8, karr, ind
        vpaddq \t2, \t2, \t5
        LSIGMA_YMM \y3, 19, 61, 6, \t4, \t1, \t3
        vpermq \t2, \t2, 0x39
.endm
.macro SHA512_MSG_EXPAND_1BLOCK_2 y0, y1, y2, y3, t1, t2, t3, t4, t5, t6, krot8, karr, ind
        vperm2i128 \t3, \t4, \t4, 0x81
        vpaddq \t2, \y0, \t2
        vpaddq \t2, \t2, \t3
        LSIGMA_YMM \t2, 19, 61, 6, \t4, \t5, \t3
.endm
.macro SHA512_MSG_EXPAND_1BLOCK_3 y0, y1, y2, y3, t1, t2, t3, t4, t5, t6, krot8, karr, ind
        vperm2i128 \t4, \t4, \t4, 0x08
        vmovdqa \t6, YMMWORD ptr [\karr + 32 * \ind]
        vpaddq \y0, \t2, \t4
        vpaddq \t6, \t6, \y0
        vmovdqu YMMWORD ptr [rsp + 32 * \ind], \t6
.endm
SymCryptSha512AppendBlocks_ymm_avx2_asm: .global SymCryptSha512AppendBlocks_ymm_avx2_asm
.type SymCryptSha512AppendBlocks_ymm_avx2_asm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
sub rsp, 2584
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
        mov rax, [rbp + 0]
        mov rdi, [rbp + 8]
        mov rsi, [rbp + 16]
        mov rdx, [rbp + 24]
        mov rcx, [rbp + 32]
        mov r8, [rbp + 40]
        mov r9, [rbp + 48]
        mov r10, [rbp + 56]
        mov r11, [rsp + -24 ]
        cmp r11, SHA2_SINGLE_BLOCK_THRESHOLD
        jb single_block_entry
        .align 16
process_blocks:
        GET_SIMD_BLOCK_COUNT r11, rbx
        mov [((rsp + SHA2_EXPANDED_MESSAGE_SIZE) + 0 * 8)], r11
        mov r13, [rsp + -16 ]
        vmovdqa ymm15, YMMWORD ptr [BYTE_REVERSE_64X2@plt+rip]
        SHA512_MSG_LOAD_TRANSPOSE_YMM r13, r11, rbx, rbp, 0, ymm15, ymm0, ymm1, ymm2, ymm3, ymm9, ymm10, ymm11, ymm12
        SHA512_MSG_LOAD_TRANSPOSE_YMM r13, r11, rbx, rbp, 1, ymm15, ymm2, ymm3, ymm4, ymm5, ymm9, ymm10, ymm11, ymm12
        SHA512_MSG_LOAD_TRANSPOSE_YMM r13, r11, rbx, rbp, 2, ymm15, ymm13, ymm2, ymm3, ymm4, ymm9, ymm10, ymm11, ymm12
        SHA512_MSG_LOAD_TRANSPOSE_YMM r13, r11, rbx, rbp, 3, ymm15, ymm5, ymm6, ymm7, ymm8, ymm9, ymm10, ymm11, ymm12
        lea r14, [rsp]
        lea r15, [SymCryptSha512K@plt+rip]
        vmovdqa ymm15, YMMWORD ptr [BYTE_ROTATE_64@plt+rip]
expand_process_first_block:
        SHA512_MSG_EXPAND_4BLOCKS ymm0, ymm1, ymm2, ymm7, (16 + 0), ymm9, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_512 rax, rdi, rsi, rdx, rcx, r8, r9, r10, 0, r11, rbx, rbp, r12, r13, r14, 32
        SHA512_MSG_EXPAND_4BLOCKS ymm1, ymm0, ymm3, ymm8, (16 + 1), ymm2, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_512 r10, rax, rdi, rsi, rdx, rcx, r8, r9, 1, r11, rbx, rbp, r12, r13, r14, 32
        SHA512_MSG_EXPAND_4BLOCKS ymm0, ymm1, ymm4, ymm9, (16 + 2), ymm3, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_512 r9, r10, rax, rdi, rsi, rdx, rcx, r8, 2, r11, rbx, rbp, r12, r13, r14, 32
        SHA512_MSG_EXPAND_4BLOCKS ymm1, ymm0, ymm5, ymm2, (16 + 3), ymm4, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_512 r8, r9, r10, rax, rdi, rsi, rdx, rcx, 3, r11, rbx, rbp, r12, r13, r14, 32
        SHA512_MSG_EXPAND_4BLOCKS ymm0, ymm1, ymm6, ymm3, (16 + 4), ymm5, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_512 rcx, r8, r9, r10, rax, rdi, rsi, rdx, 4, r11, rbx, rbp, r12, r13, r14, 32
        SHA512_MSG_EXPAND_4BLOCKS ymm1, ymm0, ymm7, ymm4, (16 + 5), ymm6, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_512 rdx, rcx, r8, r9, r10, rax, rdi, rsi, 5, r11, rbx, rbp, r12, r13, r14, 32
        SHA512_MSG_EXPAND_4BLOCKS ymm0, ymm1, ymm8, ymm5, (16 + 6), ymm7, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_512 rsi, rdx, rcx, r8, r9, r10, rax, rdi, 6, r11, rbx, rbp, r12, r13, r14, 32
        SHA512_MSG_EXPAND_4BLOCKS ymm1, ymm0, ymm9, ymm6, (16 + 7), ymm8, ymm10, ymm11, ymm12, ymm13, ymm14, ymm15, r14, r15
        ROUND_512 rdi, rsi, rdx, rcx, r8, r9, r10, rax, 7, r11, rbx, rbp, r12, r13, r14, 32
        lea r11, [SymCryptSha512K@plt+rip + 64 * 8]
        add r14, 8 * 32
        add r15, 8 * 8
        cmp r15, r11
        jb expand_process_first_block
final_rounds:
        SHA512_MSG_ADD_CONST_8X 0, ymm0, ymm1, r14, r15
        ROUND_512 rax, rdi, rsi, rdx, rcx, r8, r9, r10, 0, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 r10, rax, rdi, rsi, rdx, rcx, r8, r9, 1, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 r9, r10, rax, rdi, rsi, rdx, rcx, r8, 2, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 r8, r9, r10, rax, rdi, rsi, rdx, rcx, 3, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 rcx, r8, r9, r10, rax, rdi, rsi, rdx, 4, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 rdx, rcx, r8, r9, r10, rax, rdi, rsi, 5, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 rsi, rdx, rcx, r8, r9, r10, rax, rdi, 6, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 rdi, rsi, rdx, rcx, r8, r9, r10, rax, 7, r11, rbx, rbp, r12, r13, r14, 32
        lea r11, [SymCryptSha512K@plt+rip + 80 * 8]
        add r14, 8 * 32
        add r15, 8 * 8
        cmp r15, r11
        jb final_rounds
        mov r11, [rsp + -8 ]
        SHA2_UPDATE_CV_HELPER r11, rax, rdi, rsi, rdx, rcx, r8, r9, r10
        dec qword ptr [((rsp + SHA2_EXPANDED_MESSAGE_SIZE) + 0 * 8)]
        lea r14, [rsp + 8]
block_begin:
        mov r15d, 80 / 8
        .align 16
inner_loop:
        ROUND_512 rax, rdi, rsi, rdx, rcx, r8, r9, r10, 0, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 r10, rax, rdi, rsi, rdx, rcx, r8, r9, 1, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 r9, r10, rax, rdi, rsi, rdx, rcx, r8, 2, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 r8, r9, r10, rax, rdi, rsi, rdx, rcx, 3, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 rcx, r8, r9, r10, rax, rdi, rsi, rdx, 4, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 rdx, rcx, r8, r9, r10, rax, rdi, rsi, 5, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 rsi, rdx, rcx, r8, r9, r10, rax, rdi, 6, r11, rbx, rbp, r12, r13, r14, 32
        ROUND_512 rdi, rsi, rdx, rcx, r8, r9, r10, rax, 7, r11, rbx, rbp, r12, r13, r14, 32
        add r14, 8 * 32
        sub r15d, 1
        jnz inner_loop
        add r14, (8 - 80 * 32)
        mov r11, [rsp + -8 ]
        SHA2_UPDATE_CV_HELPER r11, rax, rdi, rsi, rdx, rcx, r8, r9, r10
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
        vmovdqa ymm14, YMMWORD ptr [BYTE_REVERSE_64X2@plt+rip]
        vmovdqa ymm15, YMMWORD ptr [BYTE_ROTATE_64@plt+rip]
single_block_start:
        mov r14, [rsp + -16 ]
        lea r15, [SymCryptSha512K@plt+rip]
        vmovdqu ymm0, YMMWORD ptr [r14 + 0 * 32]
        vmovdqu ymm1, YMMWORD ptr [r14 + 1 * 32]
        vmovdqu ymm2, YMMWORD ptr [r14 + 2 * 32]
        vmovdqu ymm3, YMMWORD ptr [r14 + 3 * 32]
        vpshufb ymm0, ymm0, ymm14
        vpshufb ymm1, ymm1, ymm14
        vpshufb ymm2, ymm2, ymm14
        vpshufb ymm3, ymm3, ymm14
        vmovdqu ymm4, YMMWORD ptr [r15 + 0 * 32]
        vmovdqu ymm5, YMMWORD ptr [r15 + 1 * 32]
        vmovdqu ymm6, YMMWORD ptr [r15 + 2 * 32]
        vmovdqu ymm7, YMMWORD ptr [r15 + 3 * 32]
        vpaddq ymm4, ymm4, ymm0
        vpaddq ymm5, ymm5, ymm1
        vpaddq ymm6, ymm6, ymm2
        vpaddq ymm7, ymm7, ymm3
        vmovdqu YMMWORD ptr [rsp + 0 * 32], ymm4
        vmovdqu YMMWORD ptr [rsp + 1 * 32], ymm5
        vmovdqu YMMWORD ptr [rsp + 2 * 32], ymm6
        vmovdqu YMMWORD ptr [rsp + 3 * 32], ymm7
inner_loop_single:
        add r15, 16 * 8
        ROUND_512 rax, rdi, rsi, rdx, rcx, r8, r9, r10, 0, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_0 ymm0, ymm1, ymm2, ymm3, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 0
        ROUND_512 r10, rax, rdi, rsi, rdx, rcx, r8, r9, 1, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_1 ymm0, ymm1, ymm2, ymm3, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 0
        ROUND_512 r9, r10, rax, rdi, rsi, rdx, rcx, r8, 2, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_2 ymm0, ymm1, ymm2, ymm3, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 0
        ROUND_512 r8, r9, r10, rax, rdi, rsi, rdx, rcx, 3, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_3 ymm0, ymm1, ymm2, ymm3, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 0
        ROUND_512 rcx, r8, r9, r10, rax, rdi, rsi, rdx, 4, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_0 ymm1, ymm2, ymm3, ymm0, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 1
        ROUND_512 rdx, rcx, r8, r9, r10, rax, rdi, rsi, 5, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_1 ymm1, ymm2, ymm3, ymm0, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 1
        ROUND_512 rsi, rdx, rcx, r8, r9, r10, rax, rdi, 6, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_2 ymm1, ymm2, ymm3, ymm0, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 1
        ROUND_512 rdi, rsi, rdx, rcx, r8, r9, r10, rax, 7, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_3 ymm1, ymm2, ymm3, ymm0, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 1
        ROUND_512 rax, rdi, rsi, rdx, rcx, r8, r9, r10, 8, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_0 ymm2, ymm3, ymm0, ymm1, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 2
        ROUND_512 r10, rax, rdi, rsi, rdx, rcx, r8, r9, 9, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_1 ymm2, ymm3, ymm0, ymm1, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 2
        ROUND_512 r9, r10, rax, rdi, rsi, rdx, rcx, r8, 10, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_2 ymm2, ymm3, ymm0, ymm1, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 2
        ROUND_512 r8, r9, r10, rax, rdi, rsi, rdx, rcx, 11, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_3 ymm2, ymm3, ymm0, ymm1, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 2
        ROUND_512 rcx, r8, r9, r10, rax, rdi, rsi, rdx, 12, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_0 ymm3, ymm0, ymm1, ymm2, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 3
        ROUND_512 rdx, rcx, r8, r9, r10, rax, rdi, rsi, 13, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_1 ymm3, ymm0, ymm1, ymm2, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 3
        ROUND_512 rsi, rdx, rcx, r8, r9, r10, rax, rdi, 14, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_2 ymm3, ymm0, ymm1, ymm2, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 3
        ROUND_512 rdi, rsi, rdx, rcx, r8, r9, r10, rax, 15, r11, rbx, rbp, r12, r13, rsp, 8
        SHA512_MSG_EXPAND_1BLOCK_3 ymm3, ymm0, ymm1, ymm2, ymm4, ymm5, ymm6, ymm7, ymm8, ymm9, ymm15, r15, 3
        lea r11, [SymCryptSha512K@plt+rip + 64 * 8]
        cmp r15, r11
        jb inner_loop_single
        lea r14, [rsp]
        lea r15, [rsp + 16 * 8]
single_block_final_rounds:
        ROUND_512 rax, rdi, rsi, rdx, rcx, r8, r9, r10, 0, r11, rbx, rbp, r12, r13, r14, 8
        ROUND_512 r10, rax, rdi, rsi, rdx, rcx, r8, r9, 1, r11, rbx, rbp, r12, r13, r14, 8
        ROUND_512 r9, r10, rax, rdi, rsi, rdx, rcx, r8, 2, r11, rbx, rbp, r12, r13, r14, 8
        ROUND_512 r8, r9, r10, rax, rdi, rsi, rdx, rcx, 3, r11, rbx, rbp, r12, r13, r14, 8
        ROUND_512 rcx, r8, r9, r10, rax, rdi, rsi, rdx, 4, r11, rbx, rbp, r12, r13, r14, 8
        ROUND_512 rdx, rcx, r8, r9, r10, rax, rdi, rsi, 5, r11, rbx, rbp, r12, r13, r14, 8
        ROUND_512 rsi, rdx, rcx, r8, r9, r10, rax, rdi, 6, r11, rbx, rbp, r12, r13, r14, 8
        ROUND_512 rdi, rsi, rdx, rcx, r8, r9, r10, rax, 7, r11, rbx, rbp, r12, r13, r14, 8
        add r14, 8 * 8
        cmp r14, r15
        jb single_block_final_rounds
        mov r11, [rsp + -8 ]
        SHA2_UPDATE_CV_HELPER r11, rax, rdi, rsi, rdx, rcx, r8, r9, r10
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
        mov rdi, rsp
        xor rax, rax
        mov ecx, [((rsp + SHA2_EXPANDED_MESSAGE_SIZE) + 1 * 8)]
        pxor xmm0, xmm0
        movaps [rdi + 0 * 16], xmm0
        movaps [rdi + 1 * 16], xmm0
        movaps [rdi + 2 * 16], xmm0
        movaps [rdi + 3 * 16], xmm0
        movaps [rdi + 4 * 16], xmm0
        movaps [rdi + 5 * 16], xmm0
        movaps [rdi + 6 * 16], xmm0
        movaps [rdi + 7 * 16], xmm0
        add rdi, 8 * 16
        sub ecx, 8 * 16
        jz nowipe
        rep stosb
nowipe:
add rsp, 2584
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
