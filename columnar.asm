section .data
    extern len_cheie, len_haystack

section .text
    global columnar_transposition

columnar_transposition:
    push    ebp
    mov     ebp, esp
    pusha 

    mov     edi, [ebp + 8]   ;  key
    mov     esi, [ebp + 12]  ;  haystack
    mov     ebx, [ebp + 16]  ;  ciphertext

    ;; First of all I free the registers
    xor     ecx, ecx
    xor     eax, eax
    xor     edx, edx

    ;; Since I will use [ebp + 12]
    ;; I will also free the esi register
    xor     esi, esi

    row_loop:
        mov     ecx, 0
        column_loop: 
            mov     eax, [len_cheie]
            ;; For each column (ecx)
            mov     edx, ecx
            mul     edx
            mov     edx, esi
            add     eax, [edi + edx * 4]
            ;; If eax exits the haystack
            ;; the program will move to the next row
            cmp     eax, [len_haystack]
            jge     move_to_next

            ;; If eax is still lower than len_haystack
            ;; ebx will be formed
            add     eax, [ebp + 12]
            mov     dl, [eax]
            mov     [ebx], dl
            inc     ebx
            inc     ecx
            
            mov     eax, ecx
            imul    eax, [len_cheie]
            ;; While eax doesn't exit the haystack
            ;; the program will loop
            cmp     eax, [len_haystack]
            jl      column_loop

    ;; This label loops for rows
    move_to_next:
        inc     esi
        mov     eax, esi
        mov     edx, [len_cheie]
        cmp     eax, edx
        jl      row_loop

    popa
    leave
    ret
