/*
 * Copyright (c) 2009-2012 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xintc.h"
#include "xparameters.h"
#include "xio.h"
#include "xil_exception.h"

#include "furelise.h"
#include "turkeymarch.h"
#include "minuet.h"
#include "auldlangsyne.h"
#include "sirene1.h"
#include "sirene2.h"
#include "whistle.h"
#include "invent8.h"
#include "fugue1.h"
#include "zutakuca.h"
#include "sound.h"

#include "dds.h"

#define ONE 1000000
#define SAMPLING_RATE 48000

#define WHICHSONG 1



XIntc Intc;

static int Volume = 80;
static int Duration = 0;
static int Tone = 0;
static int Tempo;
static int Freq;

const int *Songs[] = { FurElise, Mozart, Minuet, AuldLangSyne, Sirene1, Sirene2, Whistle, Invent8, Fugue1, 0};

int *pSong;

void send_to_dac(int x){

	if(x > 127){
		x = 127;
	}

	if(x<-128){
		x = -128;
	}

	x += 128;
	XIo_Out32(XPAR_BUZZER_PER_0_BASEADDR + 4*4, x);

}




void buzz_interrupt_handler_1(void * baseaddr_p) {

#if 0
	// 500Hz square
	static int cnt_1ms = 0;
	cnt_1ms++;
	static int sample = 100;
	if(cnt_1ms == 48){
		cnt_1ms = 0;

		if(sample == 100){
			sample = -100;
		}else{
			sample = 100;
		}

		send_to_dac(sample);
	}
#elif 0
	// Sine wave
	u16 tunning_word = dds_freq_to_tunning_word(1000, 48000);
	s8 sine = dds_next_sample(tunning_word);
	send_to_dac(sine);
#else
	// MIDI
	static int current_note = 1;
	static int cnt = SAMPLING_RATE;
	static u16 tunning_word = 0;
	static u8 flag = 1;

	++cnt;

	if ( flag == 1){
		tunning_word = dds_freq_to_tunning_word(zutakuca[current_note+1], SAMPLING_RATE);
		flag = 0;
	}

	if (cnt >= SAMPLING_RATE/zutakuca[current_note]){
		cnt = 0;

		current_note += 2;
		if(zutakuca[current_note] == 0){
			current_note = 1;
			flag = 1;
		}

		tunning_word = dds_freq_to_tunning_word(zutakuca[current_note+1], SAMPLING_RATE);
	}

	u8 sample = dds_next_sample(tunning_word);
	send_to_dac(sample);

#endif
}


void buzz_interrupt_handler_0(void * baseaddr_p) {


	 //clean reg2(0) to disable timers and set reg2(1) to go into processing state
	 XIo_Out32(XPAR_BUZZER_PER_0_BASEADDR + 4*2, 0x02);
	 //set note values

	 //xil_printf("Tone = %d\n", Tone);
	 //if not end of song
	 if(pSong[Tone]){
		 Duration = ( ONE / pSong[Tone] );
		 Tone++;
		 XIo_Out32(XPAR_BUZZER_PER_0_BASEADDR + 4*3, Duration);
		 //xil_printf("Duration = %d\n", Duration);

		 Freq = pSong[Tone];
		 Tone++;
		 XIo_Out32(XPAR_BUZZER_PER_0_BASEADDR + 4*0, Freq);
		 //xil_printf("Freq = %d\n", Freq);
	 }
	 else{
		 Tone = 1;
	 }
	 XIo_Out32(XPAR_BUZZER_PER_0_BASEADDR + 4*2, 0x01);
	  //clean reg2(1) to get out of processing state and set reg2(0) to enable timers


}


void print(char *str);

int main()
{
	 init_platform();

	 XStatus Status;
	 Xuint32 value1, value2, value3;

	 //set volume
	 XIo_Out32(XPAR_BUZZER_PER_0_BASEADDR + 4*1, Volume);

	 //set song to play
	 pSong= Songs[WHICHSONG];

	 Duration=0;
	 Tone=1;
	 Tempo = *(pSong + 0);


	 // Test.
	 send_to_dac(0);


	 //set regs for tc for interrupt(note duration)
	 XIo_Out32(XPAR_BUZZER_PER_0_BASEADDR + 4*3, ONE);

	 //set note freq falue
	 XIo_Out32(XPAR_BUZZER_PER_0_BASEADDR + 4*0, 5000);

	 //start buzzer timer 2
	 XIo_Out32(XPAR_BUZZER_PER_0_BASEADDR + 4*2, 0x01);


	 //initialize interrupt controller
	  Status = XIntc_Initialize (&Intc, XPAR_INTC_0_DEVICE_ID);
	  if (Status != XST_SUCCESS)
		  xil_printf ("\r\nInterrupt controller initialization failure");
	  else
		  xil_printf("\r\nInterrupt controller initialized");

	  // Connect buzz_interrupt_handler_0
	Status = XIntc_Connect(&Intc, XPAR_AXI_INTC_0_BUZZER_PER_0_MY_TIMER_IRQ_INTR,
			(XInterruptHandler) buzz_interrupt_handler_0, (void *) 0);
	  if (Status != XST_SUCCESS)
		  xil_printf ("\r\nRegistering MY_TIMER Interrupt Failed");
	  else
		  xil_printf("\r\nMY_TIMER Interrupt registered");
		Status = XIntc_Connect(&Intc, XPAR_AXI_INTC_0_BUZZER_PER_0_O_INTERRUPT48KHZ_INTR,
				(XInterruptHandler) buzz_interrupt_handler_1, (void *) 0);
		  if (Status != XST_SUCCESS)
			  xil_printf ("\r\nRegistering MY_TIMER Interrupt Failed");
		  else
			  xil_printf("\r\nMY_TIMER Interrupt registered");


	  //start the interrupt controller in real mode
	   Status = XIntc_Start(&Intc, XIN_REAL_MODE);
		  if (Status != XST_SUCCESS)
			  xil_printf ("\r\nXIntc_Start Failed");
		  else
			  xil_printf("\r\XIntc_Start success");

	   //enable interrupt controller
	   XIntc_Enable (&Intc, XPAR_AXI_INTC_0_BUZZER_PER_0_MY_TIMER_IRQ_INTR);
	   XIntc_Enable (&Intc, XPAR_AXI_INTC_0_BUZZER_PER_0_O_INTERRUPT48KHZ_INTR);

	   microblaze_enable_interrupts();

	   while (1){
		   /*
		   value3 = XIo_In32(XPAR_BUZZER_PER_0_BASEADDR + 4*0);
		   value1 = XIo_In32(XPAR_BUZZER_PER_0_BASEADDR + 4*3);
		   value2 = XIo_In32(XPAR_BUZZER_PER_0_BASEADDR + 4*2);
		   xil_printf("\n\rvalue1 = %x, value2 = %x, value3 = %x.", value1, value2, value3);
		   */
	   }

	   cleanup_platform();
	   return 0;
}
