  class counter_down_divide_by_4_test extends base_test;
  bit[7:0] data;
  bit[7:0] my_queue[$];
  int total_cycle = 0;
  int data_max, data_min;

  function new(); s
    super.new();
  endfunction
  
  virtual task run_scenario();
    packet pkt = new();
    wait(dut_vif.presetn == 1);
    
    // Assert overflow_en 
    write(8'h03, 8'h02);
    
    read (8'h03, 8'h02, pkt.data);
    
    // Write random init data to TDR 
    data = $urandom;
    write(8'h02, data);
    
    // Load data into counter 
    write(8'h00, 8'h04);
    
    // Set count down
    write(8'h00, 8'h12);
    write(8'h00, 8'h13);
    
    while(dut_vif.interrupt == 0) begin
      @(posedge dut_vif.ker_clk);
      total_cycle++;
    end
    
    $display("%0t: [counter_down_divide_by_4_test] Interrupt is asserted after 0d clock cyclces", $time, total_cycle);
    data min = (int' (data) - 20)*4;
    data_max = (int' (data) + 20)*4;
    
    if(total_cycle >= data_min && total_cycle <= data_max) begin
      $display("%0t: [counter_down_divide_by_4_test] PASS: %0d <= exp_cycle <= %0d, act_cycle = %0d", $time, data_min, data_max, total_cycle);
    end 
    else begin
      $display("%0t: [counter_down_divide_by_4_test] FAIL: %0 <= exp_cycle <= %0d, act_cycle = %0d", $time, data_min, data_max, total_cycle ); 
      err_cnt++;
    end
    
    total_cycle = 0;
    
    // Write 1 to clear TSR
    write(8'h01, 8'h02);
    
    // Read back
    read (8'h01, 8'h00, pkt.data);
    
    // Write random data to TDR
    data = $urandom;
    write(8'h02, data);
    
    // Stop counter and load data to TDR
    write(8'h00, 8'h00); 
    write(8'h00, 8'h04);
    
    // Set count down 
    write(8'h00, 8'h12);
    write(8'h00, 8'h13);
    
    if(dut_vif.interrupt == 0) begin
      while(dut_vif.interrupt == 0) begin
        @(posedge dut_vif.ker_clk);
        total_cycle++;
      end
    end
    else begin
      $display("%0t: [counter_down_divide_by_4_test] Interrup is not negated after write 1 to clear TSR", $time);
      $display("%0t: [counter_down_divide_by_4_test] Interrupt is asserted after %0d clock cyclces", $time, total_cycle);
    end
    
    data_min = (int' (data) - 20)*4; 
    data_max = (int' (data) + 20)*4;
      
    if(total_cycle >= data_min && total_cycle <= data_max) begin
      $display("%0t: [counter_down_divide_by_4_test] PASS: %0 <= exp_cycle <= %0d, act_cycle = %0d", $time, data_min, data_max, total_cycle); 
    end else begin
      $display("%0t: [counter_down_divide_by_4_test] FAIL: %0d <= exp_cycle <= %0d, act_cycle = %d", $time, data_min, data_max, total_cycle );
      err_cnt++
    end 
  endtask 
endclass
