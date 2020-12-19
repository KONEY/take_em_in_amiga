;*** HD + MUSIC
;*** MiniStartup by Photon ***
	INCDIR	"NAS:AMIGA/CODE/take_em_in_amiga/"
	SECTION	"Code",CODE
	INCLUDE	"Blitter-Register-List.S"
	INCLUDE	"PhotonsMiniWrapper1.04!.S"
	INCLUDE	"PT12_OPTIONS.i"
	INCLUDE	"P6112-Play-stripped.i"
;********** Constants **********
w=640		; screen width, height, depth
h=512
bpls=3		; handy values:
bpl=w/16*2	; byte-width of 1 bitplane line (80)
bwid=bpls*bpl	; byte-width of 1 pixel line (all bpls)
;*************
MODSTART_POS=0	; start music at position # !! MUST BE EVEN FOR 16BIT
SCROLLFACTOR=8
;*************

;********** Demo **********	; Demo-specific non-startup code below.
Demo:	;a4=VBR, a6=Custom Registers Base addr
	;*--- init ---*
	MOVE.L	#VBint,$6C(A4)
	MOVE.W	#%1110000000100000,INTENA
	;** SOMETHING INSIDE HERE IS NEEDED TO MAKE MOD PLAY! **
	;move.w	#%1110000000000000,INTENA	; Master and lev6	; NO COPPER-IRQ!
	MOVE.W	#%1000011111100000,DMACON

	;*--- clear screens ---*
	;lea	SCREEN1,a1
	;bsr.w	ClearScreen
	;lea	SCREEN2,a1
	;bsr.w	ClearScreen
	;bsr	WaitBlitter
	;*--- start copper ---*
	lea	SCREEN1,a0

	moveq	#bpl,d0
	lea	COPPER1\.BplPtrs+2,a1
	moveq	#bpls-1,d1
	bsr.w	PokePtrs

	moveq	#bpl,d0
	lea	COPPER2\.BplPtrs+2,a1
	moveq	#bpls-1,d1
	bsr.w	PokePtrs

	; #### CPU INTENSIVE TASKS BEFORE STARTING MUSIC
	JSR	__DUPLICATE_SCREEN

	; #### Point LOGO sprites
	LEA	COPPER1\.SpritePointers,A1	; Puntatori in copperlist
	MOVE.L	#SPRT_K,D0	; sprite 0
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_O,D0	; sprite 1
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_N,D0	; sprite 2
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_E,D0	; sprite 3
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_Y,D0	; sprite 4
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_SCROLL_2,D0	; sprite 5 SHADOW
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_SCROLL,D0	; sprite 6
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	; #### Point LOGO sprites

	;---  Call P61_Init  ---
	MOVEM.L	D0-A6,-(SP)
	LEA	MODULE,A0
	SUB.L	A1,A1
	SUB.L	A2,A2
	MOVE.W	#MODSTART_POS,P61_InitPos	; TRACK START OFFSET
	JSR	P61_Init
	MOVEM.L (SP)+,D0-A6
	;---  Call P61_Init  ---

	;MOVE.W	#$8000,VPOSW	; RESETS LOF (from EAB)

	;CLR.W	$100		; DEBUG | w 0 100 2

	MOVE.L	#COPPER1,COP1LC	; COP1LCH
	;MOVE.L	#COPPER2,COP2LC	; COP2LCH
	MOVE.L	#COPPER2,D0
	LEA	COPPER1\.CopJumpL,A0
	MOVE.W	D0,(A0)
	LEA	COPPER1\.CopJumpH,A0
	SWAP	D0
	MOVE.W	D0,(A0)
	
	MOVE.L	#COPPER1,D0
	LEA	COPPER2\.CopJumpL,A0
	MOVE.W	D0,(A0)
	LEA	COPPER2\.CopJumpH,A0
	SWAP	D0
	MOVE.W	D0,(A0)

;********************  main loop *********************
MainLoop:
	move.w	#$12c,d0		;No buffering, so wait until raster
	bsr.w	WaitRaster	;is below the Display Window.
	;*--- swap buffers ---*
	movem.l	DrawBuffer(PC),a2-a3
	exg	a2,a3
	movem.l	a2-a3,DrawBuffer	;draw into a2, show a3
	;*--- show one... ---*

	move.l	a3,a0
	move.l	#bpl*h,d0
	lea	COPPER1\.BplPtrs+2,a1
	moveq	#bpls-1,d1
	bsr.w	PokePtrs

	move.l	a3,a0
	ADD.L	#bpl,A0		; Oppure aggiungi la lunghezza di una linea
	move.l	#bpl*h,d0
	lea	COPPER2\.BplPtrs+2,a1
	moveq	#bpls-1,d1
	bsr.w	PokePtrs
	;*--- ...draw into the other(a2) ---*
	move.l	a2,a1
	;bsr	ClearScreen
	bsr	WaitBlitter

	; ** CODE FOR HI-RES ** FROM Lezione11l6.S ********************
	;MOVE.L	KONEY,D3		; Indirizzo bitplane
	;MOVE.W	VPOSR,D7
	;BTST	#15,D7
	;BNE.S	.skipLine		; Se si, tocca alle linee dispari
	;ADD.L	#bpl,D3		; Oppure aggiungi la lunghezza di una linea
	;.skipLine:
	; ** CODE FOR HI-RES **************************************
	;MOVE.L	D3,DrawBuffer
	;CLR.W	$100		; DEBUG | w 0 100 2
	;CLR.W	$100		; THIS IS NEEDED FOR HI-RES... LOL!!

	; do stuff here :)

	BSR.W	__POPULATE_TXT_BUFFER
	BSR.W	__SCROLL_SPRITE_COLUMN

	;move.w	$000,$DFF18E	; metti VHPOSR in COLOR00 (lampeggio!!)
	;bsr.w	__DUMMY		; Stampa le linee di testo sullo schermo
	;move.w	$222,$DFF18E	; metti VHPOSR in COLOR00 (lampeggio!!)
	;bsr.w	__DUMMY		; Stampa le linee di testo sullo schermo

	;*--- main loop end ---*
	BTST	#6,$BFE001
	BNE.S	.DontShowRasterTime
	MOVEM.L D0-A6,-(SP)
	JSR P61_End
	MOVEM.L (SP)+,D0-A6
	;MOVE.W	#$0F0,$18E(A6)	; show rastertime left down to $12c
	.DontShowRasterTime:
	BTST	#2,$DFF016	; POTINP - RMB pressed?
	BNE.W	MainLoop		; then loop
	;*--- exit ---*
	;    ---  Call P61_End  ---
	MOVEM.L D0-A6,-(SP)
	JSR P61_End
	MOVEM.L (SP)+,D0-A6
	RTS
;********** Demo Routines **********

PokePtrs:				; Generic, poke ptrs into copper list
	.bpll:	
	move.l	a0,d2
	swap	d2
	move.w	d2,(a1)		; high word of address
	move.w	a0,4(a1)		; low word of address
	addq.w	#8,a1		; skip two copper instructions
	add.l	d0,a0		; next ptr
	dbf	d1,.bpll
	rts

ClearScreen:			; a1=screen destination address to clear
	bsr	WaitBlitter
	clr.w	$66(a6)		; destination modulo
	move.l	#$01000000,$40(a6)	; set operation type in BLTCON0/1
	move.l	a1,$54(a6)	; destination address
	move.l	#h*bpls*64+bpl/2,$58(a6)	;blitter operation size
	rts

VBint:				; Blank template VERTB interrupt
	movem.l	d0/a6,-(sp)	; Save used registers
	lea	$dff000,a6
	btst	#5,$1f(a6)	; check if it's our vertb int.
	beq.s	.notvb
	;*--- do stuff here ---*
	moveq	#$20,d0		; poll irq bit
	move.w	d0,$9c(a6)
	move.w	d0,$9c(a6)
	.notvb:	
	movem.l	(sp)+,d0/a6	; restore
	rte

	RTS

__SCROLL_SPRITE_COLUMN:	
	MOVEM.L	D0-A6,-(SP)	; SAVE TO STACK
	BTST.B	#6,DMACONR	; for compatibility

	; ## MAIN BLIT ####
	.mainBlit:
	LEA	SCROLL_VISIBLE,A4
	LEA	SCROLL_VISIBLE_2,A5
	bsr	WaitBlitter
	MOVE.W	#$FFFF,BLTAFWM		; BLTAFWM lo spiegheremo dopo
	MOVE.W	#$FFFF,BLTALWM		; BLTALWM lo spiegheremo dopo
	MOVE.W	#%0000100111110000,BLTCON0	; BLTCON0 (usa A+D); con shift di un pixel
	MOVE.W	#%0000000000000000,BLTCON1	; BLTCON1 BIT 12 DESC MODE
	MOVE.W	#0,BLTAMOD		; BLTAMOD =0 perche` il rettangolo
	MOVE.W	#0,BLTDMOD		; BLTDMOD 40-4=36 il rettangolo

	.goBlitter:
	MOVE.L	A4,BLTAPTH		; BLTAPT  (fisso alla figura sorgente)
	;MOVE.L	A5,BLTDPTH		; CLONE TO SHADOW
	;MOVE.W	#(272+14<<6)+%00010101,BLTSIZE ; BLTSIZE (via al blitter !)
	;bsr	WaitBlitter
	SUB.L	#4,A4
	MOVE.L	A4,BLTDPTH
	MOVE.W	#(272+14<<6)+%00010101,BLTSIZE ; BLTSIZE (via al blitter !)
	; ## MAIN BLIT ####
	
	MOVEM.L	(SP)+,D0-A6	; FETCH FROM STACK
	RTS

__POPULATE_TXT_BUFFER:
	MOVEM.L	D0-A6,-(SP)	; SAVE TO STACK
	MOVE.W	FRAMESINDEX,D7
	CMP.W	#SCROLLFACTOR,D7
	BNE.W	.SKIP
	LEA	HIDDEN_BUFFER,A4
	LEA	FONT,A5
	LEA	TEXT,A6
	ADD.W	TEXTINDEX,A6
	CMP.L	#_TEXT-1,A6	; Siamo arrivati all'ultima word della TAB?
	BNE.S	.PROCEED
	MOVE.W	#0,TEXTINDEX	; Riparti a puntare dalla prima word
	LEA	TEXT,A6		; FIX FOR GLITCH (I KNOW IT'S FUN... :)
	.PROCEED:
	MOVE.B	(A6),D2		; Prossimo carattere in d2
	SUB.B	#$20,D2		; TOGLI 32 AL VALORE ASCII DEL CARATTERE, IN
	MULU.W	#8,D2		; MOLTIPLICA PER 8 IL NUMERO PRECEDENTE,
	ADD.W	D2,A5
	MOVEQ	#0,D6		; RESET D6
	MOVE.B	#8-1,D6
	.LOOP:
	ADD.W	#2,A4		; POSITIONING
	MOVE.B	(A5)+,(A4)+	; COPY NORMAL BITS
	MOVE.B	#%00000000,(A4)+	; WRAPS MORE NICELY?
	DBRA	D6,.LOOP
	ADD.W	#2,A4		; POSITIONING
	MOVE.B	#%00000000,(A4)	; WRAPS MORE NICELY?
	.SKIP:
	SUB.W	#1,D7
	CMP.W	#0,D7
	BEQ.W	.RESET
	MOVE.W	D7,FRAMESINDEX
	MOVEM.L	(SP)+,D0-A6	; FETCH FROM STACK
	RTS
	.RESET:
	ADD.W	#1,TEXTINDEX
	MOVE.W	#SCROLLFACTOR,FRAMESINDEX
	MOVEM.L	(SP)+,D0-A6	; FETCH FROM STACK
	RTS

__DUPLICATE_SCREEN:
	MOVEM.L	D0-A6,-(SP)	; SAVE TO STACK
	LEA	SCREEN1,A0
	LEA	SCREEN2,A1
	;ADD.L	#bpl,A1		; Oppure aggiungi la lunghezza di una linea
	MOVE.L	#h*bpls-1,D1	; LINES
	.OUTERLOOP:
	MOVE.L	#w/16-1,D0	; SIZE OF SOURCE IN WORDS
	.INNERLOOP:
	MOVE.W	(A0)+,(A1)+
	DBRA	D0,.INNERLOOP
	DBRA.W	D1,.OUTERLOOP

	MOVEM.L	(SP)+,D0-A6	; FETCH FROM STACK
	RTS

;********** Fastmem Data **********
TEXTINDEX:	DC.W 0
FRAMESINDEX:	DC.W SCROLLFACTOR
;KONEY:		DC.L BG1		; INIT BG
DrawBuffer:	DC.L SCREEN1	; pointers to buffers to be swapped
ViewBuffer:	DC.L SCREEN2

;**************************************************************
	SECTION "ChipData",DATA_C	;declared data that must be in chipmem
;**************************************************************

MODULE:	INCBIN "take_em_in.P61"	; code $9100

SPRITES:	INCLUDE "sprite_KONEY.s"

FONT:	DC.L 0,0		; SPACE CHAR
	INCBIN "cyber_font.raw",0
	EVEN

TEXT:	DC.B "WELCOME TO:   - TAKE EM IN -   KONEY THIRD AMIGA MUSIC RELEASE !   "
	DC.B "TECHNO TECHNO TECHNO TECHNO !!!!  "
	DC.B "AS USUAL IT SHOULD NOT BE NECESSARY TO REMIND THAT THIS PIECE OF "
	DC.B "CRAPPY CODE IS BEST VIEWED ON THE REAL HARDWARE ! WELL VERTICAL TEXT "
	DC.B "IS A BIT ODD AS NORMAL RULES DO NOT APPLY LIKE COMMAS AND EXCLAMATION POINTS ! "
	EVEN
_TEXT:

SCREEN1:	INCBIN "klogo_hd.raw"

COPPER1:
	DC.W $1FC,0		; Slow fetch mode, remove if AGA demo.
	DC.W $8E,$2C81		; 238h display window top, left
	DC.W $90,$2CC1		; and bottom, right.
	DC.W $92,$3C		; Standard bitplane dma fetch start
	DC.W $94,$D4		; and stop for standard screen.

	DC.W $106,$0C00		; (AGA compat. if any Dual Playf. mode)
	DC.W $108,bpl		; bwid-bpl	;modulos
	DC.W $10A,bpl		; bwid-bpl	;RISULTATO = 80 ?

	DC.W $102,0		; SCROLL REGISTER (AND PLAYFIELD PRI)
	DC.W $104,%0000000000100000	; BPLCON2
	;DC.W $100,bpls*$1000+$200	; enable bitplanes
	DC.W $100,%1011001000000100	; BPLCON0 1011 0010 0000 0100

	.Palette:	
	DC.W $0180,$0AAB,$0182,$0CCB,$0184,$0889,$0186,$0666
	DC.W $0188,$0444,$018A,$0333,$018C,$0222,$018E,$0515

	.BplPtrs:
	DC.W $E0,0
	DC.W $E2,0
	DC.W $E4,0
	DC.W $E6,0
	DC.W $E8,0
	DC.W $EA,0
	DC.W $EC,0
	DC.W $EE,0
	DC.W $F0,0
	DC.W $F2,0
	DC.W $F4,0
	DC.W $F6,0

	.SpritePointers:
	DC.W $120,0,$122,0 ; 0
	DC.W $124,0,$126,0 ; 1
	DC.W $128,0,$12A,0 ; 2
	DC.W $12C,0,$12E,0 ; 3
	DC.W $130,0,$132,0 ; 4
	DC.W $134,0,$136,0 ; 5
	DC.W $138,0,$13A,0 ; 6
	DC.W $13C,0,$13E,0 ; 7
	DC.W $13F,0,$140,0 ; 8

	.SpriteColors:
	DC.W $1A0,$000
	DC.W $1A2,$000
	DC.W $1A4,$000
	DC.W $1A6,$000

	DC.W $1A8,$000
	DC.W $1AA,$000
	DC.W $1AC,$000
	DC.W $1AE,$000

	DC.W $1B0,$000
	DC.W $1B2,$FFF
	DC.W $1B4,$000
	DC.W $1B6,$000

	DC.W $1B8,$000
	DC.W $1BA,$111
	DC.W $1BC,$000
	DC.W $1BE,$000

	.CopperWaits:
	DC.W $FFDF,$FFFE		; allow VPOS>$ff
	DC.W $2201,$FF00		; horizontal position masked off
	DC.W $0180,$0F00		; BG COLOR

	;DC.W COPJMP2,$000	; COPJMP2 - fai partire la copperlist 2
	DC.W COP1LCH
	.CopJumpH:
	DC.W $FFFF
	DC.W COP1LCL
	.CopJumpL:
	DC.W $FFFF

	DC.W $FFFF,$FFFE		; magic value to end copperlist

COPPER2:
	DC.W $1FC,0		; Slow fetch mode, remove if AGA demo.
	DC.W $8E,$2C81		; 238h display window top, left
	DC.W $90,$2CC1		; and bottom, right.
	DC.W $92,$3C		; Standard bitplane dma fetch start
	DC.W $94,$D4		; and stop for standard screen.

	DC.W $106,$0C00		; (AGA compat. if any Dual Playf. mode)
	DC.W $108,bpl		; bwid-bpl	;modulos
	DC.W $10A,bpl		; bwid-bpl	;RISULTATO = 80 ?

	DC.W $102,0		; SCROLL REGISTER (AND PLAYFIELD PRI)
	DC.W $104,%0000000000100000	; BPLCON2
	;DC.W $100,bpls*$1000+$200	; enable bitplanes
	DC.W $100,%1011001000000100	; BPLCON0 1011 0010 0000 0100

	.Palette:
	DC.W $0180,$0AAB,$0182,$0CCB,$0184,$0889,$0186,$0666
	DC.W $0188,$0444,$018A,$0333,$018C,$0222,$018E,$0515

	.BplPtrs:
	DC.W $E0,0
	DC.W $E2,0
	DC.W $E4,0
	DC.W $E6,0
	DC.W $E8,0
	DC.W $EA,0
	DC.W $EC,0
	DC.W $EE,0
	DC.W $F0,0
	DC.W $F2,0
	DC.W $F4,0
	DC.W $F6,0

	.SpritePointers:
	DC.W $120,0,$122,0 ; 0
	DC.W $124,0,$126,0 ; 1
	DC.W $128,0,$12A,0 ; 2
	DC.W $12C,0,$12E,0 ; 3
	DC.W $130,0,$132,0 ; 4
	DC.W $134,0,$136,0 ; 5
	DC.W $138,0,$13A,0 ; 6
	DC.W $13C,0,$13E,0 ; 7
	DC.W $13F,0,$140,0 ; 8

	.SpriteColors:
	DC.W $1A0,$000
	DC.W $1A2,$000
	DC.W $1A4,$000
	DC.W $1A6,$000

	DC.W $1A8,$000
	DC.W $1AA,$000
	DC.W $1AC,$000
	DC.W $1AE,$000

	DC.W $1B0,$000
	DC.W $1B2,$FFF
	DC.W $1B4,$000
	DC.W $1B6,$000

	DC.W $1B8,$000
	DC.W $1BA,$111
	DC.W $1BC,$000
	DC.W $1BE,$000

	.CopperWaits:

	DC.W $FFDF,$FFFE		; allow VPOS>$ff
	DC.W $2201,$FF00		; horizontal position masked off
	DC.W $0180,$000F		; BG COLOR

	;DC.W COPJMP1,$000	; COPJMP1 - fai partire la copperlist 1

	DC.W COP1LCH
	.CopJumpH:
	DC.W $FFFF
	DC.W COP1LCL
	.CopJumpL:
	DC.W $FFFF

	DC.W $FFFF,$FFFE		; magic value to end copperlist

SPRT_SCROLL_2:
	DC.B $20			; Posizione verticale di inizio sprite (da $2c a $f2)
	DC.B $D7			; Posizione orizzontale di inizio sprite (da $40 a $d8)
	DC.B $FF			; $50+13=$5d	; posizione verticale di fine sprite
	DC.B $03
	SECTION "ChipBuffers",BSS_C	;BSS doesn't count toward exe size
	SCROLL_AREA:
	DCB.W 10*2,0
	SCROLL_VISIBLE:
	DCB.W 255*2,0
	HIDDEN_BUFFER:
	DCB.W 22*2,0
	SECTION "ChipData",DATA_C	;declared data that must be in chipmem
	DC.W 0,0

	SECTION "ChipBuffers",BSS_C	;BSS doesn't count toward exe size
SCREEN2:	DCB.B h*bwid+bpl,10; two buffers

	SECTION "ChipData",DATA_C	;declared data that must be in chipmem
SPRT_SCROLL:		; THE SHADOW
	DC.B $22		; Posizione verticale di inizio sprite (da $2c a $f2)
	DC.B $D8		; Posizione orizzontale di inizio sprite (da $40 a $d8)
	DC.B $FF		; $50+13=$5d	; posizione verticale di fine sprite
	DC.B $03
	SECTION "ChipBuffers",BSS_C	;BSS doesn't count toward exe size
	SCROLL_AREA_2:
	DCB.W 10*2,0
	SCROLL_VISIBLE_2:
	DCB.W 255*2,1
	HIDDEN_BUFFER_2:
	DCB.W 22*2,0
	SECTION "ChipData",DATA_C	;declared data that must be in chipmem
	DC.W 0,0

END