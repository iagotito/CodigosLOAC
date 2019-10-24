// DESCRIPTION: Verilator: Systemverilog example module
// with interface to switch buttons, LEDs, LCD and register display

parameter NINSTR_BITS = 32;
parameter NBITS_TOP = 8, NREGS_TOP = 32, NBITS_LCD = 64;
module top(input  logic clk_2,
           input  logic [NBITS_TOP-1:0] SWI,
           output logic [NBITS_TOP-1:0] LED,
           output logic [NBITS_TOP-1:0] SEG,
           output logic [NBITS_LCD-1:0] lcd_a, lcd_b,
           output logic [NINSTR_BITS-1:0] lcd_instruction,
           output logic [NBITS_TOP-1:0] lcd_registrador [0:NREGS_TOP-1],
           output logic [NBITS_TOP-1:0] lcd_pc, lcd_SrcA, lcd_SrcB,
             lcd_ALUResult, lcd_Result, lcd_WriteData, lcd_ReadData, 
           output logic lcd_MemWrite, lcd_Branch, lcd_MemtoReg, lcd_RegWrite);


  // parabrisa
  enum logic [1:0] {off, slow, fast} state;

  logic [6:0] drops;
  logic [2:0] num_drops;

  logic [1:0] count_more_3;
  logic [1:0] count_more_5;

  logic clk_1;
  logic reset;

  // Divisor de clock
  always_ff @(posedge clk_2) begin
    clk_1 <= !clk_1;
  end

  // Entradas
  always_comb begin
    reset <= SWI[7];

    drops <= SWI[6:0];
    num_drops <= 0;
    num_drops <= num_drops + drops[0] + drops[1] + drops[2]
                 + drops[3] + drops[4] + drops[5] + drops[6];
  end

  always_ff @(posedge clk_1, posedge reset) begin
    if (reset) begin
      state <= off;
      count_more_3 <= 0;
      count_more_5 <= 0;
    end
    else begin

      // blocos para mudar os contadores de gotas
      // com base nas gotas
      if (num_drops > 3 && count_more_3 < 3)
        count_more_3 <= count_more_3 + 1;
      else begin
        if (num_drops < 4) begin 
          count_more_3 <= 0;
          count_more_5 <= 0;
        end
        else begin
          count_more_3 <= count_more_3;
          count_more_5 <= count_more_5;
        end
      end
      if (num_drops > 5 && count_more_5 < 2)
        count_more_5 <= count_more_5 + 1;
      else begin
        if (num_drops < 6)
          count_more_5 <= 0;
        else
          count_more_5 <= count_more_5;
      end

      // blocos pra mudar o estado 
      // com base nos contadores de gotas
      if (count_more_5 > 1)
        state <= fast;
      else begin
        if (count_more_3 > 2)
          state <= slow;
        else
          state <= off;
      end
    end
  end
  

  always_comb begin
    // pra debugar
    lcd_b <= count_more_3;
    lcd_a <= count_more_5;
    LED[6] <= num_drops > 5;
    LED[5] <= num_drops > 3;

    // saidas
    LED[7] <= clk_1;
    LED[1] <= (state == fast);
    LED[0] <= (state == slow);
  end
endmodule
