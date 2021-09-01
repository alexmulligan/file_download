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
            dc.b $00, $3F, $06, $5B, $4F, $66, $6D, $7D, $07

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
            LDX #table              ; initialize 7seg lookup table pointer
            BSET DDRP, $0F          ; configure pins P0-3 as input
            BSET PTP, $0F           ; disable all 7seg displays
            MOVB #$FF, DDRB         ; configure port B as output
            MOVB #0, PORTB          ; turn all segments off 
            MOVB #0, DDRH           ; configure port H (dip switches) as inputs
            
mainloop:
            LDAA #4                 ; initialize buffer counter
            LDAB #8                 ; initialize client counter
            LDY #buffer             ; initialize buffer pointer
            ; TODO: blank whole buffer
            MOVB PTH, inputs        ; load DIP switches state into memory

pollingLoop:
            LSL inputs              ; shift dip switch input data left to move next switch bit into carry
            BCC lowInput            ; if switch input is high, continue; else, skip code section

            PSHB                    ; temporarily store client counter on stack
            LDAB B, X               ; convert client counter-1 to 7seg through the lookup table
            STAB 1, Y+              ; write 7seg value in buffer and move pointer to next buffer location
            PULB                    ; restore client counter from stack
            DBEQ A, allScanned      ; update buffer counter, and if buffer if full, skip to allScanned

lowInput:
            DBNE B, pollingLoop     ; update client counter, and if all scanned, continue
            
allScanned:
            LDY #buffer             ; reset buffer pointer
            ;JSR display             ; call display subroutine to display buffer contents
            BRA mainloop

            END
    ; display - subroutine to display contents of buffer on 7seg displays
    ;
    ; Inputs:
    ;       Buffer -> pointer to memory containing data
    ;
display:
            ;
            JSR
        
