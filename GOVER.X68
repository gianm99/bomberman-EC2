; =============================================================================
; GAME OVER MANAGEMENT
; =============================================================================

; -----------------------------------------------------------------------------
GOVPLOT
; PLOTS THE GAME OVER SCREEN
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L A0/D0-D7,-(A7)
            MOVE.L  #$00FFFFFF,D1
            MOVE.B  #80,D0
            TRAP    #15                     ; PEN TO WHITE
            CLR.L   D1
            ADDQ.B  #1,D0
            TRAP    #15                     ; FILL TO BLACK
            LEA     STRGOV0,A1
            MOVE.W  #200,D2
            JSR     .PRTCTR
            LEA     STRGOV1,A1
            MOVE.W  #400,D2
            JSR     .PRTCTR
            MOVEM.L (A7)+,A0/D0-D7
            RTS
.PRTCTR     JSR     UTLSTRLN                ; COMPUTE THE STRING LENGTH
            MOVE.W  D0,D3
            MULU.W  #GENCHRW,D3             ; CONVERT TO PIXELS
            JSR     GENCENTX                ; GET CENTERED COORDINATE
            MOVE.B  #95,D0
            TRAP    #15
            RTS



*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
