macro write fd, buffer, length
{
mov rax, 1
mov rdi, fd
mov rsi, buffer
mov rdx, length
syscall
}

macro exit code
{
mov rax, 60
mov rdi, code
syscall
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
