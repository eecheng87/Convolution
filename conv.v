module conv(
    input rst,
    input clk, 
    output reg M0_R_req, 
    output reg [31:0]M0_addr, 
    input [31:0]M0_R_data, 
    output reg [3:0]M0_W_req, 
    output reg [31:0]M0_W_data,

    output reg M1_R_req, 
    output reg [31:0]M1_addr, 
    input [31:0]M1_R_data, 
    output reg [3:0]M1_W_req, 
    output reg [31:0]M1_W_data,
    
    input start,
    output reg finish
);

reg [9:0]i;
reg [9:0]j;
reg [9:0]k;
reg [9:0]m;
reg [9:0]n;

reg [31:0]in_data[800:0];
reg [575:0]product[726:0];
reg [31:0]out_data[675:0];
reg [31:0]sout_data[675:0];
reg convoFin1;
reg convoFin2;
reg convoFin3;
reg afterInit;
reg transFin;

initial begin
 i = 0;
 j = 0;
 k = 0;
 m = 0;
 n = 0;
 afterInit = 0;
 convoFin1 = 0;
 convoFin2 = 0;
 convoFin3 = 0;
 transFin = 0;
end

always@(posedge clk)begin
    if(start)begin
        afterInit <= 1;
        M0_addr <= i*4;
        M0_R_req <= 1;
        M0_W_req <= 0;
        in_data[i-2] <= M0_R_data;
        i <= i+1;
    end else if(afterInit&&i<800)begin
        M0_addr <= i*4;
        M0_R_req <= 1;
        M0_W_req <= 0;
        in_data[i-2] <= M0_R_data;
        i <= i+1;
    end
    
    if(i>=800&&!convoFin1)begin
        for(j=0;j<726;j=j+1)begin
            if(j%28<=25)begin
                //out_data[j-(j/28)*2] 
                product[j][575:512] <= in_data[j]*in_data[784];
                product[j][511:448] <= in_data[j+1]*in_data[785];
                product[j][447:384] <= in_data[j+2]*in_data[786];
                product[j][383:320] <= in_data[j+28]*in_data[787];
                product[j][319:256] <= in_data[j+29]*in_data[788];
                product[j][255:192] <= in_data[j+30]*in_data[789];
                product[j][191:128] <= in_data[j+56]*in_data[790];
                product[j][127:64] <= in_data[j+57]*in_data[791];
                product[j][63:0] <= in_data[j+58]*in_data[792];//in_data[793];
            end
            convoFin1 <= 1;
        end
    end

    if(convoFin1&&!convoFin2&&!convoFin3)begin
        for(m=0;m<726;m=m+1)begin
            //product[m][543:512] <= >4?
            product[m][543:512] <= (product[m][527:512]>16'b1000000000000000)?product[m][559:528]+1:product[m][559:528];
            product[m][479:448] <= (product[m][463:448]>16'b1000000000000000)?product[m][495:464]+1:product[m][495:464];
            product[m][415:384] <= (product[m][399:384]>16'b1000000000000000)?product[m][431:400]+1:product[m][431:400];
            product[m][351:320] <= (product[m][335:320]>16'b1000000000000000)?product[m][367:336]+1:product[m][367:336];
            product[m][287:256] <= (product[m][271:256]>16'b1000000000000000)?product[m][303:272]+1:product[m][303:272];
            product[m][223:192] <= (product[m][207:192]>16'b1000000000000000)?product[m][239:208]+1:product[m][239:208];
            product[m][159:128] <= (product[m][143:128]>16'b1000000000000000)?product[m][175:144]+1:product[m][175:144];
            product[m][95:64] <= (product[m][79:64]>16'b1000000000000000)?product[m][111:80]+1:product[m][111:80];
            product[m][31:0] <= (product[m][15:0]>16'b1000000000000000)?product[m][47:16]+1:product[m][47:16];
        end
        convoFin2 <= 1;
    end
    if(convoFin1&&convoFin2&&!convoFin3)begin
        for(k=0;k<676;k=k+1)begin
            if(k%28<=25)begin
            out_data[k-(k/28)*2] = product[k][543:512]+
                            product[k][479:448]+
                            product[k][415:384]+
                            product[k][351:320]+
                            product[k][287:256]+
                            product[k][223:192]+
                            product[k][159:128]+
                            product[k][95:64]+
                            product[k][31:0]+in_data[793];
            end
        end
        convoFin3 <= 1;
    end
    if(!transFin&&convoFin1&&convoFin2&&convoFin3)begin
        if(n<676)begin
            M1_W_data <= out_data[n];
            M1_addr <= n*4;
            M1_R_req <= 1;
            M1_W_req <= 4'b1111;
            n <= n+1;
        end else begin
            transFin <= 1;
        end
    end

end





endmodule
