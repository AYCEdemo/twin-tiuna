    .include "hw.asm"
    .include "screens.asm"
    .include "song.asm"
    
ch_s .struct
ptr     .word ?
bank    .byte ?
vol     .byte ?
cnt     .byte ?
wait    .byte ?
retptr  .word ?
retbank .byte ?
retcnt  .byte ?
grp     .byte ?
    .endstruct
    
    .section player_vars
end_line_0  .fill end_line_1_-end_line_0_
end_line_1  .fill end_line_end-end_line_1_
clear_start
ch0         .dstruct ch_s
ch1         .dstruct ch_s
syncval     .byte ?
synccnt     .byte ?
dispmask    .byte ?
clear_end
    .endsection
    
* = $80
tmpA        .byte ?
tmpX        .byte ?
tmpY        .byte ?
    .union
    .struct
    .dsection player_vars
    .endstruct
    .struct
    .dsection screens_vars
    .endstruct
    .endunion
    
* = $0000
    .logical $1000
    
music_start
    sta WSYNC
    lda #20
    sta T1024T
    lda #2
    sta VSYNC
    sta WSYNC
    sta WSYNC
    lda #0
    sta VSYNC
    jsr clear_tia
    ldx #clear_end-clear_start-1
-   sta clear_start,x
    dex
    bpl -
    ldx #0
-   lda end_line_0_,x
    sta end_line_0,x
    inx
    cpx #end_line_end-end_line_0_
    bne -
    lda #<twin_ch0
    sta ch0.ptr
    lda #>twin_ch0
    sta ch0.ptr+1
    lda #twin_ch0>>13
    sta ch0.bank
    lda #<twin_ch1
    sta ch1.ptr
    lda #>twin_ch1
    sta ch1.ptr+1
    lda #twin_ch1>>13
    sta ch1.bank
    lda #1
    sta ch0.cnt
    sta ch0.wait
    sta ch1.cnt
    sta ch1.wait
-   lda INTIM
    bne -
    ldy #5
    jsr wait_lines

frame_loop
    lda SWCHB
    and #1 ; reset?
    bne +
    jmp music_start
+   jsr end_line_0
    lda #2
    sta VBLANK
    sta VSYNC
    jsr end_line_1
    jsr end_line_0
    lda #0
    sta VSYNC
    jsr end_line_1
    jsr end_line_0
    lda #20         ; 2
    sta T1024T      ; 6
    
process_syncval
    ldx synccnt     ; 9
    beq _skipsync   ; 11
    ldy syncval     ; 14
    cpy #$ff        ; 16
    bne +           ; 18 | 20
    jmp endscreen_entry ; 21
+   jsr end_line_1
    cpy #$10        ; 2
    bcc +           ; 4 | 6
    lda synccnt     ; 7
    lsr             ; 9
    ora #$40        ; 11
    sta COLUBK      ; 14
+   tya             ; 16
    and #$f         ; 18
    cmp #$8         ; 20
    bcc +           ; 22 | 24
    jsr end_line_0
    lda #0          ; 2
    jmp ++          ; 5
+   jsr end_line_0
    tya             ; 2
    and #7          ; 4
    sta NUSIZ0      ; 7
    sta NUSIZ1      ; 10
    lda #$f         ; 12
+   sta dispmask    ; 15
    dec synccnt     ; 20
    jmp _donesync   ; 23
_skipsync           ; 13
    lda #0          ; 15
    sta COLUBK      ; 18
_donesync
    jsr end_line_1
    lda ch0.grp
    and dispmask
    sta GRP0
    jsr end_line_0
    lda ch1.grp
    and dispmask
    sta GRP1
    
; command format
; 00xxxxxx x      call
; 00111110 x      sync
; 00111111 w      set wait
; 010xxxxx        set freq hi
; 011xxxxx x      set freq
; 1vcwxxxx .      dt vol/set ctrl/set wait/wait
; 11000000        bank end
; 11100000 x x x  loop/end
    
update_ch .macro
    jsr end_line_1
    dec ch\1.cnt    ; 5
    beq +           ; 9
    jsr end_line_0
    jmp _done
+   
_startcmd
    ldy #0          ; 11
_cmdloop
    jsr g.bank.get_ptr\1 ; 16
    sta tmpA        ; 19
    bmi _finalcmd   ; 21|23
    iny             ; 23
    jsr end_line_1
    lda tmpA        ; 3
    asl             ; 5
    bmi +           ; 9 |7
    jmp _notfreq    ; 10
    
+   asl             ; 11
    bpl _dtfreq     ; 13|15
    jsr g.bank.get_ptr\1 ; 18
    iny             ; 20
    sta frac\1      ; 23
    jsr end_line_1
    lda tmpA        ; 3
    and #$1f        ; 5
    sta freq\1      ; 8
    jmp _cmdloop    ; 11
    
_dtfreq
    asl             ; 17
    asl             ; 19
    php             ; 22
    jsr end_line_0
    lda tmpA
    and #$f
    tax
    inx
    stx tmpA
    jsr end_line_1
    plp             ; 4
    bcc +           ; 6|8
    lda frac\1      ; 9
    sbc tmpA        ; 12
    sta frac\1      ; 15
    bcs ++          ; 17|19
    dec freq\1      ; 22
    jmp ++          ; 25

+   lda tmpA        ; 11
    adc frac\1      ; 14
    sta frac\1      ; 17
    bcc +           ; 19
    inc freq\1      ; 24
+   jsr end_line_0
    jsr end_line_1
    jmp _cmdloop
    
_finalcmd
    sta tmpX        ; 26
    jsr end_line_1
    
    iny             ; 2
    lda #0          ; 4
    sta tmpY        ; 7
    asl tmpA        ; 12
    bpl _voldone    ; 14|16
    
    lda tmpX        ; 17
    and #$f         ; 19
    bne _volcmd     ; 23|21
    jsr end_line_0
    asl tmpA        ;   |5
    bpl +           ;   |9 |7
    ; TODO looping
    jmp _done       ;      |10
+   ; bank end
    ; assuming they all start at $x000 for now
    lda #0          ;   |11
    sta ch\1.ptr    ;   |14
    lda #$30        ;   |16
    sta ch\1.ptr+1  ;   |19
    inc ch\1.bank   ;   |24
    jsr end_line_1
    jmp _startcmd

_volcmd
    pha             ; 26
    jsr end_line_0
    pla             ; 4
    clc             ; 6
    adc ch\1.vol    ; 9
    and #$f         ; 11
    sta ch\1.vol    ; 14
    sta AUDV\1      ; 17
    inc tmpY        ; 22
    jsr end_line_1
_voldone
    asl tmpA        ; 19
    bpl _ctrldone   ; 21|23
    
    jsr end_line_0
    ldx tmpY        ; 3
    beq +           ; 5
    jsr end_line_1
    jsr g.bank.get_ptr\1 ; 16
    iny             ; 18
    sta tmpX        ; 21
+   jsr end_line_1
    lda tmpX        ; 3
    and #$f         ; 5
    sta AUDC\1      ; 8
    sta ch\1.grp    ; 11
    inc tmpY        ; 16
_ctrldone
    jsr end_line_0
    asl tmpA        ; 5
    bpl _waitdone   ; 7|9
    ldx tmpY        ; 10
    beq ++          ; 12
    dex             ; 14
    bne +           ; 16|18
    jsr end_line_1
    jsr g.bank.get_ptr\1 ; 16
    iny             ; 18
    sta tmpX        ; 21
    jmp ++          ; 24
    
+   jsr end_line_1
    lsr tmpX
    lsr tmpX
    lsr tmpX
    lsr tmpX
    jsr end_line_0
+   jsr end_line_1
    lda tmpX        ; 3
    and #$f         ; 5
    tax             ; 7
    inx             ; 9
    stx ch\1.wait   ; 12
    jmp +           ; 16
_waitdone
    jsr end_line_1
+   lda ch\1.wait   ; 19
    sta ch\1.cnt    ; 22
    jsr end_line_0
    tya             ; 2
    clc             ; 4
    adc ch\1.ptr    ; 7
    sta ch\1.ptr    ; 10
    bcc +           ; 12
    inc ch\1.ptr+1  ; 17
+   jmp _done       ; 20

_notfreq
    jsr g.bank.get_ptr\1 ; 16
    iny
    sta tmpX
    jsr end_line_1
    lda tmpA        ; 3
    cmp #%00111111  ; 5
    beq _waitl      ; 7|9
    cmp #%00111110  ; 9
    beq _sync       ; 11|13
    
    ; call
    ; TODO support IDs > 255
    tya             ; 13
    clc             ; 15
    adc ch\1.ptr    ; 18
    sta ch\1.retptr ; 21
    php             ; 24
    jsr end_line_0
    plp             ; 4
    lda ch\1.ptr+1  ; 7
    adc #0          ; 9
    sta ch\1.retptr+1 ; 12
    lda ch\1.bank   ; 15
    sta ch\1.retbank ; 18
    ldy tmpX        ; 21
    jsr end_line_1
    lda twin_calltable,y ; 4
    sta ch\1.ptr    ; 7
    lda twin_calltable+$100,y ; 11
    sta ch\1.ptr+1  ; 14
    lda twin_calltable+$200,y ; 18
    sta ch\1.bank   ; 21
    jsr end_line_0
    lda twin_calltable+$300,y
    sta ch\1.retcnt
    jsr end_line_1
    jmp _startcmd
    
_sync
    jsr end_line_0
    lda tmpX
    sta syncval
    lda #$1f
    sta synccnt
    jsr end_line_1
    jmp _cmdloop
    
_waitl
    jsr end_line_0
    ldx tmpX
    inx
    stx ch\1.wait
    jsr end_line_1
    jmp _cmdloop

_done
    jsr end_line_1
    ldy ch\1.retptr+1
    beq +
    dec ch\1.retcnt
    bne +
    jsr end_line_0
    lda ch\1.retptr
    sta ch\1.ptr
    sty ch\1.ptr+1
    lda ch\1.retbank
    sta ch\1.bank
    jsr end_line_1
    lda #0
    sta ch\1.retptr+1
+   jsr end_line_0
    .endmacro
    
upd0    #update_ch 0
upd1    #update_ch 1
                    ; 3
    lda #0          ; 5
    sta VBLANK      ; 8
    lda ch0.vol     ; 11
    ora #$40        ; 13
    sta COLUP0      ; 16
    lda ch1.vol     ; 19
    ora #$40        ; 21
    sta COLUP1      ; 24
-   jsr end_line_1
    sta HMOVE       ; 3
    lda cmp0        ; 6
    asl             ; 8
    asl             ; 10
    asl             ; 12
    adc #$80        ; 15
    sta HMP0        ; 17
    jsr end_line_0
    sta HMOVE       ; 3
    lda cmp1        ; 6
    asl             ; 8
    asl             ; 10
    asl             ; 12
    adc #$80        ; 15
    sta HMP1        ; 17
    lda INTIM       ; 20
    bne -           ; 24
    jsr end_line_1
    sta HMOVE
    lda #0
    sta HMP0
    sta HMP1
    jmp frame_loop
    
    ; we need to keep track of the frequency counter to make sure that writes
    ; won't make the compare miss and cause noisy output, multiples of base
    ; divider rate (2x line rate) should be fine
                ; 35
end_line_0_     ; 41
    inc cnt0    ; 46
cmp0 = *+1-end_line_0_+end_line_0
    lda #0      ; 48
cnt0 = *+1-end_line_0_+end_line_0
    cmp #0      ; 50
    lda #0      ; 52
    bcs ++      ; 54
    sta cnt0    ; 57
freq0 = *+1-end_line_0_+end_line_0
    ldx #0      ; 59
acc0 = *+1-end_line_0_+end_line_0
    lda #0      ; 61
frac0 = *+1-end_line_0_+end_line_0
    adc #0      ; 63
    sta acc0    ; 66
    bcc +       ; 68
    inx         ; 70
+   stx cmp0    ; 73
    sta WSYNC   ; 76
    stx AUDF0   ; 3
    rts         ; 9
+               ; =35-9=26
-   sta WSYNC
    rts

end_line_1_
    inc cnt1
cmp1 = *+1-end_line_0_+end_line_0
    lda #0
cnt1 = *+1-end_line_0_+end_line_0
    cmp #0
    lda #0
    bcs -
    sta cnt1
freq1 = *+1-end_line_0_+end_line_0
    ldx #0
acc1 = *+1-end_line_0_+end_line_0
    lda #0
frac1 = *+1-end_line_0_+end_line_0
    adc #0
    sta acc1
    bcc +
    inx
+   stx cmp1
    sta WSYNC
    stx AUDF1
    rts
end_line_end

    .dsection screens
    .dsection twin_bank0
    
    .here
    
bank_common  .macro
org = (\1 + 1) * $1000 - size(bank)
    .cerror * > org, "bank ", \1, " too large! (", *, ")"
    
* = org
    .logical (\1 + 1) * $2000 - size(bank)
bank    .block
                    ; 13
get_ptr0            ; 19
    ldx ch0.bank    ; 22
    lda BANK0,x     ; 26
    jsr end_line_0
    lda (ch0.ptr),y ; 6
    sta BANK0       ; 10
    rts             ; 16
    
get_ptr1
    ldx ch1.bank
    lda BANK0,x
    jsr end_line_0
    lda (ch1.ptr),y
    sta BANK0
    rts
    
reset
    sta BANK0
    jmp start
    .fill 8, 0  ; BANK0 - BANK7
    .word reset ; reset vector
    .word reset ; break vector
    .bend
    .here
    .endm

g   #bank_common 0

* = $1000
    .logical $3000
    .dsection twin_bank1
    .here
    #bank_common 1
    
* = $2000
    .logical $5000
    .dsection twin_bank2
    .here
    #bank_common 2
    
* = $3000
    .logical $7000
    .dsection twin_bank3
    .here
    #bank_common 3
    
* = $4000
    .logical $9000
    .dsection twin_bank4
    .here
    #bank_common 4
    
* = $5000
    .logical $b000
    .dsection twin_bank5
    .here
    #bank_common 5
    
* = $6000
    .logical $d000
    .dsection twin_bank6
    .here
    #bank_common 6
    
* = $7000
    .logical $f000
    .dsection twin_bank7
    .here
    #bank_common 7
