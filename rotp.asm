section .text
    global rotp

rotp:
    
    push    ebp
    mov     ebp, esp
    pusha

    mov     edx, [ebp + 8]  ; ciphertext
    mov     esi, [ebp + 12] ; plaintext
    mov     edi, [ebp + 16] ; key
    mov     ecx, [ebp + 20] ; len

    ;; The 2 registers are empty at first
    xor     eax, eax
    xor     ebx, ebx

xor_loop:
    ;; I add the bytes of plaintext in al      
    mov     al, byte [esi + ebx]
    ; Then the xor
    xor     al, byte [edi + ecx - 1]
    ; The ciphertext will be formed from each element
    mov     [edx + ebx], al
    inc     ebx
    loop    xor_loop

    popa
    leave
    ret
