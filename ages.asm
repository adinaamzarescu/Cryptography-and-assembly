struc  my_date
    .day: resw 1
    .month: resw 1
    .year: resd 1
endstruc

section .data
    pointer: times my_date_size * 100 db 0

section .text
    global ages

ages:

    push    ebp
    mov     ebp, esp
    pusha

    mov     edx, [ebp + 8]  ; len
    mov     esi, [ebp + 12] ; present
    mov     edi, [ebp + 16] ; dates
    mov     ecx, [ebp + 20] ; all_ages

year:
    xor     eax, eax
    xor     ebx, ebx
    ;; Year of birth
    mov     ebx, dword [edi + my_date.year + 8 * (edx - 1)]
    ;; Current year
    mov     eax, dword [esi + my_date.year]
    ;; In order to save the age in eax
    sub     eax, ebx
    cmp     eax, 0
    jl      fail
    month:
        ;; Since eax will be changed
        push    eax
        ;; Month of birth
        movzx   eax, word [edi + my_date.month + 8 * (edx - 1)]
        ;; Current month
        movzx   ebx, word [esi + my_date.month]
        cmp     ebx, eax
        pop     eax
        ;; If the current month is the same
        ;; calculates the day
        je      day
        ;; If the current month is lower
        ;; the age is present_year - birth_year - 1
        jl      almost
        ;; If the current month is greater
        ;; the age is present_year - birth_year
        ;; so there is no need for another test
        jg      end
        day:
            ;; Since eax will be changed
            push    eax
            xor     eax, eax
            xor     ebx, ebx
            ;; Day of birth
            movzx   ebx, word [edi + my_date.day + 8 * (edx - 1)]
            ;; Current day
            movzx   eax, word [esi + my_date.day]
            cmp     ebx, eax
            pop     eax
            jg      almost
            jmp     end
almost:
    ;; Same month, but few days before birthday
    sub     eax, 1
    cmp     eax, 0
    jg      end
    not_even_one:
        mov     eax, 0
        jmp     end
fail:
    popa
    leave
    ret 0
end:
    mov     [ecx + 4 * (edx- 1)], eax
    dec     edx
    cmp     edx, 0
    jg      year


    popa
    leave
    ret
