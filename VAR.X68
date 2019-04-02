; =============================================================================
; GAME VARS
; =============================================================================

; --- GAME STATE RELATED VARIABLES --------------------------------------------

STACUR      DS.W    1                       ; CURRENT GAME STATE
STANEXT     DS.W    1                       ; NEXT GAME STATE

; --- GENERAL PURPOSE VARIABLES -----------------------------------------------

GENFRMCT    DS.B    1                       ; FRAME COUNTER

; --- PLAYER RELATED VARIABLES ------------------------------------------------

; VARIABLES SPECIFIC FOR PLAYER (NOT IN AGENT DATABLOCK)

PLRLIFE     DS.W    1                       ; PLAYER'S LIFE
PLRSTAT     DS.W    1                       ; PLAYER STATUS (NORMAL OR GM)
PLRTIM      DS.B    1                       ; PLAYER TIMER FOR GM
            DS.W    0

PLRDBLK                                     ; PLACEHOLDER FOR DATABLOCK

; PLAYER VARIABLES

PLRFACE     DS.W    1                       ; FACE LEFT, RIGHT, UP OR DOWN
PLRPOSX     DS.W    1                       ; PLAYER X POSITION (PIXELS)
PLRPOSY     DS.W    1                       ; PLAYER Y POSITION (PIXELS)

; PLAYER COMMANDS

PLRMOT      DS.B    1                       ; DESIRED MOTION (KBDVAL FORMAT)

; PLAYER PARAMETERS. STORED IN RAM TO REUSE GENERIC AGENT CODE

PLRTYPE     DS.B    1                       ; SET TO FF
PLRFRMH     DS.L    1                       ; MSW LEFT FRAME,LSW RIGHT FRAME
PLRFRMV     DS.L    1                       ; MSW UP FRAME, LSW DOWN FRAME
PLRSPED     DS.W    1                       ; PLAYER X AND Y SPEED

; --- MAP RELATED VARIABLES ---------------------------------------------------

MAPNUMEN    DS.W    1                       ;NUMBER OF ENEMIES ALIVE

; --- BOMB RELATED VARIABLES --------------------------------------------------

BOMBSTA     DS.W    1                       ; FLAG FOR BOMB STATUS
BOMBPOX     DS.W    1                       ; BOMB X POSITION (PIXELS)
BOMBPOY     DS.W    1                       ; BOMB Y POSITION (PIXELS)
BOMBTIM     DS.B    1                       ; FRAME OF BOMB ACTIVATION

; --- UTILITY VARIABLES ------------------------------------------------------

UTLRNDIX    DS.B    1                       ; NEXT INDEX TO RANDOM NUMBER
            DS.W    0



*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
