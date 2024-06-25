; a2600 hardware registers

; TIA
; write
VSYNC   = $00
VBLANK  = $01
WSYNC   = $02
RSYNC   = $03
NUSIZ0  = $04
NUSIZ1  = $05
COLUP0  = $06
COLUP1  = $07
COLUPF  = $08
COLUBK  = $09
CTRLPF  = $0a
REFP0   = $0b
REFP1   = $0c
PF0     = $0d
PF1     = $0e
PF2     = $0f
RESP0   = $10
RESP1   = $11
RESM0   = $12
RESM1   = $13
RESBL   = $14
AUDC0   = $15
AUDC1   = $16
AUDF0   = $17
AUDF1   = $18
AUDV0   = $19
AUDV1   = $1a
GRP0    = $1b
GRP1    = $1c
ENAM0   = $1d
ENAM1   = $1e
ENABL   = $1f
HMP0    = $20
HMP1    = $21
HMM0    = $22
HMM1    = $23
HMBL    = $24
VDELP0  = $25
VDELP1  = $26
VDELBL  = $27
RESMP0  = $28
RESMP1  = $29
HMOVE   = $2a
HMCLR   = $2b
CXCLR   = $2c
; read
CXM0P   = $30
CXM1P   = $31
CXP0FB  = $32
CXP1FB  = $33
CXM0FB  = $34
CXM1FB  = $35
CXBLPF  = $36
CXPPMM  = $37
INPT0   = $38
INPT1   = $39
INPT2   = $3a
INPT3   = $3b
INPT4   = $3c
INPT5   = $3d

; RIOT
SWCHA   = $0280
SWACNT  = $0281
SWCHB   = $0282
SWBCNT  = $0283
INTIM   = $0284
INSTAT  = $0285
TIM1T   = $0294
TIM8T   = $0295
TIM64T  = $0296
T1024T  = $0297

; 32k bank switches
BANK0   = $fff4
BANK1   = $fff5
BANK2   = $fff6
BANK3   = $fff7
BANK4   = $fff8
BANK5   = $fff9
BANK6   = $fffa
BANK7   = $fffb
