section .text
global linear_regression_asm


linear_regression_asm:
    ; Function prologue
    push    rbp
    mov     rbp, rsp

    ; Arguments:
    ; rdi = x array
    ; rsi = y array
    ; rdx = n
    ; rcx = pointer to slope
    ; r8  = pointer to intercept

    push rcx ; preserve rcx value

    xorps xmm0, xmm0     ; sum_xy
    xorps xmm1, xmm1     ; sum_x 
    xorps xmm2, xmm2     ; sum_y
    xorps xmm3, xmm3     ; sum_x_squared

    xor rcx, rcx
    start_loop:
        cmp rcx, rdx
        je end_loop

        movss xmm4, DWORD [rdi + 4*rcx] 
        movss xmm5, DWORD [rsi + 4*rcx]
        mulss xmm4, xmm5
        addss xmm0, xmm4    ; result of sum_xy

        addss xmm1, DWORD [rdi + 4*rcx] ; result of sum_x
        addss xmm2, DWORD [rsi + 4*rcx] ; result of sum_y

        movss xmm6, DWORD [rdi + 4*rcx] 
        mulss xmm6, xmm6
        addss xmm3, xmm6 ; result of sum_x_squared

        inc rcx
        jmp start_loop

    end_loop:
        cvtsi2ss xmm7, rdx  ; xmm7 holds n converted to float

        mulss xmm0, xmm7
        movss xmm8, xmm1
        mulss xmm8, xmm2
        subss xmm0, xmm8
        
        mulss xmm3, xmm7
        movss xmm8, xmm1
        mulss xmm8, xmm8
        subss xmm3, xmm8

        divss xmm0, xmm3
        pop rcx
        movss [rcx], xmm0   ; slope

        mulss xmm0, xmm1
        subss xmm2, xmm0
        divss xmm2, xmm7
        movss [r8], xmm2    ; intercept

    ; Function epilogue
    pop     rbp
    ret
