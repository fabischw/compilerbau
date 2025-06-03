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

macro itos int, counter, buffer
{
local .loop
mov eax, int
mov counter, 0
mov buffer, conversion_buffer+11
mov byte [buffer], 0
mov ebx, 10
.loop:
xor edx, edx
idiv ebx
add dl, '0'
dec buffer
mov [buffer], dl
inc counter
test eax, eax
jnz .loop
}

macro modulo var1, var2, result
{
mov eax, var1
mov ebx, var2
idiv ebx
mov result, edx
}
