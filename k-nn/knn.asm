section .text
global knn_asm

sort:
    mov rcx, 1 ; rcx = i
    .outer_loop:
        cmp rcx, rsi
        jge .end_outer_loop

        mov rax, rcx
        shl rax, 5
        movsd xmm1, QWORD [rdi + rax] ; key[0]
        movsd xmm2, QWORD [rdi + rax + 8] ; key[1]
        movsd xmm3, QWORD [rdi + rax + 16] ; key[2]
        movsd xmm4, QWORD [rdi + rax + 24] ; key[3]

        mov rbx, rcx
        dec rbx ; rbx = j

        .inner_loop:
            test rbx, rbx
            js .end_inner_loop

            mov rax, rbx
            shl rax, 5
            movsd xmm5, QWORD [rdi + rax + 16] ; points[j][2]

            comisd xmm5, xmm3
            jbe .end_inner_loop

            mov rax, rbx
            shl rax, 5
            movsd xmm6, QWORD [rdi + rax] ; points[j][0]
            movsd xmm7, QWORD [rdi + rax + 8] ; points[j][1]
            movsd xmm8, QWORD [rdi + rax + 16] ; points[j][2]
            movsd xmm9, QWORD [rdi + rax + 24] ; points[j][3]

            inc rbx
            mov rax, rbx
            dec rbx
            shl rax, 5
            movsd QWORD [rdi + rax], xmm6
            movsd QWORD [rdi + rax + 8], xmm7
            movsd QWORD [rdi + rax + 16], xmm8
            movsd QWORD [rdi + rax + 24], xmm9     

            dec rbx
            jmp .inner_loop

        .end_inner_loop:

            inc rbx
            mov rax, rbx
            shl rax, 5         
            movsd QWORD [rdi + rax], xmm1
            movsd QWORD [rdi + rax + 8], xmm2
            movsd QWORD [rdi + rax + 16], xmm3
            movsd QWORD [rdi + rax + 24], xmm4


            inc rcx
            jmp .outer_loop

    .end_outer_loop:
        ret

knn_asm:
    ; Function prologue
    push rbp
    mov rbp, rsp

    ; Arguments:
    ; rdi = points[][4]
    ; rsi = n
    ; rdx = k
    ; rcx = pointer to point to classify

    mov r9, rcx ; r9 contains the point to be classified

    .distances:
        xor rcx, rcx
        .distances_loop:
            cmp rcx, rsi
            je .end_distances_loop

            xor rax, rax
            add rax, 32 
            imul rax, rcx
            
            xorps xmm1, xmm1    ; arr[i][0]
            movsd xmm1, QWORD [rdi + rax]

            add rax, 8
            xorps xmm2, xmm2    ; arr[i][1]
            movsd xmm2, QWORD [rdi + rax]

            xorps xmm3, xmm3    ; p[0]
            movsd xmm3, QWORD [r9]
            xorps xmm4, xmm4    ; p[1]
            movsd xmm4, QWORD [r9 + 8]
            
            ; xmm5 -> (arr[i][0] - p[0]) ^ 2
            comisd xmm1, xmm3
            jl .first_calc_lower
            
            movsd xmm5, xmm1
            subsd xmm5, xmm3

            .first_calc_lower:
            movsd xmm5, xmm3
            subsd xmm5, xmm1
            
            mulsd xmm5, xmm5

            ; xmm6 -> (arr[i][1] - p[1]) ^ 2

            comisd xmm2, xmm4
            jl .second_calc_lower
          
            movsd xmm6, xmm2
            subsd xmm6, xmm4

            .second_calc_lower:
            movsd xmm6, xmm4
            subsd xmm6, xmm2

            mulsd xmm6, xmm6

            addsd xmm5, xmm6 
            sqrtpd xmm5, xmm5 ; xmm5 -> euclidian distance

            add rax, 8
            movsd QWORD [rdi + rax], xmm5 ; update the distance of the current point in the array
            inc rcx
            jmp .distances_loop

        .end_distances_loop:
            
            push rcx
            push rbx
            call sort
            pop rcx
            pop rbx


    .classify:

        xor r8, r8 ; freq0
        xor r9, r9 ; freq1

        xor rcx, rcx
        .classify_loop:
            cmp rcx, rdx    ; compare to k
            je .end_loop

            xor rax, rax
            add rax, 32 
            imul rax, rcx
            add rax, 24

            movsd xmm1, QWORD [rdi + rax]   ; arr[i][3]

            xorps xmm2, xmm2
            comiss xmm1, xmm2
            je .inc_freq0

            .inc_freq1:
                inc r9
                inc rcx
                jmp .classify_loop


            .inc_freq0:
                inc r8
                inc rcx
                jmp .classify_loop
            
        .end_loop:
            cmp r8, r9
            jg .return_0
            jmp .return_1

    .return_0:
        xor rax, rax
        jmp .end
    .return_1:
        xor rax, rax
        add rax, 1
        jmp .end

    .end:
        pop rbp
        ret