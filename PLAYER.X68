; =============================================================================
; PLAYER MANAGEMENT
; =============================================================================

; -----------------------------------------------------------------------------
PLRINIT
; INITIALIZES THE PLAYER
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.W  #PLRSTNM,PLRSTAT        ; NORMAL MODE
            MOVE.W  #PLRXINI,(PLRPOSX)      ; INITIAL X
            MOVE.W  #PLRYINI,(PLRPOSY)      ; INITIAL Y
            MOVE.W  #PLRFACED,(PLRFACE)     ; INITIALLY LOOKING DOWN
            MOVE.W  #PLRSPEDC,(PLRSPED)     ; X AND Y SPEED WHEN MOVING
            MOVE.L  #PLRFACEL<<16+PLRFACER,(PLRFRMH) ; PREPARE GRAPHIC
            MOVE.L  #PLRFACEU<<16+PLRFACED,(PLRFRMV) ; FRAME DATA
            CLR.B   (PLRMOT)                ; NO DESIRED MOTION
            MOVE.W  #PLRLIFEI,(PLRLIFE)     ; INITIAL LIFE
            MOVE.B  #$FF,(PLRTYPE)          ; FIXED TYPE
            RTS
; -----------------------------------------------------------------------------
PLRUPD
; UPDATES THE PLAYER MOTION
; INPUT     - NONE (ACCESSES KBDVAL AND KBDEDGE)
; OUTPUT    - NONE (MODIFIES PLAYER DATA)
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D6/A2,-(A7)
            LEA     PLRDBLK,A2              ; GET PLAYER DATA BLOCK
            MOVE.B  (KBDVAL),D0             ; PREPARE MOTION COMMAND BY USING THE
            AND.B   #(KBDMSKLF+KBDMSKUP+KBDMSKRT+KBDMSKDN),D0 ; ARROW KEYS FROM KBDVAL
            MOVE.B  D0,(PLRMOT)
            JSR     AGNMOVE                 ; MOVE HORIZONTALLY OR VERTICALLY
            BTST.B  #KBDBITF1,(KBDEDGE)
            BEQ     .NORMAL
            MOVE.W  PLRPOSX,D1
            ADD.W   #AGNWIDTH/2,D1
            ADD.W   #AGNHEIGH/2,D2
            MOVE.W  PLRPOSY,D2
            JSR     BOMBINIT
.NORMAL     MOVE.W  (PLRPOSX),D5
            MOVE.W  (PLRPOSY),D6
            ADD.W   #AGNWIDTH/2,D5
            ADD.W   #AGNHEIGH/2,D6
            JSR     BOMBRNG                 ; PLAYER IN EXPLOSION RANGE?
            CMP.B   #BOMBNIR,D7
            BEQ     .CHKGM                    ; IF NOT, CONTINUE
            MOVE.W  #BOMBDMG,D0
            JSR     PLRSUBLF
.CHKGM      MOVE.W  PLRSTAT,D0             
            CMP.W   #PLRSTGM,D0             ; IS GHOST MODE ON?
            BNE     .END                    ; NO: END
            MOVE.B  PLRTIM,D0               ; YES: CHECK IF TIME IS OVER
            ADD.B   #PLRGMTIM,D0
            CMP.B   GENFRMCT,D0
            BNE     .END                    ; IF NOT, END
            MOVE.W  #PLRSTNM,PLRSTAT        ; ELSE, END GHOST MODE
            CLR.B   PLRTIM
.END        MOVEM.L (A7)+,D0-D6/A2
            RTS

; -----------------------------------------------------------------------------
PLRPLOT
; PLOTS THE PLAYER AND ITS LIFE
; INPUT     - NONE
; OUTPUT    - NONE
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D4/A2,-(A7)
            
            LEA     PLRDBLK,A2              ; GET THE AGENT POINTER
            MOVE.W  PLRSTAT,D0              ; CHECK IF GHOST MODE ON
            CMP.W   #PLRSTNM,D0
            BEQ     .NOGM                   ; IF NO GHOST MODE, CONTINUE
            MOVE.B  #92,D0                  ; SET TRANSPARENT MODE (OR)
            MOVE.B  #10,D1
            TRAP    #15
.NOGM       JSR     AGNPLOT                 ; PLOT THE AGENT
            MOVE.B  #92,D0                  ; RETURN TO NORMAL MODE
            MOVE.B  #4,D1
            TRAP    #15
            
            MOVE.B  #80,D0                  ; SET PEN COLOR
            MOVE.L  #PLRSCOCB,D1            ; BLACK
            TRAP    #15
            ADDQ.B  #1,D0                   ; SET FILL COLOR
            MOVE.L  #$000000FF,D1           ; RED
            TRAP    #15
            MOVE.B  #87,D0                  ; DRAW RED RECTANGLE
            MOVE.W  #(MAPWIDTH-1)*MAPTILEW,D1 ;LEFT X
            MOVE.W  #0,D2                   ; UPPER Y
            MOVE.W  #MAPWIDTH*MAPTILEW,D3   ; RIGHT X
            MOVE.W  #MAPHEIGH*MAPTILEH,D4   ; LOWER Y
            TRAP    #15
            MOVE.B  #81,D0                  ; SET FILL COLOR
            MOVE.L  #PLRSCOCF,D1            ; GREEN
            TRAP    #15
            MOVE.B  #87,D0                  ; PLOT LIFE
            MOVE.W  #(MAPWIDTH-1)*MAPTILEW,D1 ; LEFT X
            MOVE.W  #PLRLIFEI,D2            ; PREPARE CALCULATION
            SUB.W   PLRLIFE,D2              ; UPPER Y
            MOVE.W  #MAPWIDTH*MAPTILEW,D3   ; RIGHT X
            MOVE.W  #MAPHEIGH*MAPTILEH,D4   ; LOWER Y
            TRAP    #15
            MOVEM.L (A7)+,D0-D4/A2
            RTS
            
; -----------------------------------------------------------------------------
PLRSUBLF
; SUBSTRACTS LIFE TO THE PLAYER AND ENABLES GHOST MODE
; INPUT    - D0.W   AMOUNT TO SUBSTRACT
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            TST.W   PLRSTAT                 ; CHECK IF NORMAL MODE ON
            BNE     .END                    ; IF NOT, END
            MOVE.W  #PLRSTGM,PLRSTAT        ; SET GHOST MODE ON
            MOVE.B  GENFRMCT,PLRTIM         ; SAVE INITIAL TIME
            SUB.W   D0,PLRLIFE              ; SUBSTRACT LIFE
.END        RTS
            
            












*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
