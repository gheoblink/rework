


format PE Console

entry start

include 'win32a.inc'

section '.data' data readable writable

        strNum          db 'Enter number: ', 0                                   ;строки для ввода в консоль
        resStr          db 'The number of primes before the entered: %d', 0
        emptyStr        db '%d', 0
        strEnding       db '            If you want repeat enter n>0, otherwise  n<=0: ', 0

        scanNum dd ?                  ;Итераторы и контейнеры
        counter dd 0
        j       dd 0


;--------------------------------------------------------------------------
section '.code' code readable executable

        start:

        push strNum
        call [printf]
        add esp, 4


        push scanNum
        push emptyStr
        call [scanf]
        add esp, 8

;--------------------------------------------------------------------------
startPrime:                                     ;проверка простоты числел от 1 до n
        mov ebx, 2
        lp:
                mov ecx, 1
                jmp isPrime
                postlp:
                inc ebx

                cmp ebx, [scanNum]
                jle lp
        finish:


        invoke printf, resStr, [counter]

        push strEnding
        call [printf]                   ; Просим ввести ответ о повторной работе программы

        push j
        push emptyStr                   ; Считываем ответ
        call [scanf]
        cmp [j], 0
        jg start                        ; Цикл повторения решения

        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
isPrime:
        inc [counter]         ;проверка числа на простоту, методом перебора возможных делителей
        stpr:
                inc ecx

                cmp ecx, ebx ;postlp
                jge postlp

                xor edx, edx
                mov eax, ebx
                div ecx

                cmp edx, 0 ;ost
                je notPrime


                jmp stpr

notPrime:
        dec [counter]
        jmp postlp

;--------------------------------------------------------------------------
section '.idata'  import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\                                          ; Подключение нужных библиотек
               ExitProcess, 'ExitProcess'
        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'