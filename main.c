#include <hidef.h>
#include "derivative.h"

#define DELAY_CONSTANT 100

unsigned char buff[4] = {0x00, 0x00, 0x00, 0x00}; 

void fillBuffer() {
        unsigned char lookup[8] = {0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07};
        unsigned char bit;
        int i;
        int j;
        
        // clear buffer
        for (i=0; i<4; i++) {
                buff[i] = 0x00;
        }
        
        // check each switch
        j = 0;
        for (i=7; i>=0; i--) {
                bit = (1 << i) & PTH;
                if (bit) {
                        buff[j] = lookup[i];
                        j += 1;        
                }
                
                if (j == 4) {
                        break;        
                }
        }
}

void main(void) {
        // Control Signals Applied to 4 Common Cathodes
        unsigned char digit[4] = {0xFE, 0xFD, 0xFB, 0xF7}; 

        // Initialization
        DDRB  = 0xFF;       // configure Port B as output
        DDRP  = 0x0F;       // configure lower Port P as output
        DDRH  = 0;          // configure Port H as input
        PTP   = 0xFF;       // Turn 7-segment displays off
        DDRJ  |= 0x02;      // configure PJ1 pin as output
        PTJ   |= 2;         // disable LEDs

        // Infinite loop: it displays the buffer and then calls fillBuffer 
        while (1) {
                int i, j;
                for (i=0; i<4; i++) {
                        // display each buffer value and toggle corresponding 7seg display
                        PORTB = buff[i];
                        PTP = digit[i];
                        
                        // delay enough for multiplexing to work
                        for (j=0; j<DELAY_CONSTANT; j++) {;}
                }

                fillBuffer();      
        }
}

