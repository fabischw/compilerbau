macro if var1, comparator, var2, body, else
{
mov eax, var1
mov ebx, var2
cmp eax, ebx
comparator body
jmp else
}

macro while var1, comparator, var2, body
{
local .exit, .loop
.loop:
mov eax, var1
mov ebx, var2
cmp eax, ebx
comparator .exit
call body
jmp .loop
.exit:
; invert comparator ???
}
