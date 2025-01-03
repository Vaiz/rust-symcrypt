SET(SHA2_SIMD_LANES, ((SHA2_SIMD_REG_SIZE) / (SHA2_BYTES_PER_WORD)))
SET(SHA2_EXPANDED_MESSAGE_SIZE, ((SHA2_ROUNDS) * (SHA2_SIMD_REG_SIZE)))
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
        vperm2i128 \y1, \t1, \t2, HEX(20)
        vperm2i128 \y2, \t3, \t4, HEX(20)
        vperm2i128 \y3, \t1, \t2, HEX(31)
        vperm2i128 \y4, \t3, \t4, HEX(31)
        vmovdqu YMMWORD ptr [rsp + (\ind) * 128 + 0 * 32], \y1
        vmovdqu YMMWORD ptr [rsp + (\ind) * 128 + 1 * 32], \y2
        vmovdqu YMMWORD ptr [rsp + (\ind) * 128 + 2 * 32], \y3
        vmovdqu YMMWORD ptr [rsp + (\ind) * 128 + 3 * 32], \y4
.endm
