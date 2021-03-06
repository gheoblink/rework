; ����������� ���������, ������� ������ ���������� ������ A[N],
; ��������� �� ��������� ������� A ����� ������ B �� ��������, ��������� � �������, � ������� ���. 
; ������ ��� ������� ����� ���������� ��� ����������, ��� � ����������� �� ������ ������������.

; ������� 23 % 20 = 3: ������ � �� ���� �������� ��������� A ({A[0] + A[1], A[1] + A[2], ...}).
; ������ �������� ������� ���� ���193.

format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable     ; ������ ������
        ru db 'Russian', 0

        strVecSize     db '������� ������ �������: ', 0
        strSizeException   db '�������� ������ �������           ', 0
        strVecElemI    db '������� [%d] ������� �������: ', 10, 0          ; ������ ��� ������ � �������
        strScanInt     db '%d', 0
        strScanLine    db '%s', 0
        strResult      db 10,'������ �������� ���� ��������� ��������� �������:', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0
        strEnding      db '��� ���������� ������� ����� ������ ����, ����� - ������, ���� ����� ����: ', 0

        i            dd ?
        j            dd 0
        tmp          dd ?              ; ��������� � ��������� ����������
        tmpStack     dd ?

        vec          rd 100            ; �������� ������
        vec_size     dd 0

        vecRes       rd 100            ; ������-���������
        vecRes_size  dd 0

;--------------------------------------------------------------------------
section '.code' code readable executable   ; ������ ������������ ����

start:
        cinvoke setlocale, 0, ru       ; ������������� ������� ������

        call VectorInput               ; ��������� ������
        call SumsVector                ; ��������� ������
        call VectorOut                 ; ������� ��������

finish:
        call [getch]

        push 0                        ; ���������� ���������
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]                 ; ������ ������ ����� �������
        add esp, 4

        push vec_size
        push strScanInt               ; ��������� ����� �������
        call [scanf]
        add esp, 8

        mov eax, [vec_size]           ; ��������� ������������ ����� �������
        cmp eax, 1                    ; ���� ������������� �����, ��������� ��������
        jg  getVector

        push strSizeException
        call [printf]                 ; ���� <=0, ������� ��������� � ��������� �������
        jmp endOutputVector
      ;  push 0
      ;  call [ExitProcess]

getVector:
        xor ecx, ecx             ; ecx = 0        �������� �������-��������
        mov ebx, vec             ; ebx = &vec     ������ ������ �� ������ � �������

getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; ��������� ����, ���� ������ ����� �� �������

        mov [i], ecx
        push ecx
        push strVecElemI         ; ������ ������ ���� �������
        call [printf]
        add esp, 8

        push ebx
        push strScanInt          ; ��������� ���� �������
        call [scanf]
        add esp, 8

        mov ecx, [i]             ; ����������� �������� ���������
        inc ecx
        mov ebx, [tmp]           ; ������ �������� � c���
        add ebx, 4               ; ���������� ��������� �����
        jmp getVecLoop           ; ���� � ������ �����

endInputVector:
        ret                      ; ������� �� �����
;--------------------------------------------------------------------------
SumsVector:
        xor ecx, ecx            ; ecx = 0         �������� �������-�������� ��� ��������� �������
        mov ebx, vec            ; ebx = &vec      ������ ������ �� �������� ������ � �������

        mov edx, vecRes         ; edx = &vecRes   ������ ������ �� �������������� ������ � �������
        dec [vec_size]          ; vec_size--      ����� ������� B �� 1 ������, ��� ����� ������� A


        mov [i], ecx
SumsVecLoop:
        mov ecx, [i]
        cmp ecx, [vec_size]
        je endSumsVector        ; ���� ����� �� ����� ��������� ������� - ��������� ����

        mov eax, [ebx]
        mov [j], eax

        add ebx, 4

        mov eax, [ebx]          ; ������ �������� � �������������� ������
        add eax, [j]
        sub ebx, 4

        mov [edx], eax

        add edx, 4              ; ���������� ��������� �� ������� �������
        add ebx, 4

        inc [i]                 ; ����������� ��������

        jmp SumsVecLoop         ; ������������ � ������ �����

endSumsVector:
        mov eax, [vec_size]     ; ���������� ������
        mov [vecRes_size], eax
        ret                     ; ������� �� ���������
;--------------------------------------------------------------------------
VectorOut:
        push strResult
        call [printf]           ; ������� ���������
        add esp, 4

        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0          �������� �������-�������� ��� ��������������� �������
        mov ebx, vecRes         ; ebx = &vecRes    ���������� ��������� �� �������������� ������ � �������
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [vecRes_size]  ; ������� �� �����, ����� ����� �� ����� �������
        je endOutputVector

        mov [i], ecx

        push dword [ebx]
        push ecx
        push strVecElemOut      ; ������� �������
        call [printf]

        mov ecx, [i]            ; ����������� �������� ���������
        inc ecx
        mov ebx, [tmp]          ; ������� ��������� �� ������� �������
        add ebx, 4
        jmp putVecLoop          ; ��������� � ������ �����

endOutputVector:
        push strEnding
        call [printf]                 ; ������ ������ ����� � ��������� ������ ���������

        push j
        push strScanInt               ; ��������� �����
        call [scanf]
        cmp [j], 0
        jle start                      ; ���� ���������� �������
        ret                           ; ������� �� ���������
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\                               ; ����������� ������ ���������
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           setlocale, 'setlocale',\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'