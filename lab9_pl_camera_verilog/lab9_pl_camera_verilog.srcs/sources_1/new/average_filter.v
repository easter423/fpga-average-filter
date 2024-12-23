`timescale 1ns / 1ps
module average_filter(
    input             clk_i,
    input             rst_ni,
    input      [15:0] pixel_in_i,
    input      [15:0] h_count_i,
    input      [15:0] v_count_i,
    input             hsync_i,
    input             vsync_i,
    output reg [15:0] pixel_out_o
    );

    localparam WIDTH = 480;
    localparam HEIGHT = 272;
    localparam FILTER_SIZE = 3;
    localparam HALF = (FILTER_SIZE-1)/2; 
    localparam TOTAL_PIX = FILTER_SIZE*FILTER_SIZE;

    reg [15:0] line_shift[0:FILTER_SIZE-1][0:FILTER_SIZE-1];
    integer r,c;
    integer sum_r, sum_g, sum_b;

    always @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            pixel_out_o <= 16'd0;
            for(r=0; r<FILTER_SIZE; r=r+1) begin
                for(c=0; c<FILTER_SIZE; c=c+1) begin
                    line_shift[r][c] <= 16'd0;
                end
            end
        end else begin
            if(vsync_i == 0) begin
                for(r=0; r<FILTER_SIZE; r=r+1) begin
                    for(c=0; c<FILTER_SIZE; c=c+1) begin
                        line_shift[r][c] <= pixel_in_i;
                    end
                end
                pixel_out_o <= {pixel_in_i[15:11], pixel_in_i[10:5], pixel_in_i[4:0]};
            end else if(hsync_i) begin
                for(r=0; r<FILTER_SIZE; r=r+1) begin
                    for(c=0; c<FILTER_SIZE-1; c=c+1) begin
                        line_shift[r][c] <= line_shift[r][c+1];
                    end
                end
                for (r = 0; r < FILTER_SIZE; r = r + 1) begin
                    line_shift[r][FILTER_SIZE-1] <= pixel_in_i;
                end
                sum_r = 0; sum_g = 0; sum_b = 0;
                for(r=0; r<FILTER_SIZE; r=r+1) begin
                    for(c=0; c<FILTER_SIZE; c=c+1) begin
                        sum_r = sum_r + line_shift[r][c][4:0];
                        sum_g = sum_g + line_shift[r][c][10:5];
                        sum_b = sum_b + line_shift[r][c][15:11];
                    end
                end

                sum_r = sum_r / TOTAL_PIX;
                sum_g = sum_g / TOTAL_PIX;
                sum_b = sum_b / TOTAL_PIX;

                pixel_out_o <= {sum_b[4:0], sum_g[5:0], sum_r[4:0]};
            end else begin
                pixel_out_o <= pixel_out_o;
            end
        end
    end

endmodule
