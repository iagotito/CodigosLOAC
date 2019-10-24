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


  enum logic [1:0] {increase_state, decrease_state, usual_state} state;
  logic [2:0] desired_temp;
  logic [2:0] real_temp;
  logic [3:0] dripping;
  logic [1:0] stop_dripping;
  logic increase;
  logic decrease;
  logic clk_3;
  logic clk_4;
  logic reset;

  always_comb begin
    increase <= SWI[0];
    decrease <= SWI[1];
    reset <= SWI[7];
  end

  always_ff @(posedge clk_2, posedge reset) begin
    if (reset) begin
      clk_3 <= 0;
    end
    else begin
      clk_3 <= !clk_3;
    end
  end

  always_ff @(posedge clk_3, posedge reset) begin
    if (reset) begin
      state <= usual_state;
    end
    else begin
      if ((increase && decrease) || (!increase && !decrease)) begin
        state <= usual_state;
      end
      else begin
        if (increase) begin
          state <= increase_state;
        end
         else begin
          state <= decrease_state;
        end
      end
    end
  end

  // always ff para alterar a temperatura desejada
  // com base nos estados
  always_ff @(posedge clk_3, posedge reset) begin
    if (reset) begin
      desired_temp <= 0;
    end
    else begin
      unique case (state)
        usual_state:
          desired_temp <= desired_temp;
        increase_state:
          if (desired_temp < 7) begin
            desired_temp <= desired_temp + 1;
          end
          else begin
            desired_temp <= desired_temp;
          end
        decrease_state:
          if (desired_temp > 0) begin
            desired_temp <= desired_temp - 1;
          end
          else begin 
            desired_temp <= desired_temp;
          end
      endcase
    end
  end

  // always ff para o gotejamento
  // com base nos estados
  always_ff @(posedge clk_3, posedge reset) begin
    if (reset) begin
      dripping <= 0;
      stop_dripping <= 0;
    end
    else begin
      if (real_temp != 7) begin
        stop_dripping <= 0;
        if (dripping < 10) begin
          dripping <= dripping + 1;
        end
        else begin
          dripping <= dripping;
        end
      end
      else begin
        if (stop_dripping < 3) begin
          stop_dripping <= stop_dripping + 1;
        end
        else begin
          stop_dripping <= stop_dripping;
        end

        if (dripping < 10 && stop_dripping != 3) begin
          dripping <= dripping + 1;
        end
        else begin
          if (stop_dripping != 3) begin
            dripping <= dripping;
          end
          else begin
            dripping <= 0;
          end
        end
      end
    end
  end

  // always ff para atrasar o clock
  always_ff @(posedge clk_3, posedge reset) begin
    if (reset) begin
      clk_4 <= 0;
    end
    else begin
      clk_4 <= !clk_4;
    end
  end

  // always ff para alterar a temperatura real
  // com base em se está diferente da desejada
  always_ff @(posedge clk_4, posedge reset) begin
    if (reset) begin
      real_temp <= 0;
    end
    else begin
      if (real_temp == desired_temp) begin
        real_temp <= real_temp;
      end
      else begin
        if (real_temp < desired_temp) begin
          real_temp <= real_temp + 1;
        end
        else begin
          real_temp <= real_temp - 1;
        end
      end
    end
  end

  // always comb para as saidas
  always_comb begin
    LED[7] <= clk_3;
    LED[6:4] <= real_temp;
    LED[2:0] <= desired_temp;
    LED[3] <= (dripping == 10);

    // Pra debugar:
    //lcd_a <= dripping;
    //lcd_b <= stop_dripping;
  end
endmodule

