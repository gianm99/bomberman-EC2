; =============================================================================
; MAP MANAGEMENT
; =============================================================================

; -----------------------------------------------------------------------------
MAPINIT
; INITIALIZES THE MAP
; INPUT     - NONE
; OUTPUT    - NONE
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D1/A0-A1,-(A7)            
            MOVE.L  #MAPWIDTH*MAPHEIGH-1,D0 ; LOOP COUNTER
            LEA     MAPDATAO,A0             ; ORGINAL MAPDATA
            LEA     MAPDATA,A1              ; GAME MAPDATA
.LOOP       MOVE.W  (A0)+,(A1)+             ; COPY MAPDATA
            DBRA    D0,.LOOP            
            MOVE.W  #BOMBNAC,BOMBSTA        ; NO ACTIVE BOMB
            JSR     MAPENMDL                ; DELETE ALL ENEMIES
            JSR     MAPENMCR                ; CREATE ALL ENEMIES
            MOVEM.L (A7)+,D0-D1/A0-A1
            RTS
; -----------------------------------------------------------------------------
MAPUPD
; UPDATES THE MAP
; INPUT     - NONE
; OUTPUT    - NONE
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            TST.W   MAPNUMEN                ; CHECK IF THERE ARE ENEMIES
            BNE     .END                    ; YES: END
            MOVE.W  #STAVICT,(STANEXT)      ; NO: GO TO VICTORY
.END        RTS  

; -----------------------------------------------------------------------------
MAPPLOT
; PLOTS THE MAP
; INPUT     - NONE
; OUTPUT    - NONE
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D7/A2,-(A7)
            LEA     MAPDATA,A2              ; GET INITIAL CELL
            LEA     GFXLST,A0               ; GET GRAPHICS DATA
            MOVE.W  #MAPHEIGH-1,D0          ; ROW ITERATOR
            CLR.W   D6                      ; INITIAL Y
.LOOPY      CLR.W   D5                      ; INITIAL X (REINIT AFTER EACH ROW)
            MOVE.W  #MAPWIDTH-1,D1          ; COLUMN ITERATOR
.LOOPX      MOVE.W  (A2)+,D7                ; GET MAP CELL
.PLOT       JSR     GFXDRIDP                ; DRAW
            ADD.W   #MAPTILEW,D5            ; ADD 32 TO X
            DBRA.W  D1,.LOOPX               ; LOOP FOR ALL COLUMNS
            ADD.W   #MAPTILEH,D6            ; ADD 32 TO Y
            DBRA.W  D0,.LOOPY               ; LOOP FOT ALL ROWS
            MOVEM.L (A7)+,D0-D7/A2
            RTS

; -----------------------------------------------------------------------------
MAPGTTIL
; GETS THE TILE IN THE SPECIFIED (PIXELWISE) COORDINATES
; INPUT    - D5.W X COORDINATE
;            D6.W Y COORDINATE
; OUTPUT   - D7.W TILE ID
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D5-D6/A0,-(A7)
            ASR.W   #5,D6                   ; Y/=MAPTILEH. VALID IF MAPTILEH=32
            ASR.W   #4,D5                   ; X=2*(X/MAPTILEW) IF MAPTILEW=32
            AND.L   #$0000FFFE,D5           ; CLEAR LSB
            MULU    #MAPWIDTH*2,D6          ; COMPUTE Y OFFSET
            ADD.L   D5,D6                   ; ADD X OFFSET
            LEA.L   MAPDATA,A0              ; GET BASE MAP ADDR
            ADD.L   D6,A0                   ; GET ADDRESS
            MOVE.W  (A0),D7                 ; OUTPUT TO D7
            MOVEM.L (A7)+,D5-D6/A0
            RTS

; -----------------------------------------------------------------------------
MAPGTCOD
; GETS THE CODE OF THE SPECIFIED (PIXELWISE) COORDINATES.
; INPUT    - D5.W X COORDINATE
;            D6.W Y COORDINATE
; OUTPUT   - D7.B CODE:
;            %00 FREE (MAPFREE)
;            %01 OBSTACLE (MAPOBS)
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            JSR     MAPBOMB
            CMP.B   #MAPFREE,D7             ; CHECK IF FREE
            BNE     .OBST                   ; IF NOT, OBSTACLE
            JSR     MAPGTTIL
            TST.W   D7
            BEQ     .FREE                   ; ID=0 -> CODE 00
            BRA     .OBST
.FREE       MOVE.B  #MAPFREE,D7
.END        RTS
.OBST       MOVE.B  #MAPOBS,D7
            RTS

; -----------------------------------------------------------------------------
MAPBOMB
; CHECKS IF THERE IS A BOMB IN THE SPECIFIED COORDINATES.
; INPUT     - D5.W  X COORDINATE
;             D6.W  Y COORDINATE
; OUTPUT     - D7.B  CODE:
;             %00 FREE (MAPFREE)
;             %01 OBSTACLE (MAPOBS)
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D4-D6,-(A7)
            MOVE.B  #%00,D7                 ; FIRST SET AS FREE
            MOVE.W  BOMBSTA,D4
            CMP.W   #BOMBACT,D4             ; IS THE BOMB ACTIVE?
            BNE     .END                    ; IF NOT, END
            AND.W   #$FFE0,D5               ; GET THE BLOCK COORDINATES
            AND.W   #$FFE0,D6
            CMP.W   BOMBPOX,D5              ; CHECK X
            BNE     .END                    ; IF NOT, END
            CMP.W   BOMBPOY,D6              ; CHECK Y
            BNE     .END                    ; IF NOT, END
            MOVE.B  #%01,D7                 ; SET AS OBSTACLE
.END        MOVEM.L (A7)+,D4-D6
            RTS

; -----------------------------------------------------------------------------
MAPGRND
; IF THE TILE IN THE SPECIFIED COORDINATES IS A BRICK BLOCK, IT CHANGES TO A 
; GROUND TILE.
; INPUT     - D5.W  X COORDINATE
;           - D6.W  Y COORDINATE
; OUTPUT    - NONE
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D4-D6/A0,-(A7)
            ASR.W   #5,D6                   ; Y/=MAPTILEH. VALID IF MAPTILEH=32
            ASR.W   #4,D5                   ; X=2*(X/MAPTILEW) IF MAPTILEW=32
            AND.L   #$0000FFFE,D5           ; CLEAR LSB
            MULU    #MAPWIDTH*2,D6          ; COMPUTE Y OFFSET
            ADD.L   D5,D6                   ; ADD X OFFSET
            LEA.L   MAPDATA,A0              ; GET BASE MAP ADDR
            ADD.L   D6,A0                   ; GET ADDRESS
            MOVE.W  (A0),D4                 ; GET TILE ID
            CMP.W   #$01,D4                 ; CHECK IF BRICK
            BNE     .END                    ; IF NOT, END
            CLR.W   (A0)                    ; SET TO GROUND
.END        MOVEM.L (A7)+,D4-D6/A0
            RTS

; -----------------------------------------------------------------------------
MAPENMCR
; CREATES ENEMIES THE ENEMIES
; INPUT     - NONE
; OUTPUT    - NONE
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D5/A0-A3,-(A7)
            CLR.W   D5                      ; ENEMY COUNTER
            LEA     ENMDATA,A0              ; GET ENEMY LIST
.LOOP       MOVE.L  (A0),D1                 ; GET DATA
            CMP.L   #$FFFFFFFF,D1           ; TERMINATOR REACHED?
            BEQ     .END                    ; IF SO, EXIT
            ADDQ.W  #1,D5                   ; COUNT ENEMIES
            MOVE.L  (A0),D1
            MOVE.L  4(A0),D2
            MOVE.L  8(A0),D3
            MOVE.L  12(A0),D4
            LEA     ENMINIT,A1
            LEA     ENMUPD,A2
            LEA     ENMPLOT,A3
            MOVE.W  #ENMTYPE,D0
            JSR     AGLADD
            ADD.L   #16,A0                  ; GO TO NEXT ENEMY
            BRA     .LOOP
.END        MOVE.W  D5,(MAPNUMEN)           ; STORE THE NUMBER OF ENEMIES
            MOVEM.L (A7)+,D0-D5/A0-A3
            RTS

; -----------------------------------------------------------------------------
MAPENMDL
; DELETES ALL ENEMIES
; INPUT     - NONE
; OUTPUT    - NONE
; MODIFIES  - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0/A0,-(A7)
            MOVE.W  #ENMTYPE,D0
            JSR     DMMFRSTO
.LOOP       CMP.L   #0,A0
            BEQ     .END
            JSR     DMMFREE
            JSR     DMMNEXTO
            BRA     .LOOP
.END        MOVEM.L (A7)+,D0/A0
            RTS





















            



*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
