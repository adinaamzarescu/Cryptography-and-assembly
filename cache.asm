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

    mov eax, [ebp + 8]  ; address of reg
    mov ebx, [ebp + 12] ; tags
    mov ecx, [ebp + 16] ; cache
    mov edx, [ebp + 20] ; address
    mov edi, [ebp + 24] ; to_replace (index of the cache line that needs to be replaced in case of a cache MISS)
    
    ; Calculam tag-ul pentru adresa de la care vrem sa obtinem date
    ; Acesta il vom obtine printr-o simpla shiftare la dreapta cu 3
    ;pozitii a valorii adresei de unde trebuie sa extragem octetul.
    xor eax, eax
    mov eax, dword [ebp + 20]
    shr eax, OFFSET_BITS
    mov dword [tag], eax; Salvam intr-o variabila valoarea tag-ului

    ;; OFFSET
    xor ebx, ebx
    mov ebx, 7; Pentru a avea 111 pe ultimele pozitii si a putea extrage cei mai
    ;nesemnificativi 3 biti din valoarea adresei
    mov eax, dword [ebp + 20]; Mutam in eax adresa de unde trebuie sa extragem octetul
    and eax, ebx; Facem si intre masca(ebx) si adresa pentru a extrage cei mai 
    ;nesemnificativi 3 biti din aceasta
    mov byte [offset], al; Salvam intr-o variabila valoarea offset-ului

    ;Cautam tag-ul calculat in vectorul tags
    xor ecx, ecx; Folosim ecx pe post de i(increment)
    mov eax, dword [ebp + 12]; Punem in registrul eax adresa de plecare pentru vectorul tags.
    mov ebx, dword [tag]; Punem in registrul ebx tag-ul calculat mai devreme.
    
search_tag:
    mov eax, ecx; Punem in eax valoarea contorului curent
    mov edx, 4; Punem in edx dimensiunea unui element din vectorul de tags
    mul dl; Avem in eax valoarea 4*index
    mov edx, dword [ebp + 12]; Punem in edx adresa de plecare pentru vectorul tags(baza)
    add eax, edx; Adunam la 4 * index valoarea de plecare pentru tags pentru a obtine elementul
    ; de pe pozitia index
    cmp ebx, [eax]; Comparam valoarea tag-ului calculat de noi cu valoarea de la adresa calculata
    ; in eax
    je cache_hit; Daca cele doua valori sunt egale in seamna ca tag-ul calculat se afla deja in
    ; vectorul de tags ceea ce inseamna ca datele au mai fost o data incarcate in cache deci va
    ; trebui sa efectuam un cache_hit(doar sa extragem octetul din cache)
    inc ecx; Incrementam contorul
    cmp ecx, CACHE_LINES; Comparam contorul cu numarul de elemente ale vectorului tags, care coincide
    ; cu numarul de linii ale matricei cache
    jb search_tag; Ne intoarcem din nou la search_tag pentru a verifica urmatorul element din tags
    jmp cache_miss; Daca am ajuns aici inseamna ca nu am gasit tag-ul in vectorul tags ceea ce 
    ; inseamna ca avem de efectuat un cache_miss
   
cache_hit:
    ;Inseamna ca am gasit index-ul la care am gasit tag-ul in vectorul tags
    ;Numarul liniei se afla in ecx
    ;Va trebui sa luam din memorie offset-ul calculat la inceput
    ;si trebuie sa punem in addr_reg = cache[i][offset], unde i = ecx
    mov ebx, dword [offset]; Punem in ebx valoarea offset-ului calculat
    mov eax, ecx; Punem in eax index-ul din vectorul de tags la care am gasit tag-ul nostru
    mov edx, CACHE_LINE_SIZE; Punem in edx numarul de elemente de pe o linie a matricei cache
    mul dl; In eax avem index_linie*dimensiune_linie
    mov edx, dword [ebp + 16]; Punem in edx adresa de plecare pentru matricea cache
    add eax, edx; Adunam adresa de plecare pentru matricea cache cu index_linie * dimensiune_linie
    ; pentru a obtine adresa liniei cu index-ul: index_linie din matricea cache
    mov edx, eax; mutam aceasta adresa in edx

    xor eax, eax; Resetam eax-ul
    mov al, byte [edx + ebx]; Punem in al byte-ul de pe coloana ebx(offset) de pe linia edx
    mov byte [ebp + 8], al; Punem in registru valoarea extrasa din cache
    jmp stop; Sarim direct la stop pentru ca nu mai avem nevoie sa incarcam date in cache din memorie

cache_miss:
    mov edi, dword [tag]; Tag-ul
    shl edi, 3; Adresa de plecare(de aici vom incepe sa aducem octeti din memorie in cache)
    mov esi, [ebp + 24]; to_replace
    mov eax, esi; In avem to_replace
    mov edx, CACHE_LINE_SIZE; In edx avem cache_line_size
    mul dl; In eax vom avea to_replace * cache_line_size
    mov ebx, dword [ebp + 16]; In ebx vom avea adresa de plecare pentru cache
    add eax, ebx; In eax vom avea adresa liniei cu index-ul to_replace din cache
    mov edx, eax; Mutam in edx

    ; In loop-ul urmator vom extrage octetii din memorie pornind de la adresa
    ;de plecare definita anterior in edi si ii vom pune pe linia corespunzatoare
    ;in matricea cache
    xor ecx, ecx  
move_from_memory:
    xor ebx, ebx
    mov bl, byte [edi + ecx]; Extragem octetul cu index-ul ecx(avand ca baza adresa de plecare)
    mov byte [edx + ecx], bl; Luam octetul extras din memorie in bl si il inseram pe linia din cache
    inc ecx; Incrementam contorul
    cmp ecx, CACHE_LINE_SIZE; Avem de luat 8 octeti din memorie(dimensiunea unei linii din cache)
    jb move_from_memory

    ;Punem tag-ul pe pozitia to_replace in vectorul de tags
    ;Trebuie sa accesam tags[to_replace]
    mov edi, dword [tag]
    mov eax, [ebp + 24]; to_replace in eax
    mov edx, 4; Punem in edx 4
    mul dl; In eax vom avea to_replace * 4
    mov edx, dword [ebp + 12]; Punem in edx adresa de plecare pentru tags
    add eax, edx; Adunam la eax edx
    mov [eax], edi; Punem in valoarea de la adresa eax tag-ul calculat de noi

    ; Acum avem datele incarcate in cache si tag-ul in vectorul tags
    ; Mai trebuie sa accesam elementul cache[to_replace][offset]
    mov eax, [ebp + 24]; to_replace
    mov edx, CACHE_LINE_SIZE; In edx avem cache_line_size
    mul dl; In eax vom avea to_replace * cache_line_size
    mov ebx, dword [ebp + 16]; In ebx vom avea adresa de plecare pentru cache
    add eax, ebx; In eax vom avea adresa liniei cu index-ul to_replace din cache
    mov cl, byte [offset]; Mutam in cl valoarea offset-ului
    mov bl, byte [eax + ecx]; Mutam in bl valoarea octetului cu coordonatele [to_replace][offset]
    mov eax, [ebp + 8]; Punem in eax registrul unde trebuie sa inseram octetul.
    mov byte [eax], bl; Punem in registru octetul extras din cache
    
    popa
    leave
    ret
