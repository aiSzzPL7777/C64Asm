assembly
        * = $0801
        .word $080b
        .byte $0c, $08, $0a, $00, $00, $9e, $32, $30, $36, $34, $00, $00

        * = $0810

START:
        JSR INIT            ; Inicjalizacja
        JSR MAINLOOP        ; Główna pętla

INIT:
        LDA #$00            ; Ustawienie ekranu na czarno
        STA $D020
        STA $D021
        RTS

MAINLOOP:
        JSR CALC_ROTATION   ; Obliczenie rotacji
        JSR DRAW_CUBE       ; Rysowanie sześcianu
        JMP MAINLOOP        ; Powtarzanie pętli

CALC_ROTATION:
        LDX #0
ROT_LOOP:
        ; Załaduj wierzchołek
        LDA VERTICES, X
        STA TEMP_X
        INX
        LDA VERTICES, X
        STA TEMP_Y
        INX
        LDA VERTICES, X
        STA TEMP_Z
        INX

        ; Obrót w osi X
        LDA TEMP_Y
        SEC
        SBC TEMP_Z
        STA NEW_Y

        LDA TEMP_Y
        CLC
        ADC TEMP_Z
        STA NEW_Z

        ; Zapisz nowe współrzędne
        LDA NEW_Y
        STA VERTICES, X-2
        LDA NEW_Z
        STA VERTICES, X-1

        CPX #24
        BCC ROT_LOOP
        RTS

DRAW_CUBE:
        LDX #0
DRAW_LINE_LOOP:
        LDA LINES, X
        STA TEMP_X
        INX
        LDA LINES, X
        STA TEMP_Y
        INX

        ; Rysowanie linii między TEMP_X i TEMP_Y
        JSR DRAW_LINE

        LDA LINES, X
        CMP #$FF
        BEQ DRAW_END

        JMP DRAW_LINE_LOOP

DRAW_END:
        RTS

DRAW_LINE:
        ; Algorytm Bresenhama do rysowania linii

        LDA TEMP_X
        STA X0
        LDA TEMP_Y
        STA Y0

        LDA TEMP_X+1
        STA X1
        LDA TEMP_Y+1
        STA Y1

        LDX X0
        LDY Y0

        STX CUR_X
        STY CUR_Y

        SEC
        LDA X1
        SBC X0
        BPL X_POSITIVE
        EOR #$FF
        CLC
        ADC #1
        STA DX
        LDA #$FF
        STA SX
        JMP DX_SET

X_POSITIVE:
        STA DX
        LDA #1
        STA SX

DX_SET:
        SEC
        LDA Y1
        SBC Y0
        BPL Y_POSITIVE
        EOR #$FF
        CLC
        ADC #1
        STA DY
        LDA #$FF
        STA SY
        JMP DY_SET

Y_POSITIVE:
        STA DY
        LDA #1
        STA SY

DY_SET:
        LDA DX
        CMP DY
        BCS X_GREATER

        LDA DY
        ASL
        STA ERR

DRAW_LINE_LOOP:
        JSR PLOT_PIXEL
        LDA CUR_Y
        CMP Y1
        BEQ DRAW_LINE_EXIT

        LDA ERR
        CMP DX
        BCC Y_INCREMENT

        LDA ERR
        SEC
        SBC DX
        STA ERR

        LDA CUR_X
        CLC
        ADC SX
        STA CUR_X

Y_INCREMENT:
        LDA ERR
        CLC
        ADC DY
        STA ERR

        LDA CUR_Y
        CLC
        ADC SY
        STA CUR_Y

        JMP DRAW_LINE_LOOP

X_GREATER:
        LDA DX
        ASL
        STA ERR

DRAW_LINE_LOOP_X:
        JSR PLOT_PIXEL
        LDA CUR_X
        CMP X1
        BEQ DRAW_LINE_EXIT

        LDA ERR
        CMP DY
        BCC X_INCREMENT

        LDA ERR
        SEC
        SBC DY
        STA ERR

        LDA CUR_Y
        CLC
        ADC SY
        STA CUR_Y

X_INCREMENT:
        LDA ERR
        CLC
        ADC DX
        STA ERR

        LDA CUR_X
        CLC
        ADC SX
        STA CUR_X

        JMP DRAW_LINE_LOOP_X

DRAW_LINE_EXIT:
        RTS

PLOT_PIXEL:
        LDA CUR_X          ; Załaduj współrzędną X
        STA $FB            ; Przechowaj ją w $FB
        LDA CUR_Y          ; Załaduj współrzędną Y
        STA $FC            ; Przechowaj ją w $FC

        ; Oblicz offset w pamięci ekranu
        LDA $FB
        LSR
        LSR
        LSR
        LSR
        STA $FD

        LDA $FC
        CLC
        ADC $FD
        TAX                ; Przechowaj w X

        ; Oblicz offset w bajcie
        LDA $FB
        AND #$0F
        TAX
        LDA $FC
        ROR
        ROR
        ROR
        ROR
        ORA $D800, X
        STA $D800, X

        RTS

VERTICES:
        .byte -10, -10, -10  ; Wierzchołek 0
        .byte  10, -10, -10  ; Wierzchołek 1
        .byte  10,  10, -10  ; Wierzchołek 2
        .byte -10,  10, -10  ; Wierzchołek 3
        .byte -10, -10,  10  ; Wierzchołek 4
        .byte  10, -10,  10  ; Wierzchołek 5
        .byte  10,  10,  10  ; Wierzchołek 6
        .byte -10,  10,  10  ; Wierzchołek 7

LINES:
        .byte 0, 1
        .byte 1, 2
        .byte 2, 3
        .byte 3, 0
        .byte 4, 5
        .byte 5, 6
        .byte 6, 7
        .byte 7, 4
        .byte 0, 4
        .byte 1, 5
        .byte 2, 6
        .byte 3, 7

        .byte $FF          ; Koniec listy

TEMP_X: .byte 0
TEMP_Y: .byte 0
TEMP_Z: .byte 0
NEW_Y:  .byte 0
NEW_Z:  .byte 0
X0:     .byte 0
Y0:     .byte 0
X1:     .byte 0
Y1:     .byte 0
CUR_X:  .byte 0
CUR_Y:  .byte 0
DX:     .byte 0
DY:     .byte 0
SX:     .byte 0
SY:     .byte 0
ERR:    .byte 0
```
