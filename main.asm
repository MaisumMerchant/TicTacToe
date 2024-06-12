.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.DATA
ClassName db "mainClass", 0
AppName db "Tic Tac Toe", 0
ButtonName db "BUTTON", 0
ButtonText db "-", 0
WinLabelText db " ", 0
TurnLabelText db "Player One (X) Turn", 0
playerOneMove DWORD "X"
playerTwoMove DWORD "O"
playerOneWin db "Player One (X) Wins", 0
playerTwoWin db "Player Two (O) Wins", 0
playerOneTurn db "Player One (X) Turn", 0
playerTwoTurn db "Player Two (O) Turn", 0
currentMove DWORD 0
tictactoeGame DWORD 9 DUP ("-")

.DATA?
hInstance HINSTANCE ? 
CommandLine LPSTR ?
hButtons DWORD 9 dup(?)
consoleHandle DWORD ?
written DWORD ?
winLabel DWORD ?
turnLabel DWORD ?

.CODE 

start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke ExitProcess, eax

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL we: WNDCLASSEX
    LOCAL msg: MSG
    LOCAL hwnd: HWND

    mov we.cbSize, SIZEOF WNDCLASSEX 
    mov we.style, CS_HREDRAW or CS_VREDRAW
    mov we.lpfnWndProc, OFFSET WndProc
    mov we.cbClsExtra, NULL
    mov we.cbWndExtra, NULL
    push hInstance
    pop we.hInstance
    mov we.hbrBackground, COLOR_WINDOW+1
    mov we.lpszMenuName, NULL
    mov we.lpszClassName, OFFSET ClassName
    invoke LoadIcon, NULL, IDI_APPLICATION
    mov we.hIcon, eax
    mov we.hIconSm, eax
    invoke LoadCursor, NULL, IDC_ARROW
    mov we.hCursor, eax
    invoke RegisterClassEx, addr we

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ClassName, ADDR AppName, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 208, 342, NULL, NULL, hInst, NULL
    mov hwnd, eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ButtonName, ADDR ButtonText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 10, 10, 50, 50, hwnd, 0, hInst, NULL
    mov hButtons[0*4], eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ButtonName, ADDR ButtonText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 70, 10, 50, 50, hwnd, 1, hInst, NULL
    mov hButtons[1*4], eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ButtonName, ADDR ButtonText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 130, 10, 50, 50, hwnd, 2, hInst, NULL
    mov hButtons[2*4], eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ButtonName, ADDR ButtonText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 10, 70, 50, 50, hwnd, 3, hInst, NULL
    mov hButtons[3*4], eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ButtonName, ADDR ButtonText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 70, 70, 50, 50, hwnd, 4, hInst, NULL
    mov hButtons[4*4], eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ButtonName, ADDR ButtonText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 130, 70, 50, 50, hwnd, 5, hInst, NULL
    mov hButtons[5*4], eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ButtonName, ADDR ButtonText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 10, 130, 50, 50, hwnd, 6, hInst, NULL
    mov hButtons[6*4], eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ButtonName, ADDR ButtonText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 70, 130, 50, 50, hwnd, 7, hInst, NULL
    mov hButtons[7*4], eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ButtonName, ADDR ButtonText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 130, 130, 50, 50, hwnd, 8, hInst, NULL
    mov hButtons[8*4], eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ButtonName, ADDR TurnLabelText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 10, 190, 170, 40, hwnd, 1001, hInst, NULL
    mov turnLabel, eax

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ButtonName, ADDR WinLabelText, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 10, 240, 170, 40, hwnd, 1002, hInst, NULL
    mov winLabel, eax

    invoke ShowWindow, hwnd, CmdShow 
    invoke UpdateWindow, hwnd

    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov consoleHandle, eax

    .WHILE TRUE
        invoke GetMessage, ADDR msg, NULL, 0, 0
        .BREAK .IF (!eax)
        invoke TranslateMessage, ADDR msg
        invoke DispatchMessage, ADDR msg
    .ENDW

    mov eax, msg.wParam
    ret

WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    .IF uMsg == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh 

        imul eax, 4

        .IF tictactoeGame[eax] == "-"

            lea ebx, playerOneMove
            mov edx, currentMove
            and edx, 7
            add currentMove, 4
            add ebx, edx

            mov ecx, [ebx]

            lea ebx, tictactoeGame
            add ebx, eax
            mov [ebx], ecx

            invoke SetWindowText, hButtons[eax], ebx
        
            lea ebx, tictactoeGame
            invoke WriteConsole, consoleHandle, ebx, 4 * 9, ADDR written, NULL
            
            mov edx, currentMove
            and edx, 7

            .IF edx == 0
                lea ebx, playerOneTurn
                invoke SetWindowText, turnLabel, ebx
            .ELSE
                lea ebx, playerTwoTurn
                invoke SetWindowText, turnLabel, ebx
            .ENDIF

            mov edx, tictactoeGame[0*4]
            .IF edx == 'X'
                mov edx, tictactoeGame[1*4]
                .IF edx == 'X'
                    mov edx, tictactoeGame[2*4]
                    .IF edx == 'X'
                        lea ebx, playerOneWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[3*4]
            .IF edx == 'X'
                mov edx, tictactoeGame[4*4]
                .IF edx == 'X'
                    mov edx, tictactoeGame[5*4]
                    .IF edx == 'X'
                        lea ebx, playerOneWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[6*4]
            .IF edx == 'X'
                mov edx, tictactoeGame[7*4]
                .IF edx == 'X'
                    mov edx, tictactoeGame[8*4]
                    .IF edx == 'X'
                        lea ebx, playerOneWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[0*4]
            .IF edx == 'X'
                mov edx, tictactoeGame[3*4]
                .IF edx == 'X'
                    mov edx, tictactoeGame[6*4]
                    .IF edx == 'X'
                        lea ebx, playerOneWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[1*4]
            .IF edx == 'X'
                mov edx, tictactoeGame[4*4]
                .IF edx == 'X'
                    mov edx, tictactoeGame[7*4]
                    .IF edx == 'X'
                        lea ebx, playerOneWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[2*4]
            .IF edx == 'X'
                mov edx, tictactoeGame[5*4]
                .IF edx == 'X'
                    mov edx, tictactoeGame[8*4]
                    .IF edx == 'X'
                        lea ebx, playerOneWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[0*4]
            .IF edx == 'X'
                mov edx, tictactoeGame[4*4]
                .IF edx == 'X'
                    mov edx, tictactoeGame[8*4]
                    .IF edx == 'X'
                        lea ebx, playerOneWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[2*4]
            .IF edx == 'X'
                mov edx, tictactoeGame[4*4]
                .IF edx == 'X'
                    mov edx, tictactoeGame[6*4]
                    .IF edx == 'X'
                        lea ebx, playerOneWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[0*4]
            .IF edx == 'O'
                mov edx, tictactoeGame[1*4]
                .IF edx == 'O'
                    mov edx, tictactoeGame[2*4]
                    .IF edx == 'O'
                        lea ebx, playerTwoWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[3*4]
            .IF edx == 'O'
                mov edx, tictactoeGame[4*4]
                .IF edx == 'O'
                    mov edx, tictactoeGame[5*4]
                    .IF edx == 'O'
                        lea ebx, playerTwoWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[6*4]
            .IF edx == 'O'
                mov edx, tictactoeGame[7*4]
                .IF edx == 'O'
                    mov edx, tictactoeGame[8*4]
                    .IF edx == 'O'
                        lea ebx, playerTwoWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[0*4]
            .IF edx == 'O'
                mov edx, tictactoeGame[3*4]
                .IF edx == 'O'
                    mov edx, tictactoeGame[6*4]
                    .IF edx == 'O'
                        lea ebx, playerTwoWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[1*4]
            .IF edx == 'O'
                mov edx, tictactoeGame[4*4]
                .IF edx == 'O'
                    mov edx, tictactoeGame[7*4]
                    .IF edx == 'O'
                        lea ebx, playerTwoWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[2*4]
            .IF edx == 'O'
                mov edx, tictactoeGame[5*4]
                .IF edx == 'O'
                    mov edx, tictactoeGame[8*4]
                    .IF edx == 'O'
                        lea ebx, playerTwoWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[0*4]
            .IF edx == 'O'
                mov edx, tictactoeGame[4*4]
                .IF edx == 'O'
                    mov edx, tictactoeGame[8*4]
                    .IF edx == 'O'
                        lea ebx, playerTwoWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

            mov edx, tictactoeGame[2*4]
            .IF edx == 'O'
                mov edx, tictactoeGame[4*4]
                .IF edx == 'O'
                    mov edx, tictactoeGame[6*4]
                    .IF edx == 'O'
                        lea ebx, playerTwoWin
                        invoke SetWindowText, winLabel, ebx
                    .ENDIF
                .ENDIF
            .ENDIF

        .ENDIF

    .ELSEIF uMsg == WM_DESTROY
        invoke PostQuitMessage, NULL
    .ELSE
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret 
    .ENDIF

    xor eax, eax
    ret 

WndProc endp

end start