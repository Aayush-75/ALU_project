module tb#(parameter REG_SIZE=8)();

    reg clk,rst;
    reg [1:0]inp_valid;
    reg mode;
    reg [3:0]cmd;
    reg ce;
    reg [REG_SIZE-1:0]opA,opB;
    reg cin;
    reg err;
    reg [(REG_SIZE*2)-1:0]res;
    reg oflow,cout,g,l,e;

    reg r_err;
    reg [(REG_SIZE*2)-1:0]r_res;
    reg r_oflow,r_cout,r_g,r_l,r_e;

    wire d_err;
    wire [(REG_SIZE*2)-1:0]d_res;
    wire d_oflow,d_cout,d_g,d_l,d_e;

    reg delay;

    integer test_case=0;
    integer pass_case=0;
    integer fail_case=0;

    wire [$clog2(REG_SIZE)-1:0] s_amt;
    assign s_amt= opB[$clog2(REG_SIZE)-1:0];

    alu a1(.clk(clk),.rst(rst),.inp_valid(inp_valid),.mode(mode),.cmd(cmd),.ce(ce),.opa(opA),.opb(opB),.cin(cin),
           //.err(d_err),.res(d_res),.oflow(d_oflow),.cout(d_cout),.g(d_g),.l(d_l),.e(d_e));
    
    //aluu a1(.clk(clk),.rst(rst),.inp_valid(inp_valid),.mode(mode),.cmd(cmd),.ce(ce),.opA(opA),.opB(opB),.cin(cin),
           .err(d_err),.res(d_res),.oflow(d_oflow),.cout(d_cout),.g(d_g),.l(d_l),.e(d_e));

    task apply;
        input rst;
        input ce;
        input mode;
        input [1:0]inp_valid;
        input [3:0]cmd;
        input [REG_SIZE-1:0]opA,opB;
        input cin;
        begin
            @(negedge clk);
            ref(rst,inp_valid,mode,cmd,ce,opA,opB,cin);
        end
    endtask

    task ref;
        input rst;
        input [1:0]inp_valid;
        input mode;
        input [3:0]cmd;
        input ce;
        input [REG_SIZE-1:0]opA,opB;
        input cin;
        begin
            if(ce)
            begin
                if(rst)
                    begin
                        r_err=0;r_res=0;r_oflow=0;r_cout=0;r_g=0;r_l=0;r_e=0;delay=0;
                    end
                else
                    begin
                        r_err=0;r_res=0;r_oflow=0;r_cout=0;r_g=0;r_l=0;r_e=0;
                        if(mode)
                            begin
                                case(cmd)
                                    4'd0: begin if(inp_valid==3) begin r_res=opA+opB; if(r_res>=2**REG_SIZE) r_cout=1; end else r_err=1; end
                                    4'd1: begin if(inp_valid==3) begin r_res=opA-opB; if(opB>opA) r_oflow=1; end else r_err=1;  end
                                    4'd2: begin if(inp_valid==3) begin r_res=opA+opB+cin; if(r_res>=2**REG_SIZE) r_cout=1; end else r_err=1; end
                                    4'd3: begin if(inp_valid==3) begin r_res=opA-opB-cin; if(opB+cin>opA) r_oflow=1; end else r_err=1; end
                                    4'd4: begin if(inp_valid==3 || inp_valid==1) r_res=(({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(opA+1)); else r_err=1; end
                                    4'd5: begin if(inp_valid==3 || inp_valid==2) r_res=(({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(opA-1)); else r_err=1; end
                                    4'd6: begin if(inp_valid==3 || inp_valid==1) r_res=(({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(1+opB)); else r_err=1; end
                                    4'd7: begin if(inp_valid==3 || inp_valid==2) r_res=(({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(opB-1)); else r_err=1; end
                                    4'd8: begin if(inp_valid==3) begin if(opA>opB) r_g=1; else if(opB>opA) r_l=1; else r_e=1; end else r_err=1; end
                                    4'd9: begin if(inp_valid==3) begin if(delay==0) begin delay=delay+1; r_res = {REG_SIZE{1'bx}}; end else begin delay=0; r_res=((({{(REG_SIZE){1'b0}},{(REG_SIZE){1'b1}}}) & (opB + 1)) * (({{(REG_SIZE){1'b0}},{(REG_SIZE){1'b1}}}) & (opA + 1))); end end else r_err=1; end
                                    4'd10: begin if(inp_valid==3) begin if(delay==0) begin delay=delay+1; r_res = {REG_SIZE{1'bx}}; end else begin delay=0; r_res=((opA<<1)*(opB)); end end else r_err=1; end
                                    4'd11: begin if(inp_valid == 3) begin r_res = $signed(opA) + $signed(opB); if($signed(opA)+$signed(opB) > (2**REG_SIZE)-1 || $signed(opA)+$signed(opB) < 0)
                                                    r_oflow <= 1; if($signed(opA)>$signed(opB)) r_g=1; else if($signed(opA)<$signed(opB)) r_l=1; else r_e=1; end else r_err=1; end
                                    4'd12: begin if(inp_valid == 3) begin r_res = $signed(opA) - $signed(opB); if($signed(opA)-$signed(opB) > (2**REG_SIZE)-1 || $signed(opA)-$signed(opB) < 0)
                                                    r_oflow <= 1; if($signed(opA)>$signed(opB)) r_g=1; else if($signed(opA)<$signed(opB)) r_l=1; else r_e=1; end else r_err=1; end
                                endcase
                            end
                        else
                            begin
                                case(cmd)
                                    4'd0:begin if(inp_valid==3) r_res=({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(opA&opB); else r_err=1; end
                                    4'd1:begin if(inp_valid==3) r_res=({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(~(opA&opB)); else r_err=1; end
                                    4'd2:begin if(inp_valid==3) r_res=({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(opA|opB); else r_err=1; end
                                    4'd3:begin if(inp_valid==3) r_res=({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(~(opA|opB)); else r_err=1; end
                                    4'd4:begin if(inp_valid==3) r_res=({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(opA^opB); else r_err=1; end
                                    4'd5:begin if(inp_valid==3) r_res=({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(~(opA^opB)); else r_err=1; end
                                    4'd6:begin if(inp_valid==3 || inp_valid==1) r_res=({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(~opA); else r_err=1; end
                                    4'd7:begin if(inp_valid==3 || inp_valid==2) r_res=({{REG_SIZE{1'b0}},{REG_SIZE{1'b1}}})&(~opB); else r_err=1; end
                                    4'd8:begin if(inp_valid==3 || inp_valid==1) r_res=(opA>>1)&(({{(REG_SIZE){1'b0}},{(REG_SIZE){1'b1}}})); else r_err=1; end
                                    4'd9:begin if(inp_valid==3 || inp_valid==1) r_res=(opA<<1)&(({{(REG_SIZE){1'b0}},{(REG_SIZE){1'b1}}})); else r_err=1; end
                                    4'd10:begin if(inp_valid==3 || inp_valid==2) r_res=(opB>>1)&(({{(REG_SIZE){1'b0}},{(REG_SIZE){1'b1}}})); else r_err=1; end
                                    4'd11:begin if(inp_valid==3 || inp_valid==2) r_res=(opB<<1)&(({{(REG_SIZE){1'b0}},{(REG_SIZE){1'b1}}})); else r_err=1; end
                                    4'd12:begin if(inp_valid==3) begin
                                                                    if(opB[REG_SIZE-1:$clog2(REG_SIZE)]==0 || opB[REG_SIZE-1:$clog2(REG_SIZE)]==1)
                                                                        r_res <= ( ({ {(REG_SIZE){1'b0}}, opA } << s_amt) | ({ {(REG_SIZE){1'b0}}, opA } >> (REG_SIZE - s_amt)) ) & { {(REG_SIZE){1'b0}}, {(REG_SIZE){1'b1}} };
                                                                    else begin
                                                                        r_res <= ( ({ {(REG_SIZE){1'b0}}, opA } << s_amt) | ({ {(REG_SIZE){1'b0}}, opA } >> (REG_SIZE - s_amt)) ) & { {(REG_SIZE){1'b0}}, {(REG_SIZE){1'b1}} }; r_err=1; end end else r_err=1; end
                                    4'd13:begin if(inp_valid==3) begin
                                                                    if(opB[REG_SIZE-1:$clog2(REG_SIZE)]==0 || opB[REG_SIZE-1:$clog2(REG_SIZE)]==1)
                                                                        r_res <= ( ({ {(REG_SIZE){1'b0}}, opA } >> s_amt) | ({ {(REG_SIZE){1'b0}}, opA } << (REG_SIZE - s_amt)) ) & { {(REG_SIZE){1'b0}}, {(REG_SIZE){1'b1}} };
                                                                    else begin
                                                                        r_res <= ( ({ {(REG_SIZE){1'b0}}, opA } >> s_amt) | ({ {(REG_SIZE){1'b0}}, opA } << (REG_SIZE - s_amt)) ) & { {(REG_SIZE){1'b0}}, {(REG_SIZE){1'b1}} }; r_err=1; end end else r_err=1; end
                                endcase
                            end
                    end
            end
            @(posedge clk);
            err=r_err;res=r_res;oflow=r_oflow;cout=r_cout;g=r_g;l=r_l;e=r_e;
        end
    endtask
    
    task check;
        begin
            test_case=test_case+1;
            if((d_err===err)&&(d_res===res)&&(d_oflow===oflow)&&(d_cout===cout)&&(d_g===g)&&(d_l===l)&&(d_e===e))
                begin
                    pass_case=pass_case+1;
                    $display("[%0d] PASS",test_case);
                end
            else 
                begin
                    fail_case=fail_case+1;
                    $display("[%0d] FAIL for CMD=[%0d] opA=[%0d] opB=[%0d] cin=[%0d]",test_case,cmd,opA,opB,cin);
                    $display("    err  res   oflow  cout  g l e");
                    $display("DUT:%h    %h  %h      %h     %h %h %h",d_err,d_res,d_oflow,d_cout,d_g,d_l,d_e);
                    $display("REF:%h    %h  %h      %h     %h %h %h",err,res,oflow,cout,g,l,e);
                    $display(""); 
                end
        end
    endtask

    initial 
    begin
        clk=0;
        #2;
        forever #2 clk = ~clk;
    end

    task short;
        begin  
            apply(rst,ce,mode,inp_valid,cmd,opA,opB,cin);
            @(posedge clk);
            @(posedge clk);
            check();
        end
    endtask  

    task inp_val;
        begin
            mode=1;
            cmd=0;
                opA=5;opB=10;cin=1;
                short();

                opA=255;opB=20;cin=0;
                short();

                opA=0;opB=255;cin=0;
                short();
            
            cmd=1;
                opA=5;opB=10;cin=1;
                short();

                opA=255;opB=20;cin=0;
                short();

                opA=0;opB=255;cin=0;
                short();

            cmd=2;
                opA=5;opB=10;cin=1;
                short();

                opA=255;opB=20;cin=0;
                short();

                opA=0;opB=255;cin=1;
                short();

                opA=5;opB=10;cin=0;
                short();

            cmd=3;
                opA=5;opB=10;cin=1;
                short();

                opA=255;opB=20;cin=0;
                short();

                opA=0;opB=255;cin=1;
                short();

                opA=5;opB=10;cin=0;
                short();
            
            cmd=4;
                opA=255;
                short();

                opA=25;
                short();
            
            cmd=5;
                opA=0;
                short();

                opA=13;
                short();

            cmd=6;
                opB=255;
                short();

                opB=25;
                short();
            
            cmd=7;
                opB=0;
                short();

                opB=13;
                short();
                
            cmd=8;
                opA=115;opB=29;
                short();

                opA=3;opB=199;
                short();

                opA=66;opB=66;
                short();

            cmd=9;
                opA=10;opB=60;
                short();
                apply(rst,ce,mode,inp_valid,cmd,opA,opB,cin);
                check();

                opA=255;opB=103;
                short();
                apply(rst,ce,mode,inp_valid,cmd,opA,opB,cin);
                check();
                
                opA=255;opB=90;
                short();
                apply(rst,ce,mode,inp_valid,cmd,opA,opB,cin);
                check();

                opA=0;opB=97;
                short();
                apply(rst,ce,mode,inp_valid,cmd,opA,opB,cin);
                check();
            
            cmd=10;
                opA=10;opB=60;
                short();
                apply(rst,ce,mode,inp_valid,cmd,opA,opB,cin);
                check();

                opA=255;opB=103;
                short();
                apply(rst,ce,mode,inp_valid,cmd,opA,opB,cin);
                check();

                opA=0;opB=90;
                short();
                apply(rst,ce,mode,inp_valid,cmd,opA,opB,cin);
                check();

                opA=0;opB=97;
                short();
                apply(rst,ce,mode,inp_valid,cmd,opA,opB,cin);
                check();

            cmd=11;
                opA=12;opB=17;
                short();

                opA=41;opB=19;
                short();

                opA=67;opB=67;
                short();

                opA=99;opB=255;
                short();

                opA=255;opB=30;
                short();

            cmd=12;
                opA=12;opB=17;
                short();

                opA=41;opB=19;
                short();

                opA=67;opB=67;
                short();

                opA=99;opB=255;
                short();

                opA=255;opB=30;
                short();
              
        mode=0;

            cmd=0;
                opA=255;opB=255;
                short();

                opA=19;opB=56;
                short();

                opA=0;opB=66;
                short();

            cmd=1;
                opA=255;opB=255;
                short();

                opA=19;opB=56;
                short();

                opA=0;opB=66;
                short();

            cmd=2;
                opA=255;opB=255;
                short();

                opA=19;opB=56;
                short();

                opA=0;opB=66;
                short();

            cmd=3;
                opA=255;opB=255;
                short();

                opA=19;opB=56;
                short();

                opA=0;opB=66;
                short();

            cmd=4;
                opA=255;opB=255;
                short();

                opA=19;opB=56;
                short();

                opA=0;opB=66;
                short();

            cmd=5;
                opA=255;opB=255;
                short();

                opA=19;opB=56;
                short();

                opA=0;opB=66;
                short();

            cmd=6;
                opA=255;opB=255;
                short();

                opA=19;opB=56;
                short();

                opA=0;opB=66;
                short();

            cmd=7;
                opA=255;opB=255;
                short();

                opA=19;opB=56;
                short();

                opA=0;opB=0;
                short();

            cmd=8;
                opA=255;opB=255;
                short();

                opA=45;opB=56;
                short();

                opA=0;opB=66;
                short();

            cmd=9;
                opA=255;opB=255;
                short();

                opA=56;opB=56;
                short();

                opA=0;opB=66;
                short();

            cmd=10;
                opA=255;opB=255;
                short();

                opA=19;opB=81;
                short();

                opA=0;opB=119;
                short();

            cmd=11;
                opA=255;opB=255;
                short();

                opA=19;opB=201;
                short();

                opA=0;opB=254;
                short();

            cmd=12;
                opA=49;opB=0;
                short();
                
                opA=250;opB=1;
                short();
                
                opA=231;opB=2;
                short();

                opA=123;opB=3;
                short();
                
                opA=127;opB=4;
                short();

                opA=144;opB=5;
                short();

                opA=198;opB=6;
                short();

                opA=201;opB=7;
                short();

                opA=11;opB=8;
                short();

                opA=77;opB=25;
                short();

                opA=59;opB=254;
                short();

            cmd=13;
                opA=49;opB=0;
                short();
                
                opA=250;opB=1;
                short();
                
                opA=231;opB=2;
                short();

                opA=123;opB=3;
                short();
                
                opA=127;opB=4;
                short();

                opA=144;opB=5;
                short();

                opA=198;opB=6;
                short();

                opA=201;opB=7;
                short();

                opA=11;opB=8;
                short();

                opA=77;opB=25;
                short();

                opA=59;opB=254;
                short();
        end
    endtask

    always@(posedge clk)
    begin
        rst=1;
        ce=0;
        inp_valid=0;
        @(posedge clk);
        //(rst,ce,mode,inp_valid,cmd,opA,opB,cin)
        apply(0,3,1,0,1,0,0,0);
        @(posedge clk);
        apply(1,3,1,0,1,0,0,0);
        rst=1;
        ce=1;
        inp_valid=1;
        apply(1,3,1,0,0,0,0,0);
        rst=0;
        ce=0;
        inp_valid=0;
        apply(1,3,1,0,1,0,0,0);
        rst=0;
        ce=1;
        inp_valid=3;
        @(posedge clk);
        inp_val();
        inp_valid=2;
        inp_val();
        inp_valid=1;
        inp_val();
        inp_valid=0;
        inp_val();


        repeat(20)
            @(posedge clk);
        $display("Total = [%0d]",test_case);
        $display("Pass  = [%0d]",pass_case);
        $display("Fail  = [%0d]",fail_case);
        $finish;
    end

endmodule

