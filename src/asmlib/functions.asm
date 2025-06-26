macro print  buffer
{
mov eax, 4
mov ebx, 1
strlen buffer
mov ecx, buffer
int 0x80
}

macro strlen string
{
local .next_char, .done
xor     edx, edx
mov ecx, string
.next_char:
cmp     byte [ecx], 0
je      .done
inc     ecx
inc     edx
jmp     .next_char
.done:
dec edx
}

macro exit code
{
mov eax, 1
mov ebx, code
int 0x80
}


macro tostr int {

    mov eax, int 
    imul eax, 10
    mov edi, conversion_buffer + 11
    mov byte [edi], 0    
    dec edi

    test eax, eax
    jnz .convert
    mov byte [edi], '0'
    dec edi
    jmp .done

.convert:
    xor edx, edx
    mov ebx, 10

.loop:
    xor edx, edx
    div ebx             
    add dl, '0'         
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .loop

.done:
    inc edi             
    mov esi, edi
    mov edi, conversion_buffer
.copy:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    test al, al
    jnz .copy
}


macro modulo var1, var2, result
{
mov eax, var1
mov ebx, var2
idiv ebx
mov result, edx
}
