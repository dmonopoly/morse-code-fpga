`timescale 1ns / 1ps

module letter_select(clk, reset, btn, start, ack, c[4:0], done);

  /*  INPUTS */
  input clk, btn, reset, start, ack;

  /*  OUTPUTS */
  output reg [4:0] c; // the character to output
  output wire done;
  wire cf; // count finished

  // store current state
  reg [2:0] state;
  reg [5:0] count; // some count that, when maxed out, means DAH

  assign DONE = state == DEF_C;
  assign cf = count == 6'b111111;

  localparam
  INI             = 3'b000;
  GOT_C           = 3'b001;
  WAITING_IN_C    = 3'b010;
  STILL_FORM_C    = 3'b011;
  DEF_C           = 3'b100;
  UNKNOWN         = 3'b111;

  // NSL AND SM
  always @ (posedge clk, posedge reset)
  begin : letter_select_nsl_sm
    if (reset)
      begin
        state <= INI;
        count <= 5'bXXXXX;
      end
    else
      case(state)
        INI:
          begin
            if (btn)
              begin
                state <= STILL_FORM_C;
                count <= 0;
              end


          end
        GOT_C:
          begin
            if (!btn)
              state <= WAITING_IN_C;

          end
        WAITING_IN_C:
          begin
            if (btn)
              state <= STILL_FORM_C;
            else if (!btn && cf)
              state <= DEF_C;


          end
        STILL_FORM_C:
          begin
            if (!btn || cf)
              state <= GOT_C;


          end
        DEF_C:
          begin
            if (ack)
              state <= INI;

          end
        default:
          state <= UNKNOWN;
      endcase
  end



  // OFL
  // no combinational output signals

endmodule
