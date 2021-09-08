;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup  ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point


; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

 
 ; ************* Enter your data here:

            ORG $3000		; starting at address $3000, insert data
counter:    dc.b 100
            
            ORG $FFF0
            dc.w rti_isr

; code section
            ORG   ROMStart

Entry:
_Startup:
                                                                                                  
                                                                                                   
; ************* Enter your code here:            
init:
            MOVB #$F, DDRP              ; configure port P3-0 as output                        
            MOVB #$F, PTP               ; disable 7seg displays
            BSET DDRJ, #2               ; configure PJ1 as output
            BCLR PTJ, #2                ; enable LEDs
            MOVB #1, DDRB               ; configure port B0 as output
            BCLR PORTB, 1               ; turn LED0 off
            MOVB #$68, RTICTL           ; configure RTI period
            BSET CRGINT, #$80           ; enable RTI
            CLI                         ; globally enable interrupts

mainloop:
            BRA mainloop                ; do nothing in mainloop, and loop forever


rti_isr:
            DEC counter                 ; decrement RTI counter
            BNE after                   ; If not reached, skip code section
            
            LDAA PORTB                  ; ..
            EORA #1                     ; .. Toggle LED0
            STAA PORTB                  ; ..
            
            LDAB #100                   ; .. 
            STAB counter                ; Reset RTI counter

after:
            BSET CRGFLG, $80            ; reset RT interrupt flag
            RTI
            
            END
