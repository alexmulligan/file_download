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
table:
            dc.b $3F, $06, $5B, $4F, $66, $6D, $7D, $07

buffer:
            ds.b 4

inputs:
            ds.b 1


; code section
            ORG   ROMStart

Entry:
_Startup:
                                                                                                  
                                                                                                   
; ************* Enter your code here:            

start:
            BSET DDRP, $0F          ; configure pins P0-3 as input
            BSET PTP, $0F           ; disable all 7seg displays
            MOVB #$FF, DDRB         ; configure port B as output
            MOVB #0, PORTB          ; turn all segments off 
            MOVB #0, DDRH           ; configure port H (dip switches) as inputs
            MOVB #$1, PEIH          ; enable only PB0 (PH0) to interrupt
            BCLR PPSH, 1            ; set PH0 to be sensitive to falling edges of signal
            CLI                     ; globally enable all interrupts

mainloop:
            LDY #buffer             ; initialize buffer pointer
            LDAB #%11101110         ; initialize cathode enable byte
            SEC                     ; set carry flag to make sure next digit is displayed

nextDigit:
            BSET PTP, $0F           ; disable all 7seg displays
            MOVB Y, PORTB           ; load contents at buffer pointer into display output
            INY                     ; move buffer pointer to next location
            STAB PTP                ; turn on next display
            
            LDX #8000               ; set delay counter to 8000
delay1ms:                           
            DBNE X, delay1ms        ; delay for 8000 * 125ns = 1ms

            ROLB                    ; rotate cathode enable byte to get ready for next digit
            BCS nextDigit           ; if more digits need to be displayed, branch to nextDigit, else continue
            BRA mainloop


update_ISR:
            ANDCC #$F0              ; reset flag register
            LDX #table
            LDY #buffer             ; initialize buffer pointer
            LDAA #4                 ; initialize buffer counter
bufferClear:
            BCLR 1, Y+, $FF         ; clear contents of buffer
            DBNE A, bufferClear     ; loop through entire buffer

            LDY #buffer             ; reset buffer pointer
            LDAA #4                 ; reset buffer counter
            LDAB #7                 ; initialize client counter
            MOVB PTH, inputs        ; load DIP switches state into memory

clientLoop:
            LSL inputs              ; shift dip switch input data left to move next switch bit into carry
            BCC lowInput            ; if switch input is high, continue; else, skip code section
            
            PSHB                    ; temporarily store client counter on stack
            LDAB B, X               ; convert client counter-1 to 7seg through the lookup table
            STAB 1, Y+              ; write 7seg value in buffer and move pointer to next buffer location
            PULB                    ; restore client counter from stack
            DBEQ A, allScanned      ; update buffer counter, and if buffer if full, skip to allScanned

lowInput:
            DBNE B, clientLoop      ; update client counter, and if all scanned, continue

allScanned:
            RTI


; ************* interrupt vector section
            ORG $FFCC               ; initialize vector address
            dc.w update_ISR         ; $FFCC is address of address of ISR
            END 
