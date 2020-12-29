	DC.W COP1LCH		; AREA TO POKE VALUES
	.CopJumpH:		; FOR THE TWO COPPERLISTS
	DC.W $FFFF
	DC.W COP1LCL
	.CopJumpL:
	DC.W $FFFF

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
	DC.W $100,%1100001000000100	; BPLCON0 1011 0010 0000 0100

	.Palette:	
	DC.W $0180,$0000,$0182,$0DED,$0184,$0AAC,$0186,$0999
	DC.W $0188,$0888,$018A,$0666,$018C,$0444,$018E,$0222
	.ColorChangers:
	DC.W $0190,$0515,$0192,$0AAB,$0194,$0AAB,$0196,$0AAB
	DC.W $0198,$0AAB,$019A,$0AAB,$019C,$0AAB,$019E,$0AAB

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
	DC.W $1B2,$000
	DC.W $1B4,$FFF
	DC.W $1B6,$000

	DC.W $1B8,$000
	DC.W $1BA,$000
	DC.W $1BC,$000
	DC.W $1BE,$000

	.CopperWaits:
	;DC.W $3441,$FFFE		; HPOS
	;DC.W $0180,$0F00		; BG COLOR
	;DC.W $0180,$0FF0		; BG COLOR
	;DC.W $0180,$0F0F		; BG COLOR

	;DC.W $FFDF,$FFFE		; allow VPOS>$ff

	DC.W $FFFF,$FFFE		; magic value to end copperlist