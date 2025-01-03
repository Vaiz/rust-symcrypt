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
SymCryptWipeAsm: .global SymCryptWipeAsm
.type SymCryptWipeAsm, %function
        xorps xmm0,xmm0
        cmp rsi,16
        jb SymCryptWipeAsmSmall
        test rdi,15
        jnz SymCryptWipeAsmUnaligned
SymCryptWipeAsmAligned:
        test rsi,16
        movaps [rdi],xmm0
        lea rdx,[rdi+16]
        cmovnz rdi,rdx
        sub rsi,32
        jc SymCryptWipeAsmTailOptional
.align 16
SymCryptWipeAsmLoop:
        movaps [rdi],xmm0
        movaps [rdi+16],xmm0
        add rdi,32
        sub rsi,32
        jnc SymCryptWipeAsmLoop
SymCryptWipeAsmTailOptional:
        and esi,15
        jnz SymCryptWipeAsmTail
        ret
SymCryptWipeAsmTail:
        xor eax,eax
        mov [rdi+rsi-16],rax
        mov [rdi+rsi-8],rax
        ret
.align 4
SymCryptWipeAsmUnaligned:
        xor eax,eax
        mov [rdi],rax
        mov [rdi+8],rax
        mov eax,edi
        neg eax
        and eax,15
        add rdi,rax
        sub rsi,rax
        cmp rsi,16
        jae SymCryptWipeAsmAligned
        xor eax,eax
        mov [rdi+rsi-16],rax
        mov [rdi+rsi-8],rax
        ret
.align 8
SymCryptWipeAsmSmall:
        xor eax,eax
        cmp esi, 8
        jb SymCryptWipeAsmSmallLessThan8
        mov [rdi],rax
        mov [rdi+rsi-8],rax
        ret
SymCryptWipeAsmSmallLessThan8:
        cmp esi, 4
        jb SymCryptWipeAsmSmallLessThan4
        mov [rdi],eax
        mov [rdi+rsi-4],eax
        ret
SymCryptWipeAsmSmallLessThan4:
        cmp esi, 2
        jb SymCryptWipeAsmSmallLessThan2
        mov [rdi],ax
        mov [rdi+rsi-2],ax
        ret
SymCryptWipeAsmSmallLessThan2:
        or esi,esi
        jz SymCryptWipeAsmSmallDone
        mov [rdi],al
SymCryptWipeAsmSmallDone:
ret
