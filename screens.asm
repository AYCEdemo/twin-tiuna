    .section screens_vars
r0  .word ?
r1  .word ?
r2  .word ?
r3  .word ?
r4  .word ?
r5  .word ?
    .endsection
    
load_hrl .macro
    lda #<\10
    sta r0
    lda #<\11
    sta r1
    lda #<\12
    sta r2
    lda #<\13
    sta r3
    lda #<\14
    sta r4
    lda #<\15
    sta r5
    .endmacro
    
load_hrh .macro
    lda #>\10
    sta r0+1
    sta r1+1
    sta r2+1
    sta r3+1
    sta r4+1
    sta r5+1
    .endmacro

    .section screens
endscreen_loop
    lda SWCHB
    and #1 ; reset?
    bne +
    jmp music_start
+   sta WSYNC
    lda #2
    sta VSYNC
    sta WSYNC
    sta WSYNC
    lda #0
    sta VSYNC
    sta WSYNC
    sta WSYNC

endscreen_entry
    ; top side border + right PF cover
    ; p0 @24. m1 @120. p1 @128. m0 @132.
    sta WSYNC   ; -68.
    ldy #5      ; -59.
    .page
-   dey
    bne -       ; 13.
    .endpage
    sta RESP0   ; 22. -> 24.
    ldy #5      ; 28.
    .page
-   dey
    bne -       ; 100.
    .endpage
    nop         ; 106.
    sta RESM1   ; 115. -> 116.
    sta RESP1   ; 124. -> 127.
    sta RESM0   ; 133. -> 134.
    lda #0
    sta HMP0
    lda #-$40
    sta HMM1
    lda #-$10
    sta HMP1
    lda #$20
    sta HMM0
    sta WSYNC
    sta HMOVE
    lda #$44
    sta COLUP0
    sta COLUPF
    lda #2
    sta ENAM0
    
    lda #1
    sta CTRLPF
    lda #0
    sta VDELP0
    sta VDELP1
    sta COLUP1
    sta GRP1
    sta ENAM1
    sta PF0
    lda #%00111111
    sta PF1
    lda #%11111111
    sta PF2
    lda #$f0
    sta GRP0
    lda #$20
    sta NUSIZ0
    lda #$37
    sta NUSIZ1
    
    ldy #21
    jsr wait_lines
    
    ; top border
    lda #0
    sta WSYNC
    sta VBLANK
    sta WSYNC
    sta WSYNC
    sta PF1
    sta PF2
    sta CTRLPF
    lda #$ff
    sta GRP1
    sta ENAM1
    
    ldy #7
    jsr wait_lines
    
    ; title
    ; preload subtitle pointers
    #load_hrh subt_gfx
    ldy #0
-
    lda title_gfxw,y
    tax
-   ; disp 40
    sta WSYNC   ; -68.
    lda #0      ; -62.
    sta COLUPF  ; -53.
    lda title_gfx0,y ; -41.
    sta PF0     ; -32.
    lda title_gfx1,y ; -20.
    sta PF1     ; -11.
    lda title_gfx2,y ;   1.
    sta PF2     ;  10.
    nop         ;  16.
    lda tmpA    ;  25.
    lda #$44    ;  31.
    sta COLUPF  ;  40.
    dex
    bne -
    iny
    cpy #size(title_gfx0)
    bne --
    
    ; subtitle
    ; p0 @ 56. p1 @ 64.
    sta WSYNC       ; -68.
    ldx #0          ; -62.
    stx PF0         ; -53.
    stx PF2         ; -44.
    lda #%00100000  ; -38.
    sta PF1         ; -29.
    inx             ; -23.
    stx CTRLPF      ; -14.
    stx VDELP0      ; - 5.
    stx VDELP1      ;   4.
    dex             ;  10.
    stx GRP0        ;  19.
    stx GRP1        ;  28.
    stx GRP0        ;  37.
    stx GRP1        ;  46.
    sta RESP0       ;  55. -> 60.
    sta RESP1       ;  64. -> 69.
    stx ENAM0
    stx ENAM1
    lda #$40
    sta HMP0
    lda #$50
    sta HMP1
    lda #3
    sta NUSIZ0
    sta NUSIZ1
    lda #$44
    sta COLUP1
    sta WSYNC
    sta HMOVE
    #load_hrl subt_gfx
    lda #size(subt_gfx0)-1
    jsr draw_hr
    sta VDELP0
    sta VDELP1
    
    ldy #6
    jsr wait_lines  ; -38.
    
    ; credits text
    ; p0 @ 44.
    lda #6          ; -32.
    sta NUSIZ0      ; -23.
    lda #$40        ; -17.
    sta HMP0        ; - 8.
    jsr wait_12     ;  28.
    nop             ;  34.
    sta RESP0       ;  43. -> 48.
    sta WSYNC
    sta HMOVE
    
    ldx #size(text0)-1
-
    sta WSYNC
    lda text0,x
    sta r0
    lda text1,x
    sta r1
    lda text2,x
    sta r2
    ldy #6
-   
    sta WSYNC
    lda (r0),y  ; -53.
    sta GRP0    ; -44. (44-52)
    jsr wait_12 ; - 8.
    jsr wait_12 ;  28.
    nop         ;  34
    lda (r1),y  ;  49.
    sta GRP0    ;  58. (76-84)
    nop         ;  64.
    lda (r2),y  ;  79.
    sta GRP0    ;  88. (108-116)
    dey
    bpl -
    sta WSYNC
    lda #0
    sta GRP0
    dex
    bpl --
    
    ldy #8
    jsr wait_lines
    
    ; bottom border
    lda #%00111111
    sta PF1
    lda #%11111111
    sta PF2
    sta WSYNC
    
    lda #2
    ldy #14
-   sta WSYNC
    sta VBLANK
    dey
    bne -
    jmp endscreen_loop
    
start
    cld
    ldx #$ff
    txs
    jsr clear_tia
    sta tmpA ; frame time = 256 frames
startscreen_loop
    lda SWCHB
    and #1 ; reset?
    beq +
    dec tmpA
    bne ++
+   jmp music_start
+   sta WSYNC
    lda #2
    sta VSYNC
    sta WSYNC
    sta WSYNC
    lda #0
    sta VSYNC
    
    ; fade handling
    lda tmpA
    ldx #$44
    cmp #$d0
    bcs _fadein
    cmp #$70
    bcs _nofade
    sec
    sbc #$40
    bcs _fadeout
    ldx #0
    beq _nofade
_fadein
    eor #$ff
_fadeout
    sta tmpX
    lsr
    lsr
    lsr
    lsr
    tay
    bcc +
    lsr tmpX
    bcc +
    iny
+   ldx fade_cols,y
_nofade
    sta WSYNC
    stx COLUP0
    stx COLUP1
    
    lda #3
    sta NUSIZ0
    sta NUSIZ1
    sta VDELP0
    sta VDELP1
    
    ; p0 @ 56. p1 @ 64.
    ldy #73
    jsr wait_lines  ; -38.
    lda #<icon_gfx0 ; -32.
    sta r0          ; -23.
    sta r5          ; -14.
    lda #<icon_gfx1 ; - 8.
    sta r1          ;   1.
    lda #<icon_gfx2 ;   7.
    sta r2          ;  16.
    lda #<icon_gfx3 ;  22.
    sta r3          ;  31.
    lda #<icon_gfx4 ;  37.
    sta r4          ;  46.
    sta RESP0       ;  55. -> 60.
    sta RESP1       ;  64. -> 69.
    #load_hrh icon_gfx
    lda #$40
    sta HMP0
    lda #$50
    sta HMP1
    lda #0
    sta WSYNC
    sta HMOVE
    sta VBLANK
    lda #size(icon_gfx0)-1
    jsr draw_hr
    
    ldy #6
    jsr wait_lines
    #load_hrl warn_gfx
    #load_hrh warn_gfx
    lda #size(warn_gfx0)-1
    sta WSYNC
    jsr draw_hr
    
    ldy #4
    jsr wait_lines
    #load_hrl flash_gfx
    lda #size(flash_gfx0)-1
    sta WSYNC
    jsr draw_hr
    
    ldy #36
    jsr wait_lines
    #load_hrl ayce_gfx
    lda #size(ayce_gfx0)-1
    sta WSYNC
    jsr draw_hr
    
    lda #2
    sta VBLANK
    ldy #43
    jsr wait_lines
    jmp startscreen_loop
    
wait_lines
-   sta WSYNC   ; -68.
    dey         ; -62.
    bne -       ; -56.
wait_12
    rts         ; -38.
    
draw_hr
    sta tmpY
-
    ldy tmpY
    lda (r3),y
    sta tmpX
    sta WSYNC   ; -68.
    lda (r4),y  ; -53.
    tax         ; -47.
    lda (r0),y  ; -32.
    sta GRP0    ; -23. (56)
    lda (r1),y  ; - 8. /
    sta GRP1    ;   1./(64)
    lda (r2),y  ;  16. /
    sta GRP0    ;  25./(72)
    lda (r5),y  ;  40.   /
    tay         ;  46.  /
    lda tmpX    ;  55. /
    sta GRP1    ;  64./(80)
    stx GRP0    ;  73./(88)
    sty GRP1    ;  82./(96)
    sta GRP0    ;  91./
    dec tmpY
    bpl -
    sta WSYNC
    lda #0
    sta GRP0
    sta GRP1
    sta GRP0
    rts
    
clear_tia
    lda #0
    ldx #$29
-   sta $00,x
    dex
    bpl -
    rts
    
    ;           o r  i .  p  e  t r i  f  o r m
text0   .byte [ 1,2, 3,4, 5, 6, 7,2,3, 8, 1,2,9][::-1] * 7 + (<font_gfx)
    ;           d r  v .  n  a  t t
text1   .byte [10,2,11,4,12,13, 7,7,0, 0, 0,0,0][::-1] * 7 + (<font_gfx)
    ;           a r  r .  a  b  s t r  a  c t
text2   .byte [13,2, 2,4,13,14,15,7,2,13,16,7,0][::-1] * 7 + (<font_gfx)

fade_cols
    .byte 0, $40, $42, $44
    
    .align $100
title_gfx0  .text x"80408000f05050504060d0" ; PF0
title_gfx1  .text x"03820300d0a884b4b4b4fc" ; PF1
title_gfx2  .text x"1f101d051d15b5b5054db7" ; PF2
title_gfxw  .text x"020c0204020208100a0202" ; wait

subt_gfx0   .text x"1e1e10184c4602121e0c"
subt_gfx1   .text x"193d2521212121253d19"
subt_gfx2   .text x"21232222e2e222222321"
subt_gfx3   .text x"8cde525212121252de8c"
subt_gfx4   .text x"47e7b494979794949797"
subt_gfx5   .text x"a4a4242439392424bcb8"

font_gfx
    .text x"00000000000000" ; ' '
    .text x"3c66666666663c" ; 'o'
    .text x"6666667c66667c" ; 'r'
    .text x"7e18181818187e" ; 'i'
    .text x"00000000181800" ; '.'
    .text x"6060607c66667c" ; 'p'
    .text x"7e60607e60607e" ; 'e'
    .text x"1818181818187e" ; 't'
    .text x"6060607c60607e" ; 'f'
    .text x"66667676767e66" ; 'm'
    .text x"7c66666666667c" ; 'd'
    .text x"183c3c66666666" ; 'v'
    .text x"66666e6e767666" ; 'n'
    .text x"66667e66663c18" ; 'a'
    .text x"7c66667c66667c" ; 'b'
    .text x"7c06063c60603e" ; 's'
    .text x"3c66606060663c" ; 'c'
    
    .align $100
icon_gfx0   .text x"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
icon_gfx1   .text x"3f7f405f5f2f2f2f171717170b0b0b050505050202020101010100000000000000000000000000000000000000000000000000"
icon_gfx2   .text x"ffff00fffffefcfcfcfcfefffffefefefcfcfcfcfcfc7c7c7c7cbcbcbc5c5c5c5c2c2e2f171717170b0b0b0505050402030100"
icon_gfx3   .text x"ffff00ffffff7f7f7f7fffffffffffff7f7f7f7e7e7e7c7c7c7c7878787171717262e2e2c4c4c4c8888888101010202020c0c0"
icon_gfx4   .text x"f8fc06f2f2e2e2e2c4c4c4c8888888101010202020204040408080808000000000000000000000000000000000000000000000"

    .align $100
warn_gfx0   .text x"6666ffffffffdbdbdbdbdbdbdbc3c3c3"
warn_gfx1   .text x"66666666667e7e66666666663c3c1818"
warn_gfx2   .text x"cdcdcdcdddd9d9f9f9cdcdcdcdcdf9f9"
warn_gfx3   .text x"9b9b99b9b9b9b9f9f9d9d9d9d9999b9b"
warn_gfx4   .text x"d9d9999b9b9b9b9f9f9d9d9d9d99d9d9"
warn_gfx5   .text x"8e9f9bb3b3b3b3b7b7b0b0b0b19b9f8e"

flash_gfx0  .text x"8d8d8989c9c98989e8e8"
flash_gfx1  .text x"495d5545cdd951559d89"
flash_gfx2  .text x"55555555d5d555555756"
flash_gfx3  .text x"33735252524242527222"
flash_gfx4  .text x"55555555555555555d59"
flash_gfx5  .text x"c9dd14058d991115ddc9"

ayce_gfx0   .text x"00000000383800000000"
ayce_gfx1   .text x"fefe8282fefe0202fefe"
ayce_gfx2   .text x"fefe0202fefe82828282"
ayce_gfx3   .text x"fefe808080808080fefe"
ayce_gfx4   .text x"fefe8080fefe8282fefe"
ayce_gfx5   .text x"00000000383800000000"
    .endsection
