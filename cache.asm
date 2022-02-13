CACHE_LINES  EQU 100
CACHE_LINE_SIZE EQU 8
OFFSET_BITS  EQU 3
TAG_BITS EQU 29 ; 32 - OFSSET_BITS


section .text
    global load
    extern printf
    
load:
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ;; Address of reg
    mov ebx, [ebp + 12] ;; Tags
    mov ecx, [ebp + 16] ;; Cache
    mov edx, [ebp + 20] ;; Address
    mov edi, [ebp + 24] ;; to_replace (index of the cache line that needs to be replaced in case of a cache MISS)
    
    ;; Calculating the tag by shifting with 3 the adress
    xor eax, eax
    mov eax, dword [ebp + 20]
    shr eax, OFFSET_BITS
    mov dword [tag], eax

    ;; OFFSET
    xor ebx, ebx
    ;; For having 111 at the end
    mov ebx, 7
    mov eax, dword [ebp + 20]
    ;; The 3 least significant bits
    and eax, ebx
    ;; Saving the offset
    mov byte [offset], al

    ;; Searching the tag
    xor ecx, ecx
    mov eax, dword [ebp + 12]
    mov ebx, dword [tag]
    
search_tag:
    ;; The current index
    mov eax, ecx
    ;; The size of an element
    mov edx, 4
    mul dl
    mov edx, dword [ebp + 12]
    ;; Getting the element
    add eax, edx
    ;; Comparing the 2 tags
    cmp ebx, [eax]
    ;; If they are equal, the tag is already stored in cache
    je cache_hit
    inc ecx
    cmp ecx, CACHE_LINES
    jb search_tag
    ;; The tag was not found
    jmp cache_miss
   
cache_hit:
    ;; The tag was found
    mov ebx, dword [offset]
    ;; eax will store the index of the tag
    mov eax, ecx
    mov edx, CACHE_LINE_SIZE
    mul dl
    mov edx, dword [ebp + 16]
    add eax, edx
    mov edx, eax

    xor eax, eax
    ;; al will store the byte of the offset's column (edx line)
    mov al, byte [edx + ebx]
    ;; The extracted value from cache
    mov byte [ebp + 8], al
    ;; There is no need to keep going
    jmp stop

cache_miss:
    mov edi, dword [tag]
    shl edi, 3
    mov esi, [ebp + 24]
    mov eax, esi
    mov edx, CACHE_LINE_SIZE
    ;; eax will store to_replace * cache_line_size
    mul dl
    mov ebx, dword [ebp + 16]
    ;; eax will store the adress of the to_replace index
    add eax, ebx
    mov edx, eax

    xor ecx, ecx  
move_from_memory:
    ;; Extracting the octets from memory starting with edi
    ;; and then they will be stored in the cache matrix
    xor ebx, ebx
    ;; Extracting the ecx index octet
    mov bl, byte [edi + ecx]
    ;; Moving it to cache
    mov byte [edx + ecx], bl
    inc ecx
    cmp ecx, CACHE_LINE_SIZE
    jb move_from_memory

    ;; Moving the tag on the to_replace position
    mov edi, dword [tag]
    mov eax, [ebp + 24]
    mov edx, 4
    mul dl
    mov edx, dword [ebp + 12]
    add eax, edx
    mov [eax], edi

    ; Accesing the cache[to_replace][offset] element
    mov eax, [ebp + 24]
    mov edx, CACHE_LINE_SIZE
    ;; eax will store to_replace * cache_line_size
    mul dl
    ;; The starting adress from cache
    mov ebx, dword [ebp + 16]
    ;; eax will store the adress of the to_replace line
    add eax, ebx
    mov cl, byte [offset]
    ;; bl will store the [to_replace][offset] octet
    mov bl, byte [eax + ecx]
    mov eax, [ebp + 8]
    mov byte [eax], bl
    
    popa
    leave
    ret
