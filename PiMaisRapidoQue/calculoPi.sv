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

  always_comb begin
    LED <= SWI | clk_2;
    SEG <= SWI;
    lcd_WriteData <= SWI;
    lcd_pc <= 'h12;
    lcd_instruction <= 'h34567890;
    lcd_SrcA <= 'hab;
    lcd_SrcB <= 'hcd;
    lcd_ALUResult <= 'hef;
    lcd_Result <= 'h11;
    lcd_ReadData <= 'h33;
    lcd_MemWrite <= SWI[0];
    lcd_Branch <= SWI[1];
    lcd_MemtoReg <= SWI[2];
    lcd_RegWrite <= SWI[3];
    for(int i=0; i<NREGS_TOP; i++) lcd_registrador[i] <= i+i*16;
    lcd_a <= {56'h1234567890ABCD, SWI};
    lcd_b <= {SWI, 56'hFEDCBA09876543};
  end

    // Número de dígitos hexadecimais.
    // Pro 10 e acho que pro 9 têm que ser 15.
    parameter q = 12;
    parameter t = 64'd1<<(4*q);
    parameter m = 4*t;

    // Aqui tem que ter vários bits de tamanho para dar certo.
    // Pra 15 dígitos hexadecimais têm que ser 64 bits.
    logic [49:0] a;
    // Quanto mais d's, mais "paralelo" fica, ou seja, mais rápido.
    logic [49:0] d1, d2, d3;
    logic [49:0] pi;
    logic reset;

    always_comb begin
        reset <= SWI[7];

        d1 <= (m/a) - (m/(a+2));
        d2 <= (m/(a+4)) - (m/(a+6));
        d3 <= (m/(a+8)) - (m/(a+10));
    end

    always_ff@(posedge clk_2 or posedge reset) begin
        if (reset) begin
            a <= 1;
            pi <= 0;
        end
        else begin
            if (d1 > 0 && d2 > 0 && d3 > 0) begin
                pi <= pi + d1 + d2 + d3;
                a <= a + 12;
                // a recebe o ultimo incremendo de 'a' nos d's + 2;
            end
        end
    end

    always_comb begin
        lcd_b <= pi;
    end

endmodule
