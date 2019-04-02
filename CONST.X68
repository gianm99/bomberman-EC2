; =============================================================================
; USER CONSTANTS
; =============================================================================

; --- GENERAL PURPOSE CONSTANTS -----------------------------------------------

GENCHRW     EQU     8                       ; WIDTH IN PIXELS OF A TEXT CHAR
GENCHRH     EQU     15                      ; HEIGHT IN PIXELS OF A TEXT CHAR

; --- MAP RELATED CONSTANTS ---------------------------------------------------

MAPWIDTH    EQU     20                      ; NUMBER OF TILES HORIZONTALLY
MAPHEIGH    EQU     15                      ; NUMBER OF TILES VERTICALLY
MAPTILEW    EQU     32                      ; SIZE OF TILE, HORIZONTALLY
MAPTILEH    EQU     32                      ; SIZE OF TILE, VERTICALLY
MAPCMPLT    EQU     $FFFF                   ; MAP COMPLETED
MAPNOTCM    EQU     $0000                   ; MAP NOT COMPLETED
MAPFREE     EQU     %00                     ; FREE CELL CODE
MAPOBS      EQU     %01                     ; OBSTACLE CELL
GROUND      EQU     0                       ; GROUND ID
BRICK       EQU     1                       ; BRICK ID
WALL        EQU     2                       ; WALL ID

; --- AGENT RELATED CONSTANTS -------------------------------------------------

AGNWIDTH    EQU     32                      ; AGENT WIDTH
AGNHEIGH    EQU     32                      ; AGENT HEIGHT
AGNBBXO     EQU     8                       ; BOUNDING BOX X OFFSET
AGNBBYO     EQU     8                       ; BOUNDING BOX Y OFFSET

; --- AGENT DATABLOCK OFFSETS -------------------------------------------------

; OFFSETS TO AGENT VARIABLES

AGNFRAOF    EQU     0                       ; BASE FRAME
AGNPOXOF    EQU     2                       ; X COORD
AGNPOYOF    EQU     4                       ; Y COORD

; OFFSETS TO AGENT COMMANDS

AGNMOTOF    EQU     6                       ; DESIRED MOTION

; OFFSETS TO AGENT PARAMETERS

AGNTYPOF    EQU     7                       ; TYPE
AGNFRMLR    EQU     8                       ; FRAMES FOR LEFT AND RIGHT
AGNFRMUD    EQU     12                      ; FRAMES FOR UP AND DOWN
AGNSPEDC    EQU     16                      ; X AND Y SPEED

; --- PLAYER RELATED CONSTANTS ------------------------------------------------

PLRXINI     EQU     32                      ; INITIAL PLAYER X COORDINATE
PLRYINI     EQU     32                      ; INITIAL PLAYER Y COORDINATE
PLRSPEDC    EQU     4                       ; PLAYER HORIZONTAL/VERTICAL SPEED
PLRSTNM     EQU     $00                     ; PLAYER NORMAL MODE
PLRSTGM     EQU     $FF                     ; PLAYER GHOST MODE
PLRGMTIM    EQU     150                     ; DURATION OF GHOST MODE
PLRFACEL    EQU     4                       ; PLAYER BASE FRAME LEFT
PLRFACER    EQU     6                       ; PLAYER BASE FRAME RIGHT
PLRFACEU    EQU     8                       ; PLAYER BASE FRAME UP
PLRFACED    EQU     10                      ; PLAYER BASE FRAME DOWN
PLRLIFEI    EQU     480                     ; PLAYER INITIAL LIFE
PLRSCORH    EQU     PLRLIFEI                ; HEIGHT OF THE LIFE BAR
PLRSCORW    EQU     32                      ; WIDTH OF THE LIFE BAR
PLRSCOCF    EQU     $0000FF00               ; INNER BAR COLOR
PLRSCOCB    EQU     $00000000               ; BORDER COLOR

; --- ENEMY RELATED CONSTANTS -------------------------------------------------

ENMDMG      EQU     80                      ; DAMAGE PERFORMED BY ENEMY

; --- BOMB RELATED CONSTANTS --------------------------------------------------

BOMBDMG     EQU     160                      ; DAMAGE PERFORMED BY BOMB
BOMBACT     EQU     $FFFF                   ; ACTIVE BOMB
BOMBEXP     EQU     $00FF                   ; BOMB EXPLODING
BOMBNAC     EQU     $0000                   ; NO ACTIVE BOMB
BOMB1PH     EQU     100                     ; FIRST PHASE DELAY (FRAMES)
BOMB2PH     EQU     50                      ; SECOND PHASE DELAY (FRAMES)
BOMBID      EQU     3                       ; BOMB FRAME ID
EXPLID      EQU     20                      ; EXPLOSION FRAME ID
BOMBIR      EQU     $FF                     ; IN RANGE
BOMBNIR     EQU     $00                     ; NOT IN RANGE

; --- GAME STATES -------------------------------------------------------------

STANONE     EQU     -1                      ; PLACEHOLDER TO FORCE CHANGE
STAINTR     EQU     0                       ; INTRO
STAPLAY     EQU     1                       ; NORMAL GAME STATE
STAGOVR     EQU     2                       ; GAME OVER STATE
STAVICT     EQU     3                       ; VICTORY STATE

; --- AGENT TYPES -------------------------------------------------------------

ENMTYPE     EQU     1












*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
