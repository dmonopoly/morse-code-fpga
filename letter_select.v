`timescale 1ns / 1ps

module letter_select(clk, reset, btn, ack, c[4:0], done);

  /*  INPUTS */
  input clk, btn, reset, ack;

  /*  OUTPUTS */
  output reg [4:0] c; // the character to output
  output wire done;
  wire cf; // count finished

  // store current state
  reg [2:0] state;
  reg [5:0] count; // some count that, when maxed out, means DAH

  assign dote = (state == DEF_C);
  assign cf = (count == 6'b111111);

  localparam
  INI             = 3'b000;
  GOT_C           = 3'b001;
  WAITING_IN_C    = 3'b010;
  STILL_FORM_C    = 3'b011;
  DEF_C           = 3'b100;
  UNKNOWN         = 3'b111;

  char_start      = 5'b00000;
  char_a          = 5'b00001;
  char_b          = 5'b00010;
  char_c          = 5'b00011;
  char_d          = 5'b00100;
  char_e          = 5'b00101;
  char_f          = 5'b00110;
  char_g          = 5'b00111;
  char_h          = 5'b01000;
  char_i          = 5'b01001;
  char_j          = 5'b01010;
  char_k          = 5'b01011;
  char_l          = 5'b01100;
  char_m          = 5'b01101;
  char_n          = 5'b01110;
  char_o          = 5'b01111;
  char_p          = 5'b10000;
  char_q          = 5'b10001;
  char_r          = 5'b10010;
  char_s          = 5'b10011;
  char_t          = 5'b10100;
  char_u          = 5'b10101;
  char_v          = 5'b10110;
  char_w          = 5'b10111;
  char_x          = 5'b11000;
  char_y          = 5'b11001;
  char_z          = 5'b11010;
  char_unknown    = 5'b11111;

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
                c <= char_start;
              end
          end

        GOT_C:
          begin
            if (!btn)
              state <= WAITING_IN_C;

          end

        WAITING_IN_C:
          begin
            count <= count + 1;
            if (btn)
              begin
                count <= 6'b000000;
                state <= STILL_FORM_C;
              end
            else if (!btn && cf)
              begin
                count <= 6'b000000;
                state <= DEF_C;
              end
          end

        STILL_FORM_C:
          begin
            count <= count + 1;
            if (!btn || cf)
              begin
                count <= 6'b000000;
                state <= GOT_C;
                SwitchLetter();
              end
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

task SwitchLetter;
  begin
    case (c)
      char_start:
        begin
          if (btn)
            c <= char_t;
          else c<= char_e;
        end

      char_a:
        begin
          if (btn)
            c <= char_w;
          else c<= char_r;
        end

      char_d:
        begin
          if (btn)
            c <= char_x;
          else c<= char_b;
        end

      char_e:
        begin
          if (btn)
            c <= char_a;
          else c<= char_i;
        end

      char_g:
        begin
          if (btn)
            c <= char_q;
          else c<= char_z;
        end

      char_i:
        begin
          if (btn)
            c <= char_u;
          else c<= char_s;
        end

      char_k:
        begin
          if (btn)
            c <= char_y;
          else c<= char_c;
        end

      char_m:
        begin
          if (btn)
            c <= char_o;
          else c<= char_g;
        end

      char_n:
        begin
          if (btn)
            c <= char_k;
          else c<= char_d;
        end

      char_r:
        begin
          if (!btn)
            c<= char_l;
        end

      char_s:
        begin
          if (btn)
            c <= char_v;
          else c<= char_h;
        end

      char_t:
        begin
          if (btn)
            c <= char_m;
          else c<= char_n;
        end

      char_u:
        begin
          if (!btn)
            c<= char_f;
        end

      char_w:
        begin
          if (btn)
            c <= char_j;
          else c<= char_p;
        end

      default:
        c <= char_unknown;

    endcase
  end
endtask

  // OFL
  // no combinational output signals

endmodule
