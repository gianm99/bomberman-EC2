; =============================================================================
; BOMB MANAGEMENT
; =============================================================================

; -----------------------------------------------------------------------------
BOMBINIT
; INTIALIZES THE BOMB IF THERE IS NOT ANOTHER STILL ACTIVE
; INPUT     - D1.W  X COORDINATE (PIXELS)
;             D2.W  Y COORDINATE (PIXELS)
; OUTPUT    - NONE
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D2/D7,-(A7)
            MOVE.W  BOMBSTA,D0              ; GET BOMB FLAG
            CMP.W   #BOMBNAC,D0             ; CHECK IF ACTIVE BOMB
            BNE     .END                    ; END IF ACTIVE BOMB
            JSR     MAPGTCOD
*            CMP.B   #MAPOBS,D7              ; IS IT AN OBSTACLE?
*            BEQ     .END                    ; YES: END
            MOVE.W  #BOMBACT,BOMBSTA        ; NO : START PHASE 1
            MOVE.B  GENFRMCT,BOMBTIM        ; SAVE INITIAL FRAME
            AND.W   #$FFE0,D1               ; X BLOCK COORDINATE
            AND.W   #$FFE0,D2               ; Y BLOCK COORDINATE
            MOVE.W  D1,BOMBPOX              ; SET BOMB COORDINATES
            MOVE.W  D2,BOMBPOY
.END        MOVEM.L (A7)+,D0-D2/D7
            RTS

; -----------------------------------------------------------------------------
BOMBUPD
; UPDATES THE BOMB STATUS FROM ACTIVE TO EXPLODING AND NOT ACTIVE, BY CHECKING 
; THE TIME THOSE PHASES STARTED.
; INPUT     - NONE
; OUTPUT    - NONE
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0,-(A7)
            MOVE.W  BOMBSTA,D0              ; GET BOMB FLAG
            TST.W   D0
            BEQ     .END                    ; IF NO BOMB, END
            CMP.W   #BOMBEXP,D0             ; CHECK IF PHASE 2
            BEQ     .EXP                    ; IF NOT, CONTINUE
            MOVE.B  BOMBTIM,D0
            ADD.B   #BOMB1PH,D0
            CMP.B   GENFRMCT,D0             ; CHECK IF PHASE 1 OVER
            BNE     .END                    ; IF NOT, END
            MOVE.W  #BOMBEXP,BOMBSTA        ; ELSE, START PHASE 2
            MOVE.B  GENFRMCT,BOMBTIM        ; SAVE INITIAL FRAME
            JSR     BOMBBRK                 ; BREAKS SURROUNDING BRICK BLOCKS
            BRA     .END
.EXP        MOVE.B  BOMBTIM,D0
            ADD.B   #BOMB2PH,D0
            CMP.B   GENFRMCT,D0             ; CHECK IF PHASE 2 OVER
            BNE     .END                    ; IF NOT, END
            MOVE.W  #BOMBNAC,BOMBSTA        ; ELSE, END PHASE 2
            CLR.B   BOMBTIM
.END        MOVEM.L (A7)+,D0
            RTS

; -----------------------------------------------------------------------------
BOMBPLOT
; PLOTS THE BOMB AND THE EXPLOSION
; INPUT     - NONE
; OUTPUT    - NONE
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D7/A0-A1,-(A7)
            MOVE.W  BOMBSTA,D0
            TST.W   D0
            BEQ     .END                    ; IF NO ACTIVE BOMB, END
            LEA     GFXLST,A0               ; GET GRAPHICS DATA
            MOVE.W  BOMBPOX,D5
            MOVE.W  BOMBPOY,D6
            CMP.W   #BOMBEXP,D0             ; CHECK IF IT ALREADY EXPLODED
            BEQ     .EXPLO                  ; IF IT HAS, DRAW EXPLOSION
            MOVE.W  #BOMBID,D7
            JSR     GFXDRIDP                ; DRAW BOMB
            BRA     .END
.EXPLO      MOVE.W  #EXPLID,D7
            JSR     GFXDRIDP                ; DRAW CENTRAL BLOCK
            SUB.W   #MAPTILEW,D5
            JSR     MAPGTTIL
            CMP.W   #WALL,D7
            BEQ     .RIGHT    
            MOVE.W  #EXPLID,D7
            JSR     GFXDRIDP                ; DRAW LEFT BLOCK
.RIGHT      ADD.W   #MAPTILEW*2,D5
            JSR     MAPGTTIL
            CMP.W   #WALL,D7
            BEQ     .UP
            MOVE.W  #EXPLID,D7
            JSR     GFXDRIDP                ; DRAW RIGHT BLOCK
.UP         SUB.W   #MAPTILEW,D5
            SUB.W   #MAPTILEH,D6
            JSR     MAPGTTIL
            CMP.W   #WALL,D7
            BEQ     .DOWN
            MOVE.W  #EXPLID,D7
            JSR     GFXDRIDP                ; DRAW UPPER BLOCK
.DOWN       ADD.W   #MAPTILEH*2,D6
            JSR     MAPGTTIL
            CMP.W   #WALL,D7
            BEQ     .END
            MOVE.W  #EXPLID,D7
            JSR     GFXDRIDP                ; DRAW LOWER BLOCK
.END        MOVEM.L (A7)+,D0-D7/A0-A1
            RTS

; -----------------------------------------------------------------------------
BOMBBRK
; DESTROYS THE BRICK BLOCKS AFFECTED BY THE EXPLOSION
; INPUT     - NONE
; OUTPUT    - NONE
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D5-D6,-(A7)
            MOVE.W  BOMBPOX,D5
            MOVE.W  BOMBPOY,D6
            SUB.W   #MAPTILEW,D5
            JSR     MAPGRND                 ; LEFT BLOCK
            ADD.W   #MAPTILEW*2,D5
            JSR     MAPGRND                 ; RIGHT BLOCK
            SUB.W   #MAPTILEW,D5
            SUB.W   #MAPTILEH,D6
            JSR     MAPGRND                 ; UPPER BLOCK
            ADD.W   #MAPTILEH*2,D6
            JSR     MAPGRND                 ; LOWER BLOCK
            MOVEM.L (A7)+,D5-D6
            RTS

; -----------------------------------------------------------------------------
BOMBRNG
; DETERMINES IF THE PROVIDED COORDINATES ARE IN THE RANGE OF AN EXPLOSION
; INPUT     - D5.W  X COORDINATE (PIXELS)
;             D6.W  Y COORDINATE (PIXELS)
; OUTPUT    - D7.B  CODE:
;             $00   NOT IN RANGE (BOMBNIR)
;             $FF   IN RANGE (BOMBIR)
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D4-D6,-(A7)
            MOVE.W  BOMBSTA,D4
            CMP.W   #BOMBEXP,D4             ; CHECK IF BOMB EXPLODING
            BNE     .NIR                    ; IF NOT, END
            AND.W   #$FFE0,D5               ; GET BLOCK X
            AND.W   #$FFE0,D6               ; GET BLOCK Y
            CMP.W   BOMBPOX,D5              ; CHECK SAME BLOCK
            BNE     .LEFT
            CMP.W   BOMBPOY,D6
            BEQ     .IR
.LEFT       SUB.W   #MAPTILEW,D5
            CMP.W   BOMBPOX,D5              ; CHECK LEFT BLOCK
            BNE     .RIGHT
            CMP.W   BOMBPOY,D6
            BEQ     .IR
.RIGHT      ADD.W   #MAPTILEW*2,D5
            CMP.W   BOMBPOX,D5
            BNE     .UP
            CMP.W   BOMBPOY,D6
            BEQ     .IR
.UP         SUB.W   #MAPTILEW,D5
            SUB.W   #MAPTILEH,D6
            CMP.W   BOMBPOX,D5
            BNE     .DOWN
            CMP.W   BOMBPOY,D6
            BEQ     .IR
.DOWN       ADD.W   #MAPTILEH*2,D6
            CMP.W   BOMBPOX,D5
            BNE     .NIR
            CMP.W   BOMBPOY,D6
            BEQ     .IR
            BRA     .NIR
.END        MOVEM.L (A7)+,D4-D6
            RTS
.NIR        MOVE.B  #BOMBNIR,D7
            BRA     .END
.IR         MOVE.B  #BOMBIR,D7
            BRA     .END
            





*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
