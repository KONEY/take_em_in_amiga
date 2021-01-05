;*** TONY MANERO EFFECT!!
;*** MiniStartup by Photon ***
	INCDIR	"NAS:AMIGA/CODE/take_em_in_amiga/"
	SECTION	"Code",CODE
	INCLUDE	"Blitter-Register-List.S"
	INCLUDE	"PhotonsMiniWrapper1.04!.S"
	INCLUDE	"PT12_OPTIONS.i"
	INCLUDE	"P6112-Play-stripped.i"
;********** Constants **********
w=640			; screen width, height, depth
h=512
bpls=4			; handy values:
bpl=w/16*2		; byte-width of 1 bitplane line (80)
bwid=bpls*bpl		; byte-width of 1 pixel line (all bpls)
;*************
MODSTART_POS=0		; start music at position # !! MUST BE EVEN FOR 16BIT
SCROLLFACTOR=8
;*************

;********** Demo **********	; Demo-specific non-startup code below.
Demo:				; a4=VBR, a6=Custom Registers Base addr
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
	LEA	KONEYBG,A0

	MOVEQ	#bpl,D0
	LEA	COPPER1\.BplPtrs+2,A1
	MOVEQ	#bpls-1,D1
	BSR.W	PokePtrs

	MOVEQ	#bpl,D0
	LEA	COPPER2\.BplPtrs+2,A1
	MOVEQ	#bpls-1,D1
	BSR.W	PokePtrs

	; #### Point LOGO sprites
	LEA	COPPER1\.SpritePointers,A1	; Puntatori in copperlist
	BSR.W	__POKE_SPRITE_POINTERS
	LEA	COPPER2\.SpritePointers,A1	; Puntatori in copperlist
	BSR.W	__POKE_SPRITE_POINTERS
	; #### Point LOGO sprites

	; #### Call P61_Init ####
	MOVEM.L	D0-A6,-(SP)
	LEA	MODULE,A0
	SUB.L	A1,A1
	SUB.L	A2,A2
	MOVE.W	#MODSTART_POS,P61_InitPos	; TRACK START OFFSET
	JSR	P61_Init
	MOVEM.L (SP)+,D0-A6
	; #### Call P61_Init ####

	; #### POINT COPPERLISTS
	BSR.W	__POINT_COPPERLISTS
	MOVE.W	#$0515,$DFF190	; POKE "K" WITH CPU
	; #### POINT COPPERLISTS

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

	; do stuff here :)
	BSR.W	__POPULATE_TXT_BUFFER
	BSR.W	__SCROLL_SPRITE_COLUMN

	; ## SONG POS RESETS ##
	MOVE.W	P61_Pos,D6
	MOVE.W	P61_DUMMY_POS,D5
	CMP.W	D5,D6
	BEQ.S	.dontReset
	ADDQ.W	#1,P61_DUMMY_POS
	ADDQ.W	#1,P61_LAST_POS
	.dontReset:
	; ## SONG POS RESETS ##

	SONG_BLOCKS_EVENTS:
	;* FOR TIMED EVENTS ON BLOCK ****
	MOVE.W	P61_LAST_POS,D5
	LEA	TIMELINE,A3
	LSL.W	#2,D5		; CALCULATES OFFSET (OPTIMIZED)
	MOVE.L	(A3,D5),A4	; THANKS HEDGEHOG!!
	JSR	(A4)		; EXECUTE SUBROUTINE BLOCK#

	;*--- main loop end ---*
	BTST	#6,$BFE001
	BNE.S	.DontShowRasterTime
	MOVE.W	#$0F0,$180(A6)	; show rastertime left down to $12c
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
	BSR	WaitBlitter
	MOVE.W	#$FFFF,BLTAFWM		; BLTAFWM lo spiegheremo dopo
	MOVE.W	#$FFFF,BLTALWM		; BLTALWM lo spiegheremo dopo
	MOVE.W	#%0000000000000000,BLTCON1	; BLTCON1 BIT 12 DESC MODE
	MOVE.W	#0,BLTAMOD		; BLTAMOD =0 perche` il rettangolo
	MOVE.W	#0,BLTDMOD		; BLTDMOD 40-4=36 il rettangolo

	.goBlitter:
	MOVE.W	#%0001100111110000,BLTCON0	; BLTCON0 (usa A+D); con shift di un pixel
	LEA	SPRT_SCROLL_1\.visible,A4
	MOVE.L	A4,BLTAPTH		; BLTAPT  (fisso alla figura sorgente)
	LEA	SPRT_SCROLL_2\.visible,A5
	SUB.L	#4,A5
	MOVE.L	A5,BLTDPTH		; CLONE TO SHADOW
	MOVE.W	#266*3*64+1,BLTSIZE ; BLTSIZE (via al blitter !)
	
	BSR	WaitBlitter
	MOVE.W	#%0000100111110000,BLTCON0	; BLTCON0 (usa A+D); con shift di un pixel
	;LEA	SPRT_SCROLL_1\.visible,A4
	MOVE.L	A4,BLTAPTH		; BLTAPT  (fisso alla figura sorgente)
	SUB.L	#4,A4
	MOVE.L	A4,BLTDPTH
	;MOVE.W	#(272+14<<6)+%00010101,BLTSIZE ; BLTSIZE (via al blitter !)
	MOVE.W	#266*3*64+1,BLTSIZE ; BLTSIZE (via al blitter !)
	; ## MAIN BLIT ####
	
	MOVEM.L	(SP)+,D0-A6	; FETCH FROM STACK
	RTS

__POPULATE_TXT_BUFFER:
	MOVEM.L	D0-A6,-(SP)	; SAVE TO STACK
	MOVE.W	FRAMESINDEX,D7
	CMP.W	#SCROLLFACTOR,D7
	BNE.W	.SKIP
	LEA	SPRT_SCROLL_1\.hidden,A4
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

__POKE_SPRITE_POINTERS:
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
	MOVE.L	#SPRT_SCROLL_1,D0	; sprite 5
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)

	ADDQ.W	#8,A1
	MOVE.L	#SPRT_SCROLL_2,D0	; sprite 6 SHADOW
	MOVE.W	D0,6(A1)
	SWAP	D0
	MOVE.W	D0,2(A1)
	RTS

__POINT_COPPERLISTS:
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

	SWAP	D0
	MOVE.L	D0,COP1LC	; COP1LCH
	RTS

__SET_PT_VISUALS:
	; ## MOD VISUALIZERS ##########
	ifne visuctrs
	;MOVEM.L D0-A6,-(SP)

	; BASS
	LEA	P61_visuctr0(PC),A0	; which channel? 0-3
	MOVEQ	#19,D0			; maxvalue
	SUB.W	(A0),D0			; -#frames/irqs since instrument trigger
	BPL.S	.ok0			; below minvalue?
	MOVEQ	#0,D0			; then set to minvalue
	.ok0:
	MOVE.B	D0,AUDIOCHLEVEL0
	BCLR.L	#0,D0			; MAKES INDEX EVEN
	_ok0:

	; KICK
	LEA	P61_visuctr1(PC),A0		; which channel? 0-3
	MOVEQ	#14,D1			; maxvalue
	SUB.W	(A0),D1			; -#frames/irqs since instrument trigger
	BPL.S	.ok1			; below minvalue?
	MOVEQ	#0,D1			; then set to minvalue
	.ok1:
	MOVE.B	D1,AUDIOCHLEVEL1
	BCLR.L	#0,D1			; MAKES INDEX EVEN
	_ok1:

	; HATZ
	LEA	P61_visuctr2(PC),A0	; which channel? 0-3
	MOVEQ	#19,D2			; maxvalue
	SUB.W	(A0),D2			; -#frames/irqs since instrument trigger
	BPL.S	.ok2			; below minvalue?
	MOVEQ	#0,D2			; then set to minvalue
	.ok2:
	MOVE.B	D2,AUDIOCHLEVEL2
	BCLR.L	#0,D2			; MAKES INDEX EVEN
	_ok2:

	; DRUMZ
	LEA	P61_visuctr3(PC),A0	; which channel? 0-3
	MOVEQ	#19,D3			; maxvalue
	SUB.W	(A0),D3			; -#frames/irqs since instrument trigger
	BPL.S	.ok3			; below minvalue?
	MOVEQ	#0,D3			; then set to minvalue
	.ok3:
	MOVE.B	D3,AUDIOCHLEVEL3
	BCLR.L	#0,D3			; MAKES INDEX EVEN
	_ok3:

	LEA	COPPER1\.ColPokes,A1	; OPTIMIZATIONS
	LEA	COPPER2\.ColPokes,A2	; OPTIMIZATIONS
	LEA	COL_TAB_PURPLE,A3		; OPTIMIZATIONS
	LEA	COL_TAB_WHITE,A4		; OPTIMIZATIONS
	LEA	COL_TAB_BLACK,A5		; OPTIMIZATIONS
	LEA	COL_TAB_GREY,A0		; OPTIMIZATIONS

	;MOVEM.L (SP)+,D0-A6
	endc
	RTS
	; MOD VISUALIZERS *****

__BLOCK_X:
	; 0: BEGIN
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	MOVE.W	(A5,D1.W),14(A1)		; FX 1
	MOVE.W	(A5,D1.W),14(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A4,D2.W),18(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A4,D2.W),18(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A4,D3.W),22(A2)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A4,D3.W),22(A1)		; 4(A2) FOR GLITCH!!
	RTS

__BLOCK_0:
	; 0: BEGIN
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	;MOVE.W	(A5,D1.W),22(A1)		; FX 1
	;MOVE.W	(A5,D1.W),22(A2)		; 4(A2) FOR GLITCH!!
	RTS

__BLOCK_1:
	; 0: BEGIN
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	MOVE.W	(A0,D1.W),26(A1)		; FX 1
	MOVE.W	(A0,D1.W),26(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D1.W),22(A1)		; FX 1
	MOVE.W	(A5,D1.W),22(A2)		; 4(A2) FOR GLITCH!!
	RTS

__BLOCK_2:
	; 0: BEGIN
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	MOVE.W	(A0,D1.W),26(A1)		; FX 1
	MOVE.W	(A0,D1.W),26(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D1.W),22(A1)		; FX 1
	MOVE.W	(A0,D1.W),22(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D2.W),14(A1)		; FX 1
	MOVE.W	(A5,D2.W),14(A2)		; 4(A2) FOR GLITCH!!
	RTS

__BLOCK_3:
	; 0: BEGIN
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	MOVE.W	(A0,D1.W),26(A1)		; FX 1
	MOVE.W	(A0,D1.W),26(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D2.W),14(A1)		; FX 1
	MOVE.W	(A5,D2.W),14(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D3.W),10(A1)		; FX 1
	MOVE.W	(A5,D3.W),10(A2)		; 4(A2) FOR GLITCH!!
	RTS

__BLOCK_4:
	; 0: BEGIN
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	MOVE.W	(A5,D1.W),26(A1)		; FX 1
	MOVE.W	(A0,D1.W),26(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A4,D2.W),6(A1)		; FX 1
	MOVE.W	(A4,D2.W),6(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D3.W),22(A1)		; FX 1
	MOVE.W	(A5,D3.W),22(A2)		; 4(A2) FOR GLITCH!!
	RTS

__BLOCK_5:
	; 0: BEGIN
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	MOVE.W	(A5,D1.W),22(A1)		; FX 1
	MOVE.W	(A5,D1.W),22(A2)		; 4(A2) FOR GLITCH!!

	ADDQ.W	#8,A0			; CHANGE COLOR
	MOVE.W	(A0,D3.W),18(A1)		; FX 1
	MOVE.W	(A0,D3.W),18(A2)		; 4(A2) FOR GLITCH!!
	RTS

__BLOCK_6:
	; 29: KASSONE!
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	MOVE.W	(A5,D2.W),2(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A5,D2.W),2(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A4,D1.W),6(A1)		; FX 1
	MOVE.W	(A4,D1.W),6(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D2.W),10(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A0,D2.W),10(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D1.W),14(A1)		; FX 1
	MOVE.W	(A5,D1.W),14(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D2.W),18(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A0,D2.W),18(A2)		; 4(A2) FOR GLITCH!!

	ADDQ.W	#8,A0			; CHANGE COLOR
	MOVE.W	(A0,D3.W),22(A2)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A0,D3.W),22(A1)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A4,D0.W),26(A1)		; FX 1
	MOVE.W	(A4,D0.W),26(A2)		; 4(A2) FOR GLITCH!!

	RTS

__BLOCK_7:
	; 29: KASSONE!
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	MOVE.W	(A5,D1.W),2(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A5,D1.W),2(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A4,D2.W),6(A1)		; FX 1
	MOVE.W	(A4,D3.W),6(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D3.W),10(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A0,D3.W),10(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A4,D1.W),14(A1)		; FX 1
	MOVE.W	(A4,D1.W),14(A2)		; 4(A2) FOR GLITCH!!

	ADDQ.W	#8,A0			; CHANGE COLOR
	MOVE.W	(A0,D2.W),18(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A0,D2.W),18(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D3.W),22(A2)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A5,D3.W),22(A1)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A4,D2.W),26(A1)		; FX 1
	MOVE.W	(A4,D2.W),26(A2)		; 4(A2) FOR GLITCH!!

	RTS

__BLOCK_8:
	; 0: BEGIN
	BSR.W	__SET_PT_VISUALS

	;MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	MOVE.W	(A0,D1.W),26(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A0,D1.W),26(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D3.W),6(A1)		; FX 1
	MOVE.W	(A5,D3.W),6(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A4,D1.W),14(A1)		; FX 1
	MOVE.W	(A4,D1.W),14(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D3.W),18(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A0,D3.W),18(A2)		; 4(A2) FOR GLITCH!!

	ADDQ.W	#8,A0			; CHANGE COLOR
	MOVE.W	(A0,D2.W),22(A2)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A0,D2.W),22(A1)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A4,D3.W),10(A1)		; FX 1
	MOVE.W	(A4,D3.W),10(A2)		; 4(A2) FOR GLITCH!!

	;MOVE.W	(A3,D0.W),2(A1)		; 4(A2) FOR GLITCH!!
	;MOVE.W	(A3,D0.W),2(A2)		; 4(A2) FOR GLITCH!!

	RTS

__BLOCK_9:
	; 0: BEGIN
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	MOVE.W	(A3,D3.W),2(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A3,D2.W),2(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D1.W),26(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A0,D1.W),26(A2)		; 4(A2) FOR GLITCH!!

	ADDQ.W	#8,A0			; CHANGE COLOR
	MOVE.W	(A0,D3.W),10(A1)		; FX 1
	MOVE.W	(A0,D3.W),10(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	P61_rowpos,D5
	CMPI.W	#15,D5
	BGE.S	.noFx
	MOVE.W	(A4,D1.W),6(A1)		; FX 1
	MOVE.W	(A5,D1.W),6(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A3,D1.W),14(A1)		; FX 1
	MOVE.W	(A3,D1.W),14(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D1.W),18(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A4,D1.W),18(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A3,D2.W),22(A2)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A5,D2.W),22(A1)		; 4(A2) FOR GLITCH!!
	.noFx:
	
	RTS

__BLOCK_A:
	; 29: KASSONE!
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A5,D1.W),2(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A5,D1.W),2(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D2.W),6(A1)		; FX 1
	MOVE.W	(A0,D3.W),6(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D2.W),10(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A5,D2.W),10(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D2.W),14(A1)		; FX 1
	MOVE.W	(A0,D2.W),14(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D3.W),18(A1)		; FX 1
	MOVE.W	(A5,D3.W),18(A2)		; 4(A2) FOR GLITCH!!

	ADDQ.W	#8,A0			; CHANGE COLOR
	MOVE.W	(A0,D0.W),22(A2)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A0,D0.W),22(A1)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D3.W),26(A1)		; FX 1
	MOVE.W	(A0,D3.W),26(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D3.W),30(A1)		; FX 1
	MOVE.W	(A0,D3.W),30(A2)		; 4(A2) FOR GLITCH!!

	; ## CHANGE TILE EVERY BEAT ##
	MOVE.W	TILE_INDEX,D6
	MOVE.B	AUDIOCHLEVEL3,D5
	CMP.B	#15,D5
	BNE.S	.dontUpdate
	ADD.W	#1,D6
	AND.W	#7,D6			; EVERY 7 RESET
	MOVE.W	D6,TILE_INDEX
	.dontUpdate:

	ADDQ.W	#2,A1
	ADDQ.W	#2,A2
	LSL.W	#2,D6			; CALCULATES OFFSET (OPTIMIZED)
	;CLR.W	$100			; DEBUG | w 0 100 2
	ADD.W	D6,A1
	ADD.W	D6,A2

	MOVE.W	(A3,D3.W),(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A3,D3.W),(A2)		; 4(A2) FOR GLITCH!!
	; ## CHANGE TILE EVERY BEAT ##

	ADDQ.W	#8,A3			; CHANGE COLOR
	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	RTS

__BLOCK_B:
	; 29: KASSONE!
	BSR.W	__SET_PT_VISUALS

	MOVE.W	(A5,D1.W),2(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A5,D1.W),2(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D2.W),6(A1)		; FX 1
	MOVE.W	(A0,D3.W),6(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D2.W),10(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A5,D2.W),10(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D2.W),14(A1)		; FX 1
	MOVE.W	(A0,D2.W),14(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A5,D3.W),18(A1)		; FX 1
	MOVE.W	(A5,D3.W),18(A2)		; 4(A2) FOR GLITCH!!

	ADDQ.W	#8,A0			; CHANGE COLOR
	MOVE.W	(A0,D0.W),22(A2)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A0,D0.W),22(A1)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A0,D3.W),26(A1)		; FX 1
	MOVE.W	(A0,D3.W),26(A2)		; 4(A2) FOR GLITCH!!

	MOVE.W	(A4,D3.W),30(A1)		; FX 1
	MOVE.W	(A4,D3.W),30(A2)		; 4(A2) FOR GLITCH!!

	; ## CHANGE TILE EVERY BEAT ##
	MOVE.B	AUDIOCHLEVEL3,D5
	MOVE.W	P61_rowpos,D7
	CMPI.W	#15,D7
	BGE.S	.noFx
	MOVE.B	AUDIOCHLEVEL2,D5
	MOVE.W	D2,D3
	.noFx:

	MOVE.W	TILE_INDEX,D6

	CMP.B	#15,D5
	BNE.S	.dontUpdate
	ADD.W	#1,D6
	AND.W	#7,D6			; EVERY 7 RESET
	MOVE.W	D6,TILE_INDEX
	.dontUpdate:

	ADDQ.W	#2,A1
	ADDQ.W	#2,A2
	LSL.W	#2,D6			; CALCULATES OFFSET (OPTIMIZED)
	;CLR.W	$100			; DEBUG | w 0 100 2
	ADD.W	D6,A1
	ADD.W	D6,A2

	MOVE.W	(A3,D3.W),(A1)		; 4(A2) FOR GLITCH!!
	MOVE.W	(A3,D3.W),(A2)		; 4(A2) FOR GLITCH!!
	; ## CHANGE TILE EVERY BEAT ##

	ADDQ.W	#8,A3			; CHANGE COLOR
	MOVE.W	(A3,D0.W),$DFF190		; POKE "K" WITH CPU

	RTS

__BLOCK_END:
	; 0: EMPTY_BEGIN
	MOVEM.L D0-A6,-(SP)
	JSR P61_End
	MOVEM.L (SP)+,D0-A6
	RTS

;********** Fastmem Data **********
AUDIOCHLEVEL0:	DC.W 0
AUDIOCHLEVEL1:	DC.W 0
AUDIOCHLEVEL2:	DC.W 0
AUDIOCHLEVEL3:	DC.W 0
TILE_INDEX:	DC.W 0
P61_LAST_POS:	DC.W MODSTART_POS
P61_DUMMY_POS:	DC.W 0
P61_FRAMECOUNT:	DC.W 0
TEXTINDEX:	DC.W 0
FRAMESINDEX:	DC.W SCROLLFACTOR
DrawBuffer:	DC.L KONEYBG	; pointers to buffers to be swapped
ViewBuffer:	DC.L KONEYBG

COL_TAB_PURPLE:	DC.W $0101
		DC.W $0202
		DC.W $0303
		DC.W $0313
		DC.W $0404
		DC.W $0414
		DC.W $0505
		DC.W $0515
		DC.W $0606
		DC.W $0616
		DC.W $0717	; NEW RANGE
		DC.W $0818
		DC.W $0919
		DC.W $0A1A

COL_TAB_WHITE:	DC.W $0556,$0666
		DC.W $0667,$0777
		DC.W $0778,$0888
		DC.W $0889,$0999
		DC.W $099A,$0AAA
		DC.W $0AAB,$0BBB
		DC.W $0BBC,$0CCC
		DC.W $0CCD,$0DDD
		DC.W $0DDE,$0EEE
		DC.W $0EEF,$0FFF

COL_TAB_GREY:	DC.W $0AAC,$0AAC
		DC.W $0AAC,$0AAC
		DC.W $0AAC,$0AAC
		DC.W $0AAC,$0AAA
		DC.W $0AAA,$0AAB
		DC.W $0BBB,$0BBC
		;DC.W $0CCC,$0CCD
		;DC.W $0DDD,$0DDE
		;DC.W $0EEE,$0EEF
		;DC.W $0EEF,$0FFF

COL_TAB_BLACK:	DC.W $0CCC,$0CCB
		DC.W $0BBC,$0BBB
		DC.W $0AAB,$0AAA
		DC.W $0AA9,$0A99
		DC.W $099A,$0999
		DC.W $0889,$0888
		DC.W $0778,$0777
		DC.W $0666,$0555
		DC.W $0444,$0333
		DC.W $0222,$0111

TIMELINE:		DC.L __BLOCK_0,__BLOCK_0	; 1 0:
		DC.L __BLOCK_1,__BLOCK_1	; 2 1: a_1
		DC.L __BLOCK_2,__BLOCK_2	; 5 3: clsdhat
		DC.L __BLOCK_3,__BLOCK_3	; 7 4: +Rulante
		DC.L __BLOCK_4,__BLOCK_4	; 9 6: cambio - kick2
		DC.L __BLOCK_2,__BLOCK_3	; 11 8: Kontinua2
		DC.L __BLOCK_5,__BLOCK_5	; 13 10: Konti CAMBIO!
		DC.L __BLOCK_6,__BLOCK_6	; 15 29: Ferryman BatLev KASSONE!
		DC.L __BLOCK_X,__BLOCK_X	; 17 11: Kuasi Levare
		DC.L __BLOCK_7,__BLOCK_7	; 19 28: Ferryman BatLev
		DC.L __BLOCK_X,__BLOCK_8	; 21 13: cambio2_2 senzakassa
		DC.L __BLOCK_8,__BLOCK_9	; 23 14: Cambio2_3
		DC.L __BLOCK_A,__BLOCK_A	; 25 15: LEVARE completo (claps)
		DC.L __BLOCK_A,__BLOCK_A	; 27 16: LEVARE completo Cambio
		DC.L __BLOCK_A,__BLOCK_A	; 29 17: COMPLETO2
		DC.L __BLOCK_A,__BLOCK_B	; 31 18: completo2 cambio
		DC.L __BLOCK_4,__BLOCK_4	; 33 20: SAle
		DC.L __BLOCK_END

;**************************************************************
	SECTION "ChipData",DATA_C	;declared data that must be in chipmem
;**************************************************************

MODULE:	INCBIN "take_em_in_V3.P61"	; code $9100

SPRITES:	INCLUDE "sprite_KONEY.s"

FONT:	DC.L 0,0		; SPACE CHAR
	INCBIN "cyber_font.raw",0
	EVEN

TEXT:	DC.B "                "
	DC.B "WELCOME TO ### TAKE-EM IN ### KONEY THIRD AMIGA INTRO RELEASE !! "
	DC.B "THIS TIME I AM USING AN OLD TECHNO TRACK FROM 1997 OR 1998... "
	DC.B "IT IS FROM THE DETROIT TECHNO ERA SO 140 BPM IS THE STANDARD - "
	DC.B "IF I REMEMBER WELL THIS TRACK WAS MADE USING INSTRUMENTS I MADE "
	DC.B "BY SAMPLING MY ROLAND TR-909 ON THE AMIGA WITH AN 8-BIT SAMPLER. "
	DC.B "LATER I HAD TO SELL THE MOST ICONIC DRUMMACHINE EVER SO THIS IS "
	DC.B "QUITE A SOUVENIR FOR ME... "
	DC.B "THIS TRACK WAS NEVER PUBLISHED BEFORE BUT IT FITTED WERY WELL WITH "
	DC.B "THE HIRES LACED SCREEN VISUALS I HAD IN MIND ! THIS TIME BUT I HAVE "
	DC.B "BEEN TESTING HOW TO WORK IN HD ! "
	DC.B "NOT TOO COMPLICATED BUT FOR SURE NOW I SEE WHY THERE ARE NOT SO " 
	DC.B "MANY HIRES LACED RELEASES OUT ! AS MENTIONED NOT MANY ANIMATIONS "
	DC.B "THIS TIME - JUST SOME COLOR SHIFT IN THE MAIN GRAPHIC AREA TO "
	DC.B "OBTAIN WHAT I LIKE TO CALL THE TONY MANERO EFFECT !! --- "
	DC.B "SO I HAVE BEEN EDITING THIS TEXT AT LEAST FOUR TIMES NOW AS IT "
	DC.B "TURNS OUT THAT NORMAL TEXT RULES DO NOT APPLY VERY WELL WHEN "
	DC.B "TEXT IS VERTICAL... QUOTES AND COMMAS AND STUFF LIKE THAT LOSE "
	DC.B "THEIR EFFECT WHEN READ VERTICALLY --- "
	DC.B "AGAIN I WANT TO THANK THE NICE GUYS UPVOTING MY LAST PRODUCTION "
	DC.B "ON POUET.NET BUT ALSO THE ONES WHO DOWNVOTED IT BECAUSE "
	DC.B "ARTICULATED COMMENTS ARE GREAT TO HELP N00BZ IMPROVE... EH EH EH "
	DC.B "--- WELL I MUST SAY AMIGA CODING IS BECOMING QUITE A THING TO "
	DC.B "ME - EVEN IF I REALIZE I AM STILL A VERY BASIC CODER I AM "
	DC.B "STARTING TO DREAM ABOUT ASSEMBLY INSTRUCTIONS ! SO I CAN SAY "
	DC.B "THIS IS THE CREATIVE STEP IT WAS MISSING TO ME TO EXPRESS "
	DC.B "IN A VISUAL WAY THE MUSIC I MADE ON THE AMIGA OVER THE YEARS - "
	DC.B "TO RELEASE ALL MY AMIGA MUSIC I NEED TO USE OCTAMED PLAYROUTINES "
	DC.B "WHICH I HAD TO WORK BUT IT SEEMS LIKE THEY ONLY WORK IN A SYSTEM "
	DC.B "FRIENDLY ENVIRONMENT SO WHEN BANGING DIRECTLY THE HARDWAY THEY "
	DC.B "WILL EITHER CRASH OR STAY SILENT - I TRIED TO FIND HELP ON EAB "
	DC.B "BUT NO LUCK - THIS IS STILL BEYOND MY SKILLS SO IF SOMEONE IS "
	DC.B "WILLING TO HELP ADAPT THESE ROUTINE I AM PRETTY SURE THEY WILL "
	DC.B "BE USEFUL TO THE SCENE ! --- WELL NOW I RAN OUT OF SPACE FOR "
	DC.B "TEXT AND BASICALLY I HAVE NOT MUCH MORE TO SAY ! - JUST "
	DC.B "REMEMBER TO VISIT MY WEBSITE WWW.KONEY.ORG AND MY GITHUB PAGE "
	DC.B "WITH THE SOURCE CODE TO MY PRODUCTIONS ! -- AND REMEMBER - ONLY "
	DC.B "AMIGA MAKES IT POSSIBLE !!!!! --            .EOF              "
	EVEN
_TEXT:

KONEYBG:	INCBIN "klogo_hdV3.raw"

COPPER1: INCLUDE "copperlist_common.i" _COPPER1:
COPPER2: INCLUDE "copperlist_common.i" _COPPER2:

SPRT_SCROLL_1:
	DC.B $20			; Posizione verticale di inizio sprite (da $2c a $f2)
	DC.B $D6			; Posizione orizzontale di inizio sprite (da $40 a $d8)
	DC.B $FF			; $50+13=$5d	; posizione verticale di fine sprite
	DC.B $03
	;SECTION "ChipBuffers",BSS_C	;BSS doesn't count toward exe size
	.scroll_area:
	DCB.W 10*2,0
	.visible:
	DCB.W h/2*2,0
	.hidden:
	DCB.W h,0
	;SECTION "ChipData",DATA_C	;declared data that must be in chipmem
	DC.W 0,0

SPRT_SCROLL_2:			; THE SHADOW
	DC.B $21			; Posizione verticale di inizio sprite (da $2c a $f2)
	DC.B $D6			; Posizione orizzontale di inizio sprite (da $40 a $d8)
	DC.B $FF			; $50+13=$5d	; posizione verticale di fine sprite
	DC.B $03
	;SECTION "ChipBuffers",BSS_C	;BSS doesn't count toward exe size
	.scroll_area:
	DCB.W 10*2,0
	.visible:
	DCB.W h/2*2,0
	.hidden:
	DCB.W h,0
	;SECTION "ChipData",DATA_C	;declared data that must be in chipmem
	DC.W 0,0

END