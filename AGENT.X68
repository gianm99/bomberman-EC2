; =============================================================================
; AGENT MANAGEMENT - CODE SHARED BY PLAYER AND ENEMIES
;
; AN AGENT DATA BLOCK HAS THE FOLLOWING STRUCTURE.
; PROVIDED NAMES REFERS TO THE OFFSET (SEE CONST.X68) TO ACCESS THE FIELD.
;
; * VARIABLES. VALUES THAT THE AGENT CAN CHANGE DURING EXECUTION
;   - AGNFRAOF (WORD) THE GRAPHIC ID OF THE BASE FRAME TO PLOT. ONLY TWO FRAME
;                     ANIMATIONS ARE ALLOWED, THE SECOND FRAME BEING THIS ONE
;                     PLUS ONE.
;   - AGNPOXOF (WORD) THE X POSITION IN PIXELS.
;   - AGNPOYOF (WORD) THE Y POSITION IN PIXELS.
;   
; * COMMANDS. VALUES PROVIDED TO THE AGENT FOR IT TO ACT ACCORDING TO THEM
; OFFSETS TO AGENT COMMANDS
;   - AGNMOTOF (BYTE) DESIRED MOTION IN THE SAME FORMAT THAT KBDVAL
;
; * PARAMETERS. VALUES FIXED FOR A GIVEN AGENT
;   - AGNTYPOF (BYTE) SUBTYPE OF THE AGENT. THIS ALLOWS A SECOND CATEGORIZATION
;                     OTHER THAN THE ONE PROVIDED BY THE OWNER.
;   - AGNFRMLR (LONG) FRAME TO SHOW WHEN THE AGENT MOVES LEFT (HIGH WORD) AND
;                     RIGHT (LOW WORD)
;   - AGNFRMUD (LONG) FRAME TO SHOW WHEN AGENT MOVES UP (HIGH WORD) AND DOWN
;                     (LOW WORD)
;   - AGNSPEDC (WORD) SPEED OF AGENT
; =============================================================================

; -----------------------------------------------------------------------------
AGNMOVE
; MOVES THE AGENT ALONG THE X AND Y AXIS
; INPUT     - A2 POINTER TO AGENT DATA BLOCK
; OUTPUT    - D7 CONTAINS KBDMSKLF OR KBDMSKRT OR KBDMSKUP OR KBSMSKDN 
;             DEPENDING ON WHERE THE AGENT FOUND OBSTACLES.
; MODIFIES  - NOTHING
; -----------------------------------------------------------------------------
            MOVEM.L D0-D7,-(A7)
            CLR.B   7*4+3(A7)               ; CLEAR COPY OF D7
            MOVE.B  AGNMOTOF(A2),D0         ; GET MOTION
            MOVE.L  AGNFRMLR(A2),D1         ; GET BASE FRAMES (LEFT, RIGHT)
            MOVE.L  AGNFRMUD(A2),D2         ; GET BASE FRAMES (UP, DOWN)
            BTST    #KBDBITLF,D0
            BNE     .TRYLEFT                ; IF MOTION LEFT WANTED, TRY
.KBDRT      BTST    #KBDBITRT,D0
            BNE     .TRYRIGHT               ; IF MOTION RIGHT WANTED, TRY
.KBDUP      BTST    #KBDBITUP,D0
            BNE     .TRYUP                  ; IF MOTION UP WANTED, TRY
.KBDDN      BTST    #KBDBITDN,D0
            BNE     .TRYDOWN                ; IF MOTION DOWN WANTED, TRY
.END        MOVEM.L (A7)+,D0-D7
            RTS
.TRYLEFT    SWAP    D1
            MOVE.W  D1,AGNFRAOF(A2)         ; STORE LEFT FRAME
            MOVE.W  AGNPOYOF(A2),D6         ; GET Y
            MOVE.W  AGNPOXOF(A2),D5         ; GET X
            SUB.W   AGNSPEDC(A2),D5          ; PROPOSE NEW POSITION
            JSR     AGNOBSH                 ; CHECK OBSTACLES
            TST.B   D7
            BEQ     .STOL                   ; IF NOT, STORE
.ADJLEFT    AND.W   #~(MAPTILEW-1),D5       ; ELSE, ADJUST TO BLOCK
            ADD.W   #MAPTILEW,D5
            OR.B    #KBDMSKLF,7*4+3(A7)     ; STORE LEFT IN COPY OF D7
.STOL       MOVE.W  D5,AGNPOXOF(A2)         ; STORE POSITION
            BRA     .KBDRT
.TRYRIGHT   MOVE.W  D1,AGNFRAOF(A2)         ; STORE RIGHT FRAME
            MOVE.W  AGNPOYOF(A2),D6         ; GET Y
            MOVE.W  AGNPOXOF(A2),D4         ; GET X
            ADD.W   AGNSPEDC(A2),D4          ; PROPOSE NEW POSITION
            MOVE.W  D4,D5
            ADD.W   #AGNWIDTH,D5
            JSR     AGNOBSH                 ; CHECK OBSTACLES
            TST.B   D7
            BEQ     .STOR                   ; IF NOT, STORE
.ADJRIGHT   AND.W   #~(MAPTILEH-1),D4       ; ADJUST TO BLOCK
            OR.B    #KBDMSKRT,7*4+3(A7)     ; STORE RIGHT IN COPY OF D7
.STOR       MOVE.W  D4,AGNPOXOF(A2)         ; STORE POSITION
            BRA     .KBDUP
.TRYUP      SWAP    D2
            MOVE.W  D2,AGNFRAOF(A2)         ; STORE UP FRAME
            MOVE.W  AGNPOXOF(A2),D5         ; GET X
            MOVE.W  AGNPOYOF(A2),D6         ; GET Y
            SUB.W   AGNSPEDC(A2),D6          ; PROPOSE NEW POSITION
            JSR     AGNOBSV                 ; CHECK OBSTACLES
            TST.B   D7
            BEQ     .STOU                   ; IF NOT, STORE
.ADJUP      AND.W   #~(MAPTILEH-1),D6       ; ELSE ADJUST TO BLOCK
            ADD.W   #MAPTILEH,D6
            OR.B    #KBDMSKUP,7*4+3(A7)     ; STORE UP IN COPY OF D7
.STOU       MOVE.W  D6,AGNPOYOF(A2)         ; STORE POSITION
            BRA     .KBDDN
.TRYDOWN    MOVE.W  D2,AGNFRAOF(A2)         ; STORE DOWN FRAME
            MOVE.W  AGNPOXOF(A2),D5         ; GET X
            MOVE.W  AGNPOYOF(A2),D4         ; GET Y
            ADD.W   AGNSPEDC(A2),D4          ; PROPOSE NEW POSITION
            MOVE.W  D4,D6
            ADD.W   #AGNHEIGH,D6
            JSR     AGNOBSV                 ; CHECK OBSTACLES
            TST.B   D7
            BEQ     .STOD                   ; IF NOT, STORE
.ADJDOWN    AND.W   #~(MAPTILEW-1),D4       ; ADJUST TO BLOCK
            OR.B    #KBDMSKDN,7*4+3(A7)     ; STORE DOWN IN COPY OF D7
.STOD       MOVE.W  D4,AGNPOYOF(A2)         ; STORE POSITION
            BRA     .END
            
; -----------------------------------------------------------------------------
AGNOBSV
; CHECKS OBSTACLES AT (X+OFF,Y) AND (X+W-O,Y)
; INPUT     - D5.W  X COORDINATE
;             D6.W  Y COORDINATE
; OUTPUT    - D7 = $FF OBSTACLES, $00 NO OBSTACLES
; MODIFIES  - NOTHING
; -----------------------------------------------------------------------------
            MOVEM.L D4-D5,-(A7)             ; STORE REGISTERS
            CLR.B   D4                      ; TEMPORARY OUTPUT
            ADD.W   #AGNBBXO,D5             ; X OFFSET TO AVOID DETECT LEFT
            JSR     MAPGTCOD                ; GET TILE ID
            AND.B   #MAPOBS,D7              ; IS OBSTACLE?
            BNE     .OBST                   ; YES: STATE IT
            ADD.W   #AGNWIDTH-2*AGNBBXO,D5  ; X TO THE RIGHT PART
            JSR     MAPGTCOD                ; GET TILE ID?
            AND.B   #MAPOBS,D7              ; IS OBSTACLE?
            BEQ     .END                    ; NO: STATE IT
.OBST       MOVE.B  #$FF,D4                 ; YES: PREPARE OUTPUT $FF
.END        MOVE.B  D4,D7                   ; OUTPUT PREPARED VALUE
            MOVEM.L (A7)+,D4-D5             ; RESTORE REGISTERS
            RTS

; -----------------------------------------------------------------------------
AGNOBSH
; CHECKS OBSTACLES AT (X,Y+OFF) AND (X,Y+H-O)
; INPUT    - D5.W   X COORDINATE
;            D6.W   Y COORDINATE
; OUTPUT   - D7 = $FF OBSTACLES, $00 NO OBSTACLES
; MODIFIES - NOTHING
; -----------------------------------------------------------------------------
            MOVEM.L D4/D6,-(A7)             ; STORE REGISTERS
            CLR.B   D4                      ; TEMPORARY OUTPUT
            ADD.W   #AGNBBYO,D6             ; Y OFFSET TO AVOID DETECT TOP
            JSR     MAPGTCOD                ; GET TILE ID
            AND.B   #MAPOBS,D7              ; IS OBSTACLE?
            BNE     .OBST                   ; YES: STATE IT
            ADD.W   #AGNHEIGH-2*AGNBBYO,D6  ; Y TO THE BOTTOM PART
            JSR     MAPGTCOD                ; GET TILE ID?
            AND.B   #MAPOBS,D7              ; IS OBSTACLE?
            BEQ     .END                    ; NO: STATE IT
.OBST       MOVE.B  #$FF,D4                 ; YES: PREPARE OUTPUT $FF
.END        MOVE.B  D4,D7                   ; OUTPUT PREPARED VALUE
            MOVEM.L (A7)+,D4/D6             ; RESTORE REGISTERS
            RTS

; -----------------------------------------------------------------------------
AGNPLOT
; PLOTS THE AGENT
; INPUT     - A2 POINTER TO THE AGENT DATA BLOCK
; OUTPUT    - NONE
; MODIFIES  - NONE
; NOTE      - ONLY WORKS WITH TWO-FRAME ANIMATIONS WHOSE FIRST FRAME IS AT AN 
;             EVEN ADDRESS.
; -----------------------------------------------------------------------------
            MOVEM.L D0/D5-D7/A0,-(A7)
            MOVE.W  AGNPOXOF(A2),D5         ; GET AGENT X
            MOVE.W  AGNPOYOF(A2),D6         ; GET AGENT Y (INTEGER PART)
            MOVE.W  AGNFRAOF(A2),D7         ; GET AGENT BASE FRAME
            LEA     GFXLST,A0               ; GET GRAPHICS DATA
            MOVE.B  (GENFRMCT),D0           ; GET OFFSET
            LSR.B   #3,D0
            AND     #1,D0
            OR.B    D0,D7                   ; ADD OFFSET
            JSR     GFXDRIDP                ; PLOT
            MOVEM.L (A7)+,D0/D5-D7/A0
            RTS




*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
