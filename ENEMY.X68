; =============================================================================
; ENEMY MANAGEMENT
; =============================================================================

; -----------------------------------------------------------------------------
ENMINIT
; INITIALIZES THE ENEMY
; INPUT    - A0 POINTER TO THE AGENT DATA BLOCK
;            D1.L HIGH 16 BITS INITIAL Y. LOW 16 BITS INITIAL X
;            D2.L HIGH 16 BITS TYPE, LOW 16 BITS SPEED
;            D3.L HIGH 16 BITS LEFT BASE FRAME. LOW 16 BITS RIGHT BASE FRAME
;            D4.L HIGH 16 BITS UP BASE FRAME. LOW 16 BITS DOWN BASE FRAME
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.W  D4,AGNFRAOF(A0)         ; STORE DOWN BASE FRAME
            MOVE.L  D3,AGNFRMLR(A0)         ; STORE THE LEFT/RIGHT FRAMES LONG
            MOVE.L  D4,AGNFRMUD(A0)         ; STORE THE UP/DOWN FRAMES LONG
            MOVE.W  D1,AGNPOXOF(A0)         ; WRITE INITIAL X
            SWAP    D1                      ; PREPARE INITIAL Y
            MOVE.W  D1,AGNPOYOF(A0)         ; STORE INITIAL Y
            MOVE.W  D2,AGNSPEDC(A0)         ; STORE SPEED
            SWAP    D2                      ; PREPARE TYPE
            MOVE.B  D2,AGNTYPOF(A0)         ; STORE TYPE
            CLR.B   AGNMOTOF(A0)            ; PUT NO MOTION
            SWAP    D1                      ; RESTORE D1
            SWAP    D2
            RTS

; -----------------------------------------------------------------------------
ENMUPD
; UPDATES THE ENEMY MOTION
; INPUT    - A0 POINTER TO THE AGENT DATA BLOCK
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------

            MOVEM.L D0/D7/A2,-(A7)
            MOVE.L  A0,A2                   ; PREPARE AGENT DATA BLOCK
            JSR     AGNMOVE                 ; UPDATE MOTION
            JSR     ENMPLCOL                ; CHECK COLLISION
            
            MOVE.B  (GENFRMCT),D7
            AND.B   #$1F,D7
            BNE     .END                    ; CHANGE MOTION EVERY 32 FRAMES
            JSR     UTLRAND
            CMP.W   #51,D0                  ; 20% CHANCE OF STOPPING
            BLE     .STOP
            CMP     #102,D0                 ; 20% CHANCE OF MOVING UP
            BLE     .UP
            CMP.W   #153,D0                 ; 20% CHANCE OF MOVING DOWN
            BLE     .DOWN
            CMP.W   #204,D0                 ; 20% CHANCE OF MOVING LEFT
            BLE     .LEFT
.RIGHT      MOVE.B  #KBDMSKRT,AGNMOTOF(A0)  ; 20% CHANCE OF MOVING RIGHT
            BRA     .END
.LEFT       MOVE.B  #KBDMSKLF,AGNMOTOF(A0)
            BRA     .END
.DOWN       MOVE.B  #KBDMSKDN,AGNMOTOF(A0)
            BRA     .END
.UP         MOVE.B  #KBDMSKUP,AGNMOTOF(A0)
            BRA     .END
.STOP       CLR.B   AGNMOTOF(A0)
.END        JSR     ENMBOMB
            MOVEM.L (A7)+,D0/D7/A2
            RTS

; -----------------------------------------------------------------------------
ENMPLOT
; PLOTS THE ENEMY
; INPUT    - A0 POINTER TO THE AGENT DATA BLOCK
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.L  A2,-(A7)
            MOVE.L  A0,A2                   ; GET AGENT POINTER
            JSR     AGNPLOT                 ; PLOT THE AGENT
            MOVE.L  (A7)+,A2
            RTS

; -----------------------------------------------------------------------------
ENMPLCOL
; CHECKS ENEMY-PLAYER COLLISION AND SUBSTRACTS LIFE IF NECESSARY
; INPUT    - A0 POINTER TO THE AGENT DATA BLOCK
; OUTPUT   - NONE
; MODIFIES - NONE
; NOTE     - THIS SUBROUTINE CHECKS AND MODIFIES PLAYER DATA.
; -----------------------------------------------------------------------------
            MOVEM.L D0-D7,-(A7)
            MOVE.W  (PLRPOSX),D0
            MOVE.W  (PLRPOSY),D1
            MOVE.W  AGNPOXOF(A0),D2
            MOVE.W  AGNPOYOF(A0),D3
            MOVE.W  #AGNWIDTH,D4
            MOVE.W  D4,D5
            MOVE.W  #AGNHEIGH,D6
            MOVE.W  D6,D7
            JSR     UTLCHCOL                ; CHECK COLLISION
            TST.B   D0                      ; IS THERE COLLISION?
            BEQ     .END                    ; NO: END
            MOVE.W  #ENMDMG,D0              : YES: DO DAMAGE
            JSR     PLRSUBLF
.END        MOVEM.L (A7)+,D0-D7
            RTS
; -----------------------------------------------------------------------------
ENMBOMB
; CHECKS IF THE ENEMY IS IN THE RANGE OF AN EXPLOSION AND KILLS IT IF NECESSARY
; INPUT     - A0 POINTER TO THE AGENT DATA BLOCK
; OUTPUT    - NONE
; MODIIFES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D5-D7,-(A7)
            MOVE.W  AGNPOXOF(A0),D5
            MOVE.W  AGNPOYOF(A0),D6
            ADD.W   #AGNWIDTH/2,D5
            ADD.W   #AGNHEIGH/2,D6
            JSR     BOMBRNG                 ; CHECK BOMB
            CMP.B   #BOMBIR,D7              ; IS IT AFFECTED BY AN EXPLOSION?
            BNE     .END                    ; NO: END
            JSR     AGLKILL                 ; YES: KILL THE AGENT
            SUBQ.W  #1,MAPNUMEN
.END        MOVEM.L (A7)+,D5-D7
            RTS



*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
