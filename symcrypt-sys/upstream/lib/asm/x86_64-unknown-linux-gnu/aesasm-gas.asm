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
.macro SYMCRYPT_CHECK_MAGIC check_magic_label, ptr, struct_magic_offset, arg_1
.endm
.set N_ROUND_KEYS_IN_AESKEY, 29
.set lastEncRoundKeyOffset, (29*16)
.set lastDecRoundKeyOffset, (29*16 + 8)
.set magicFieldOffset, (29*16 + 8 + 8)
.macro ENC_MIX keyptr
        movzx esi,al
        mov esi,[(r11 + 0) + 4 * rsi]
        movzx edi,ah
        shr eax,16
        mov r8d,[(r11 + 1024) + 4 * rdi]
        movzx ebp,al
        mov ebp,[(r11 + 2048) + 4 * rbp]
        movzx edi,ah
        mov edi,[(r11 + 3072) + 4 * rdi]
        movzx eax,bl
        xor edi,[(r11 + 0) + 4 * rax]
        movzx eax,bh
        shr ebx,16
        xor esi,[(r11 + 1024) + 4 * rax]
        movzx eax,bl
        xor r8d,[(r11 + 2048) + 4 * rax]
        movzx eax,bh
        xor ebp,[(r11 + 3072) + 4 * rax]
        movzx eax,cl
        xor ebp,[(r11 + 0) + 4 * rax]
        movzx ebx,ch
        shr ecx,16
        xor edi,[(r11 + 1024) + 4 * rbx]
        movzx eax,cl
        xor esi,[(r11 + 2048) + 4 * rax]
        movzx ebx,ch
        xor r8d,[(r11 + 3072) + 4 * rbx]
        movzx eax,dl
        xor r8d,[(r11 + 0) + 4 * rax]
        movzx ebx,dh
        shr edx,16
        xor ebp,[(r11 + 1024) + 4 * rbx]
        movzx eax,dl
        xor edi,[(r11 + 2048) + 4 * rax]
        movzx ebx,dh
        xor esi,[(r11 + 3072) + 4 * rbx]
        mov eax, [\keyptr]
        mov ebx, [\keyptr + 4]
        xor eax, esi
        mov ecx, [\keyptr + 8]
        xor ebx, edi
        mov edx, [\keyptr + 12]
        xor ecx, ebp
        xor edx, r8d
.endm
.macro DEC_MIX keyptr
        movzx esi,al
        mov esi,[(r11 + 0) + 4 * rsi]
        movzx edi,ah
        shr eax,16
        mov edi,[(r11 + 1024) + 4 * rdi]
        movzx ebp,al
        mov ebp,[(r11 + 2048) + 4 * rbp]
        movzx eax,ah
        mov r8d,[(r11 + 3072) + 4 * rax]
        movzx eax,bl
        xor edi,[(r11 + 0) + 4 * rax]
        movzx eax,bh
        shr ebx,16
        xor ebp,[(r11 + 1024) + 4 * rax]
        movzx eax,bl
        xor r8d,[(r11 + 2048) + 4 * rax]
        movzx eax,bh
        xor esi,[(r11 + 3072) + 4 * rax]
        movzx eax,cl
        xor ebp,[(r11 + 0) + 4 * rax]
        movzx ebx,ch
        shr ecx,16
        xor r8d,[(r11 + 1024) + 4 * rbx]
        movzx eax,cl
        xor esi,[(r11 + 2048) + 4 * rax]
        movzx ebx,ch
        xor edi,[(r11 + 3072) + 4 * rbx]
        movzx eax,dl
        xor r8d,[(r11 + 0) + 4 * rax]
        movzx ebx,dh
        shr edx,16
        xor esi,[(r11 + 1024) + 4 * rbx]
        movzx eax,dl
        xor edi,[(r11 + 2048) + 4 * rax]
        movzx ebx,dh
        xor ebp,[(r11 + 3072) + 4 * rbx]
        mov eax, [\keyptr]
        mov ebx, [\keyptr + 4]
        xor eax, esi
        mov ecx, [\keyptr + 8]
        xor ebx, edi
        mov edx, [\keyptr + 12]
        xor ecx, ebp
        xor edx, r8d
.endm
.macro AES_ENCRYPT_MACRO AesEncryptMacroLoopLabel
        xor eax,[r9]
        xor ebx,[r9+4]
        xor ecx,[r9+8]
        xor edx,[r9+12]
        add r9,32
\AesEncryptMacroLoopLabel:
        ENC_MIX r9-16
        cmp r9,r10
        lea r9,[r9+16]
        jc \AesEncryptMacroLoopLabel
        movzx esi,al
        movzx esi,byte ptr[r11 + 1 + 4*rsi]
        movzx edi,ah
        shr eax,16
        movzx r8d,byte ptr[r11 + 1 + 4*rdi]
        movzx ebp,al
        shl r8d,8
        movzx ebp,byte ptr[r11 + 1 + 4*rbp]
        shl ebp,16
        movzx edi,ah
        movzx edi,byte ptr[r11 + 1 + 4*rdi]
        shl edi,24
        movzx eax,bl
        movzx eax,byte ptr[r11 + 1 + 4*rax]
        or edi,eax
        movzx eax,bh
        shr ebx,16
        movzx eax,byte ptr[r11 + 1 + 4*rax]
        shl eax,8
        or esi,eax
        movzx eax,bl
        movzx eax,byte ptr[r11 + 1 + 4*rax]
        movzx ebx,bh
        shl eax,16
        movzx ebx,byte ptr[r11 + 1 + 4*rbx]
        or r8d,eax
        shl ebx,24
        or ebp,ebx
        movzx eax,cl
        movzx ebx,ch
        movzx eax,byte ptr[r11 + 1 + 4*rax]
        shr ecx,16
        movzx ebx,byte ptr[r11 + 1 + 4*rbx]
        shl ebx,8
        or ebp,eax
        or edi,ebx
        movzx eax,cl
        movzx eax,byte ptr[r11 + 1 + 4*rax]
        movzx ebx,ch
        movzx ebx,byte ptr[r11 + 1 + 4*rbx]
        shl eax,16
        shl ebx,24
        or esi,eax
        or r8d,ebx
        movzx eax,dl
        movzx ebx,dh
        movzx eax,byte ptr[r11 + 1 + 4*rax]
        shr edx,16
        movzx ebx,byte ptr[r11 + 1 + 4*rbx]
        shl ebx,8
        or r8d,eax
        or ebp,ebx
        movzx eax,dl
        movzx eax,byte ptr[r11 + 1 + 4*rax]
        movzx ebx,dh
        movzx ebx,byte ptr[r11 + 1 + 4*rbx]
        shl eax,16
        shl ebx,24
        or edi,eax
        or esi,ebx
        xor r8d,[r10+12]
        xor esi,[r10]
        xor edi,[r10+4]
        xor ebp,[r10+8]
.endm
.macro AES_DECRYPT_MACRO AesDecryptMacroLoopLabel
        xor eax,[r9]
        xor ebx,[r9+4]
        xor ecx,[r9+8]
        xor edx,[r9+12]
        add r9,32
\AesDecryptMacroLoopLabel:
        DEC_MIX r9-16
        cmp r9,r10
        lea r9,[r9+16]
        jc \AesDecryptMacroLoopLabel
        movzx esi,al
        movzx esi,byte ptr[r12 + rsi]
        movzx edi,ah
        shr eax,16
        movzx edi,byte ptr[r12 + rdi]
        movzx ebp,al
        shl edi,8
        movzx ebp,byte ptr[r12 + rbp]
        shl ebp,16
        movzx eax,ah
        movzx r8d,byte ptr[r12 + rax]
        shl r8d,24
        movzx eax,bl
        movzx eax,byte ptr[r12 + rax]
        or edi,eax
        movzx eax,bh
        shr ebx,16
        movzx eax,byte ptr[r12 + rax]
        shl eax,8
        or ebp,eax
        movzx eax,bl
        movzx eax,byte ptr[r12 + rax]
        movzx ebx,bh
        shl eax,16
        movzx ebx,byte ptr[r12 + rbx]
        or r8d,eax
        shl ebx,24
        or esi,ebx
        movzx eax,cl
        movzx ebx,ch
        movzx eax,byte ptr[r12 + rax]
        shr ecx,16
        movzx ebx,byte ptr[r12 + rbx]
        shl ebx,8
        or ebp,eax
        or r8d,ebx
        movzx eax,cl
        movzx eax,byte ptr[r12 + rax]
        movzx ebx,ch
        movzx ebx,byte ptr[r12 + rbx]
        shl eax,16
        shl ebx,24
        or esi,eax
        or edi,ebx
        movzx eax,dl
        movzx ebx,dh
        movzx eax,byte ptr[r12 + rax]
        shr edx,16
        movzx ebx,byte ptr[r12 + rbx]
        shl ebx,8
        or r8d,eax
        or esi,ebx
        movzx eax,dl
        movzx eax,byte ptr[r12 + rax]
        movzx ebx,dh
        movzx ebx,byte ptr[r12 + rbx]
        shl eax,16
        shl ebx,24
        or edi,eax
        or ebp,ebx
        xor esi,[r10]
        xor edi,[r10+4]
        xor ebp,[r10+8]
        xor r8d,[r10+12]
.endm
.macro AES_ENCRYPT loopLabel
        call SymCryptAesEncryptAsmInternal
.endm
.macro AES_DECRYPT loopLabel
        call SymCryptAesDecryptAsmInternal
.endm
SymCryptAesEncryptAsmInternal: .global SymCryptAesEncryptAsmInternal
.type SymCryptAesEncryptAsmInternal, %function
        AES_ENCRYPT_MACRO SymCryptAesEncryptAsmInternalLoop
ret
SymCryptAesDecryptAsmInternal: .global SymCryptAesDecryptAsmInternal
.type SymCryptAesDecryptAsmInternal, %function
        AES_DECRYPT_MACRO SymCryptAesDecryptAsmInternalLoop
ret
SymCryptAesEncryptAsm: .global SymCryptAesEncryptAsm
.type SymCryptAesEncryptAsm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
sub rsp, 40
        SYMCRYPT_CHECK_MAGIC SymCryptAesEncryptAsmCheckMagic, rdi, magicFieldOffset, rdi
        mov r10, [rdi + lastEncRoundKeyOffset]
        mov r9, rdi
        mov [rsp + 0 ], rdx
        mov eax,[rsi ]
        mov ebx,[rsi + 4]
        mov ecx,[rsi + 8]
        mov edx,[rsi + 12]
        lea r11,[SymCryptAesSboxMatrixMult@plt+rip]
        AES_ENCRYPT SymCryptAesEncryptAsmLoop
        mov rax,[rsp + 0 ]
        mov [rax ], esi
        mov [rax + 4], edi
        mov [rax + 8], ebp
        mov [rax + 12], r8d
add rsp, 40
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptAesDecryptAsm: .global SymCryptAesDecryptAsm
.type SymCryptAesDecryptAsm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
sub rsp, 40
        SYMCRYPT_CHECK_MAGIC SymCryptAesDecryptAsmCheckMagic, rdi, magicFieldOffset, rdi
        mov r9,[rdi + lastEncRoundKeyOffset]
        mov r10,[rdi + lastDecRoundKeyOffset]
        mov [rsp + 0 ], rdx
        mov eax,[rsi ]
        mov ebx,[rsi + 4]
        mov ecx,[rsi + 8]
        mov edx,[rsi + 12]
        lea r11,[SymCryptAesInvSboxMatrixMult@plt+rip]
        lea r12,[SymCryptAesInvSbox@plt+rip]
        AES_DECRYPT SymCryptAesDecryptAsmLoop
        mov rax,[rsp + 0 ]
        mov [rax ], esi
        mov [rax + 4], edi
        mov [rax + 8], ebp
        mov [rax + 12], r8d
add rsp, 40
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptAesCbcEncryptAsm: .global SymCryptAesCbcEncryptAsm
.type SymCryptAesCbcEncryptAsm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
sub rsp, 40
        SYMCRYPT_CHECK_MAGIC SymCryptAesCbcEncryptAsmCheckMagic, rdi, magicFieldOffset, rdi
        and r8, NOT 15
        jz SymCryptAesCbcEncryptNoData
        mov [rsp + 0 ], rsi
        mov rax, rsi
        mov r13, rdx
        mov r15, r8
        mov r14, rcx
        add r15, rdx
        mov r10,[rdi + lastEncRoundKeyOffset]
        mov r12,rdi
        mov esi,[rax ]
        mov edi,[rax + 4]
        mov ebp,[rax + 8]
        mov r8d,[rax + 12]
        lea r11,[SymCryptAesSboxMatrixMult@plt+rip]
.align 16
SymCryptAesCbcEncryptAsmLoop:
        mov eax, [r13]
        mov r9, r12
        mov ebx, [r13+4]
        xor eax, esi
        mov ecx, [r13+8]
        xor ebx, edi
        xor ecx, ebp
        mov edx, [r13+12]
        xor edx, r8d
        add r13, 16
        AES_ENCRYPT SymCryptAesCbcEncryptAsmInnerLoop
        mov [r14], esi
        mov [r14+4], edi
        mov [r14+8], ebp
        mov [r14+12], r8d
        add r14, 16
        cmp r13, r15
        jb SymCryptAesCbcEncryptAsmLoop
        mov rax,[rsp + 0 ]
        mov [rax], esi
        mov [rax+4], edi
        mov [rax+8], ebp
        mov [rax+12], r8d
SymCryptAesCbcEncryptNoData:
add rsp, 40
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptAesCbcDecryptAsm: .global SymCryptAesCbcDecryptAsm
.type SymCryptAesCbcDecryptAsm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
sub rsp, 40
        SYMCRYPT_CHECK_MAGIC SymCryptAesCbcDecryptAsmCheckMagic, rdi, magicFieldOffset, rdi
        and r8, NOT 15
        jz SymCryptAesCbcDecryptNoData
        mov [rsp + 0 ], rsi
        mov [rsp + 8 ], rdx
        lea r14, [r8 - 16]
        lea r15, [rcx + r14]
        add r14, rdx
        mov r13,[rdi + lastEncRoundKeyOffset]
        mov r10,[rdi + lastDecRoundKeyOffset]
        lea r11,[SymCryptAesInvSboxMatrixMult@plt+rip]
        lea r12,[SymCryptAesInvSbox@plt+rip]
        mov eax,[r14]
        mov ebx,[r14+4]
        mov ecx,[r14+8]
        mov edx,[r14+12]
        mov [rsp + 16 ], eax
        mov [rsp + 16 +4], ebx
        mov [rsp + 24 ], ecx
        mov [rsp + 24 +4], edx
        jmp SymCryptAesCbcDecryptAsmLoopEntry
.align 16
SymCryptAesCbcDecryptAsmLoop:
        mov eax,[r14-16]
        mov ebx,[r14-12]
        xor esi,eax
        mov ecx,[r14-8]
        xor edi,ebx
        mov [r15],esi
        mov edx,[r14-4]
        xor ebp,ecx
        mov [r15+4],edi
        xor r8d,edx
        mov [r15+8],ebp
        mov [r15+12],r8d
        sub r14,16
        sub r15,16
SymCryptAesCbcDecryptAsmLoopEntry:
        mov r9, r13
        AES_DECRYPT SymCryptAesCbcDecryptAsmInnerLoop
        cmp r14, [rsp + 8 ]
        ja SymCryptAesCbcDecryptAsmLoop
        mov rbx,[rsp + 0 ]
        xor esi,[rbx]
        xor edi,[rbx+4]
        xor ebp,[rbx+8]
        xor r8d,[rbx+12]
        mov [r15], esi
        mov [r15+4], edi
        mov [r15+8], ebp
        mov [r15+12], r8d
        mov rax,[rsp + 16 ]
        mov rcx,[rsp + 24 ]
        mov [rbx], rax
        mov [rbx+8], rcx
SymCryptAesCbcDecryptNoData:
add rsp, 40
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
SymCryptAesCtrMsb64Asm: .global SymCryptAesCtrMsb64Asm
.type SymCryptAesCtrMsb64Asm, %function
push rbx
push rbp
push r12
push r13
push r14
push r15
sub rsp, 40
        SYMCRYPT_CHECK_MAGIC SymCryptAesCtrMsb64AsmCheckMagic, rdi, magicFieldOffset, rdi
        and r8, NOT 15
        jz SymCryptAesCtrMsb64NoData
        mov [rsp + 0 ], rsi
        mov rax, rsi
        mov r13, rdx
        mov r14, r8
        mov r15, rcx
        add r14, rdx
        mov r10,[rdi + lastEncRoundKeyOffset]
        mov r12,rdi
        lea r11,[SymCryptAesSboxMatrixMult@plt+rip]
        mov rcx, [rax + 8]
        mov rax, [rax ]
        mov [rsp + 8 ], rax
        mov [rsp + 16 ], rcx
        mov rbx, rax
        mov rdx, rcx
        shr rbx, 32
        shr rdx, 32
.align 16
SymCryptAesCtrMsb64AsmLoop:
        mov r9, r12
        AES_ENCRYPT SymCryptAesCtrMsb64AsmInnerLoop
        mov eax,dword ptr [rsp + 8 + 0]
        mov ebx,dword ptr [rsp + 8 + 4]
        mov rcx,[rsp + 16 ]
        bswap rcx
        add rcx, 1
        bswap rcx
        mov [rsp + 16 ], rcx
        mov rdx, rcx
        shr rdx, 32
        xor esi,[r13 + 0 ]
        xor edi,[r13 + 4 ]
        xor ebp,[r13 + 8 ]
        xor r8d,[r13 + 12]
        mov [r15 + 0], esi
        mov [r15 + 4], edi
        mov [r15 + 8], ebp
        mov [r15 + 12], r8d
        add r13, 16
        add r15, 16
        cmp r13, r14
        jb SymCryptAesCtrMsb64AsmLoop
        mov rsi,[rsp + 0 ]
        mov [rsi + 8], ecx
        mov [rsi + 12], edx
        xor rax, rax
        mov [rsp + 8 ], rax
        mov [rsp + 16 ], rax
SymCryptAesCtrMsb64NoData:
add rsp, 40
pop r15
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
