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
SymCryptFdef369RawAddAsm: .global SymCryptFdef369RawAddAsm
.type SymCryptFdef369RawAddAsm, %function
        inc ecx
        xor rax, rax
SymCryptFdef369RawAddAsmLoop:
        mov rax,[rdi]
        adc rax,[rsi]
        mov [rdx],rax
        mov rax,[rdi + 8]
        adc rax,[rsi + 8]
        mov [rdx + 8], rax
        mov rax,[rdi + 16]
        adc rax,[rsi + 16]
        mov [rdx + 16], rax
        lea rdi, [rdi + 24]
        lea rsi, [rsi + 24]
        lea rdx, [rdx + 24]
        dec ecx
        jnz SymCryptFdef369RawAddAsmLoop
        mov rax, 0
        adc rax, rax
ret
SymCryptFdef369RawSubAsm: .global SymCryptFdef369RawSubAsm
.type SymCryptFdef369RawSubAsm, %function
        inc ecx
        xor rax, rax
SymCryptFdef369RawSubAsmLoop:
        mov rax,[rdi]
        sbb rax,[rsi]
        mov [rdx],rax
        mov rax,[rdi + 8]
        sbb rax,[rsi + 8]
        mov [rdx + 8], rax
        mov rax,[rdi + 16]
        sbb rax,[rsi + 16]
        mov [rdx + 16], rax
        lea rdi, [rdi + 24]
        lea rsi, [rsi + 24]
        lea rdx, [rdx + 24]
        dec ecx
        jnz SymCryptFdef369RawSubAsmLoop
        mov rax, 0
        adc rax, rax
ret
SymCryptFdef369MaskedCopyAsm: .global SymCryptFdef369MaskedCopyAsm
.type SymCryptFdef369MaskedCopyAsm, %function
        inc edx
        movsxd rcx, ecx
SymCryptFdef369MaskedCopyAsmLoop:
        mov rax, [rdi]
        mov r8, [rsi]
        xor rax, r8
        and rax, rcx
        xor rax, r8
        mov [rsi], rax
        mov rax, [rdi + 8]
        mov r8, [rsi + 8]
        xor rax, r8
        and rax, rcx
        xor rax, r8
        mov [rsi + 8], rax
        mov rax, [rdi + 16]
        mov r8, [rsi + 16]
        xor rax, r8
        and rax, rcx
        xor rax, r8
        mov [rsi + 16], rax
        add rdi, 24
        add rsi, 24
        dec edx
        jnz SymCryptFdef369MaskedCopyAsmLoop
ret
SymCryptFdef369RawMulAsm: .global SymCryptFdef369RawMulAsm
.type SymCryptFdef369RawMulAsm, %function
push rbx
push rbp
push r12
mov r10, rdx
        inc esi
        inc ecx
        lea esi, [esi + 2*esi]
        mov r9, r10
        mov r11, r8
        mov rbx, [rdi]
        xor rbp, rbp
        mov r12d, ecx
.align 16
SymCryptFdef369RawMulAsmLoop1:
        mov rax, [r9]
        mul rbx
        add rax, rbp
        adc rdx, 0
        mov [r11], rax
        mov rbp, rdx
        mov rax, [r9 + 8]
        mul rbx
        add rax, rbp
        adc rdx, 0
        mov [r11 + 8], rax
        mov rbp, rdx
        mov rax, [r9 + 16]
        mul rbx
        add rax, rbp
        adc rdx, 0
        mov [r11 + 16], rax
        mov rbp, rdx
        add r9, 24
        add r11, 24
        dec r12d
        jnz SymCryptFdef369RawMulAsmLoop1
        mov [r11], rdx
        dec esi
.align 16
SymCryptFdef369RawMulAsmLoopOuter:
        add rdi, 8
        add r8, 8
        mov rbx, [rdi]
        mov r9, r10
        mov r11, r8
        xor rbp, rbp
        mov r12d, ecx
.align 16
SymCryptFdef369RawMulAsmLoop2:
        mov rax, [r9]
        mul rbx
        add rax, [r11]
        adc rdx, 0
        add rax, rbp
        adc rdx, 0
        mov [r11], rax
        mov rbp, rdx
        mov rax, [r9 + 8]
        mul rbx
        add rax, [r11 + 8]
        adc rdx, 0
        add rax, rbp
        adc rdx, 0
        mov [r11 + 8], rax
        mov rbp, rdx
        mov rax, [r9 + 16]
        mul rbx
        add rax, [r11 + 16]
        adc rdx, 0
        add rax, rbp
        adc rdx, 0
        mov [r11 + 16], rax
        mov rbp, rdx
        add r9, 24
        add r11, 24
        dec r12d
        jnz SymCryptFdef369RawMulAsmLoop2
        mov [r11], rdx
        dec esi
        jnz SymCryptFdef369RawMulAsmLoopOuter
pop r12
pop rbp
pop rbx
ret
SymCryptFdef369MontgomeryReduceAsm: .global SymCryptFdef369MontgomeryReduceAsm
.type SymCryptFdef369MontgomeryReduceAsm, %function
push rbx
push rbp
push r12
push r13
push r14
mov r10, rdx
        mov ecx, [rdi + SymCryptModulusNdigitsOffsetAmd64]
        inc ecx
        mov r8, [rdi + SymCryptModulusInv64OffsetAmd64]
        lea rdi, [rdi + SymCryptModulusValueOffsetAmd64]
        lea r14d, [ecx + 2*ecx]
        xor ebx, ebx
.align 16
SymCryptFdef369MontgomeryReduceAsmOuterLoop:
        mov r9, [rsi]
        mov r12, rsi
        mov rbp, rdi
        imul r9, r8
        mov r13d, ecx
        xor r11d, r11d
.align 16
SymCryptFdef369MontgomeryReduceAsmInnerloop:
        mov rax, [rbp]
        mul r9
        add rax, [r12]
        adc rdx, 0
        add rax, r11
        adc rdx, 0
        mov [r12], rax
        mov r11, rdx
        mov rax, [rbp + 8]
        mul r9
        add rax, [r12 + 8]
        adc rdx, 0
        add rax, r11
        adc rdx, 0
        mov [r12 + 8], rax
        mov r11, rdx
        mov rax, [rbp + 16]
        mul r9
        add rax, [r12 + 16]
        adc rdx, 0
        add rax, r11
        adc rdx, 0
        mov [r12 + 16], rax
        mov r11, rdx
        add rbp, 24
        add r12, 24
        dec r13d
        jnz SymCryptFdef369MontgomeryReduceAsmInnerloop
        add r11, rbx
        mov ebx, 0
        adc rbx, 0
        add r11, [r12]
        adc rbx, 0
        mov [r12], r11
        add rsi, 8
        dec r14d
        jnz SymCryptFdef369MontgomeryReduceAsmOuterLoop
        mov r13d, ecx
        mov r12, rsi
        mov rbp, rdi
        mov r11, r10
.align 16
SymCryptFdef369MontgomeryReduceAsmSubLoop:
        mov rax,[r12]
        sbb rax,[rbp]
        mov [r11], rax
        mov rax,[r12 + 8]
        sbb rax,[rbp + 8]
        mov [r11 + 8], rax
        mov rax,[r12 + 16]
        sbb rax,[rbp + 16]
        mov [r11 + 16], rax
        lea r12,[r12 + 24]
        lea rbp,[rbp + 24]
        lea r11,[r11 + 24]
        dec r13d
        jnz SymCryptFdef369MontgomeryReduceAsmSubLoop
        sbb rbx, 0
.align 16
SymCryptFdef369MontgomeryReduceAsmMaskedCopyLoop:
        mov rax, [rsi]
        mov rdi, [r10]
        xor rax, rdi
        and rax, rbx
        xor rax, rdi
        mov [r10], rax
        mov rax, [rsi + 8]
        mov rdi, [r10 + 8]
        xor rax, rdi
        and rax, rbx
        xor rax, rdi
        mov [r10 + 8], rax
        mov rax, [rsi + 16]
        mov rdi, [r10 + 16]
        xor rax, rdi
        and rax, rbx
        xor rax, rdi
        mov [r10 + 16], rax
        add rsi, 24
        add r10, 24
        dec ecx
        jnz SymCryptFdef369MontgomeryReduceAsmMaskedCopyLoop
pop r14
pop r13
pop r12
pop rbp
pop rbx
ret
