SPRT_K:	
	DC.B	$37	; Posizione verticale di inizio sprite (da $2c a $f2)
	SPRT_K_POS:
	DC.B	$44	; Posizione orizzontale di inizio sprite $44
	DC.B	$46	; $50+13=$5d	; posizione verticale di fine sprite
	DC.B	$00
	DC.W	$E00E,$E00E,$E00E,$E00E,$E00E,$E00E
	DC.W	$E070,$E070,$E070,$E070,$E070,$E070
	DC.W	$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
	DC.W	$FC70,$FC70,$FC70,$FC70,$FC70,$FC70
	DC.W	$FC0E,$FC0E,$FC0E,$FC0E,$FC0E,$FC0E
	DC.W	0,0	; 2 word azzerate definiscono la fine dello sprite.
SPRT_O:	
	DC.B	$37	; Posizione verticale di inizio sprite (da $2c a $f2)
	SPRT_O_POS:
	DC.B	$44	; Posizione orizzontale di inizio sprite $4D
	DC.B	$46	; $50+13=$5d	; posizione verticale di fine sprite
	DC.B	$00
	DC.W	$FFFE,$FFFE,$FFFE,$FFFE,$FFFE,$FFFE
	DC.W	$E00E,$E00E,$E00E,$E00E,$E00E,$E00E
	DC.W	$FC0E,$FC0E,$FC0E,$FC0E,$FC0E,$FC0E
	DC.W	$FC0E,$FC0E,$FC0E,$FC0E,$FC0E,$FC0E
	DC.W	$FFFE,$FFFE,$FFFE,$FFFE,$FFFE,$FFFE
	DC.W	0,0	; 2 word azzerate definiscono la fine dello sprite.
SPRT_N:	
	DC.B	$37	; Posizione verticale di inizio sprite (da $2c a $f2)
	SPRT_N_POS:
	DC.B	$44	; Posizione orizzontale di inizio sprite $56
	DC.B	$46	; $50+13=$5d	; posizione verticale di fine sprite
	DC.B	$00
	DC.W	$FFFE,$FFFE,$FFFE,$FFFE,$FFFE,$FFFE
	DC.W	$E00E,$E00E,$E00E,$E00E,$E00E,$E00E
	DC.W	$FC0E,$FC0E,$FC0E,$FC0E,$FC0E,$FC0E
	DC.W	$FC0E,$FC0E,$FC0E,$FC0E,$FC0E,$FC0E
	DC.W	$FC0E,$FC0E,$FC0E,$FC0E,$FC0E,$FC0E
	DC.W	0,0	; 2 word azzerate definiscono la fine dello sprite.
SPRT_E:	
	DC.B	$37	; Posizione verticale di inizio sprite (da $2c a $f2)
	SPRT_E_POS:
	DC.B	$44	; Posizione orizzontale di inizio sprite $5F
	DC.B	$46	; $50+13=$5d	; posizione verticale di fine sprite
	DC.B	$00
	DC.W	$FFFE,$FFFE,$FFFE,$FFFE,$FFFE,$FFFE
	DC.W	$E000,$E000,$E000,$E000,$E000,$E000
	DC.W	$FFFE,$FFFE,$FFFE,$FFFE,$FFFE,$FFFE
	DC.W	$FC00,$FC00,$FC00,$FC00,$FC00,$FC00
	DC.W	$FFFE,$FFFE,$FFFE,$FFFE,$FFFE,$FFFE
	DC.W	0,0	; 2 word azzerate definiscono la fine dello sprite.
SPRT_Y:	
	DC.B	$37	; Posizione verticale di inizio sprite (da $2c a $f2)
	SPRT_Y_POS:
	DC.B	$44	; Posizione orizzontale di inizio sprite $68
	DC.B	$46	; $50+13=$5d	; posizione verticale di fine sprite
	DC.B	$00
	DC.W	$FC7E,$FC7E,$FC7E,$FC7E,$FC7E,$FC7E
	DC.W	$1FF0,$1FF0,$1FF0,$1FF0,$1FF0,$1FF0
	DC.W	$0380,$0380,$0380,$0380,$0380,$0380
	DC.W	$03F0,$03F0,$03F0,$03F0,$03F0,$03F0
	DC.W	$03F0,$03F0,$03F0,$03F0,$03F0,$03F0
	DC.W	0,0	; 2 word azzerate definiscono la fine dello sprite.

;SPRT_K_BG:	
;	DC.B	$A4	; Posizione verticale di inizio sprite (da $2c a $f2)
;	SPRT_K_BG_POS:
;	DC.B	$92	; Posizione orizzontale di inizio sprite (da $40 a $d8)
;	DC.B	$B3	; $50+13=$5d	; posizione verticale di fine sprite
;	DC.B	$00
;	DC.W	$E00E,$E00E,$E00E,$E00E,$E00E,$E00E
;	DC.W	$E070,$E070,$E070,$E070,$E070,$E070
;	DC.W	$FF80,$FF80,$FF80,$FF80,$FF80,$FF80
;	DC.W	$FC70,$FC70,$FC70,$FC70,$FC70,$FC70
;	DC.W	$FC0E,$FC0E,$FC0E,$FC0E,$FC0E,$FC0E
;	DC.W	0,0	; 2 word azzerate definiscono la fine dello sprite.

;SPRT_Y_BG:	
;	DC.B	$A4	; Posizione verticale di inizio sprite (da $2c a $f2)
;	SPRT_Y_BG_POS:
;	DC.B	$BD	; Posizione orizzontale di inizio sprite (da $40 a $d8)
;	DC.B	$B3	; $50+13=$5d	; posizione verticale di fine sprite
;	DC.B	$00
;	DC.W	$FC7E,$FC7E,$FC7E,$FC7E,$FC7E,$FC7E
;	DC.W	$1FF0,$1FF0,$1FF0,$1FF0,$1FF0,$1FF0
;	DC.W	$0380,$0380,$0380,$0380,$0380,$0380
;	DC.W	$03F0,$03F0,$03F0,$03F0,$03F0,$03F0
;	DC.W	$03F0,$03F0,$03F0,$03F0,$03F0,$03F0
;	DC.W	0,0	; 2 word azzerate definiscono la fine dello sprite.