start:
    BSET DDRP, $F       ; Config. lower PORT P as output
    BSET PTP, $F        ; turn off 7-segment displays
    BSET DDRJ, 2        ; configure PJ1 as output
    BCLR PTJ, 2         ; Enable LEDs
    BSET DDRB, 1        ; configure PB0 as output
    BSET PORTB, 1       ; trun LED0 ON
    BCLR DDRH, 1        ; configure PH0 as input
    BCLR PPSH, 1        ; interrupt on falling edge
    BSET PIEH, 1        ; enable interrupt on PH0
    CLI                 ; enable interrupts (in CCR)

forever:
    BRA forever

ledISR:                 ; ISR starts here
    LDX #9000           ; wait to debounce pushbutton

wait:
    DBNE X, wait        ; “wait” here (3 cycles)
    BRSET PTH, 1, done  ; “and see” here
    LDAB PORTB          ; read PORT B
    EORB #1             ; toggle bit 0
    STAB PORTB          ; toggle LED0

done:
    BSET PIFH, 1        ; reset PH0 interrupt flag
    RTI                 ; return from ISR


    org $FFCC           ; initialize vector address
    dc.w ledISR         ; $FFCC is address of address of ISR
    end
