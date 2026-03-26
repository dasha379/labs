module bubble #(
  parameter DWIDTH = 8,
  parameter WORDS = 5,
  parameter AWIDTH = 3
) (
  input  logic                  clk_i,
  input  logic                  srst_i,
  input  logic                  en,
  input  logic [AWIDTH - 1 : 0] data_size,

  input  logic [DWIDTH - 1 : 0] a_in,
  input  logic [DWIDTH - 1 : 0] b_in,

  output logic [AWIDTH - 1 : 0] a_addr,
  output logic                  a_valid,
  output logic [DWIDTH - 1 : 0] a_out,

  output logic [AWIDTH - 1 : 0] b_addr,
  output logic                  b_valid,
  output logic [DWIDTH - 1 : 0] b_out,
  output logic                  end_sort
);

  logic [AWIDTH - 1 : 0] i, j;
  logic enable, delayed_en;

  always_ff @ (posedge clk_i)
    if (srst_i)
      delayed_en <= 1'b1;
    else
      if (en)
        delayed_en <= en ^ delayed_en;
      else
        delayed_en <= '1;
  
  assign enable = en && !delayed_en;

  always_ff @ (posedge clk_i)
    if (srst_i)
      i <= '0;
    else
      if (!end_sort && enable)
        if (i < (data_size - 2'd2 - j))
          i <= i + AWIDTH'(1);
        else
          i <= '0;
  
  always_ff @ (posedge clk_i)
    if (srst_i)
      j <= '0;
    else
      if (!end_sort && enable)
        if (i == (data_size - 2'd2 - j))
          j <= j + AWIDTH'(1);
      else if (end_sort == '1)
        j <= '0;

  assign end_sort = (j >= (data_size - AWIDTH'(1)));

  assign a_addr = i;
  assign b_addr = i + AWIDTH'(1);

  assign a_out = a_valid ? b_in : a_in;
  assign b_out = b_valid ? a_in : b_in;

  assign a_valid = ( enable && ( !end_sort ) && ( a_in > b_in ) );
  assign b_valid = a_valid;

endmodule