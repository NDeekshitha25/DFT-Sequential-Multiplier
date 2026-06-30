//Self-Checking Testbench
/*
This testbench checks:
1. Functional multiplication
2. Clock gating operation
3. Scan shift operation
4. Shift-capture-shift operation
5. At-speed counter test
*/

module tb_seq_multiplier;

	reg clk = 0;
	reg rst = 1;
	reg start = 0;

	reg [7:0] a, b;

	// DFT signals
	reg test_mode = 0;
	reg scan_enable = 0;
	reg scan_in = 0;

	wire [15:0] product;
	wire done;
	wire scan_out;

	// DUT
	seq_multiplier dut (

		.clk(clk),
		.rst(rst),
		.start(start),

		.a(a),
		.b(b),

		.test_mode(test_mode),
		.scan_enable(scan_enable),
		.scan_in(scan_in),

		.scan_out(scan_out),

		.product(product),
		.done(done)
	);

	// waveform dump
	initial begin
		$dumpfile("seq_mult_dft.vcd");
		$dumpvars(0, tb_seq_multiplier);
	end

	// clock generation
	always #5 clk = ~clk;

	// Functional multiplication test


	task run(input [7:0] x, input [7:0] y);

		begin

			@(negedge clk);

			a = x;
			b = y;

			start = 1;

			@(negedge clk);
			start = 0;

			@(posedge done);

			if (product !== x*y)
				$display("FAIL %0d * %0d = %0d (got %0d)",
					x, y, x*y, product);

			else
				$display("PASS %0d * %0d = %0d",
					x, y, product);

			@(negedge clk);

		end

	endtask

	// C2 : scan shift test


	task scan_shift_test;

		reg [31:0] pattern;
		integer i;

		begin

			$display("\nRunning Scan Shift Test");

			// reset
			@(negedge clk);
			rst = 1;

			@(negedge clk);
			rst = 0;

			// enter test mode
			test_mode = 1;
			scan_enable = 1;

			// state=100
			// A=055
			// M=AA
			// Q=33
			// count=5

			pattern = {3'b100, 9'h055, 8'hAA, 8'h33, 4'h5};

			// shift in pattern
			for(i=31; i>=0; i=i-1) begin

				@(negedge clk);
				scan_in = pattern[i];

			end

			@(negedge clk);

			scan_enable = 0;

			#1;

			if(dut.state == 3'b100 &&
			   dut.A == 9'h055 &&
			   dut.M == 8'hAA &&
			   dut.Q == 8'h33 &&
			   dut.cnt == 4'h5)

				$display("C2 PASS");

			else
				$display("C2 FAIL");

		end

	endtask

	// C3 : shift capture shift


	task shift_capture_shift_test;

		reg [31:0] pattern;
		reg [31:0] captured;
		integer i;

		begin

			$display("\nRunning Shift Capture Shift Test");

			@(negedge clk);
			rst = 1;

			@(negedge clk);
			rst = 0;

			test_mode = 1;
			scan_enable = 1;

			// state=LOAD
			// A=0
			// M=13
			// Q=11
			// count=0

			pattern = {3'b001, 9'h000, 8'h0D, 8'h0B, 4'h0};

			// shift in
			for(i=31; i>=0; i=i-1) begin

				@(negedge clk);
				scan_in = pattern[i];

			end

			// capture cycle
			@(negedge clk);

			scan_enable = 0;

			@(negedge clk);

			// shift out
			scan_enable = 1;

			for(i=31; i>=0; i=i-1) begin

				@(negedge clk);

				captured[i] = scan_out;

				scan_in = 0;

			end

			@(negedge clk);

			scan_enable = 0;

			if(dut.state == 3'b010)
				$display("C3 PASS");
			else
				$display("C3 FAIL");

		end

	endtask

	// C4 : at speed test


	task at_speed_test;

		reg [31:0] pattern;
		integer i;

		begin

			$display("\nRunning At Speed Test");

			@(negedge clk);
			rst = 1;

			@(negedge clk);
			rst = 0;

			test_mode = 1;
			scan_enable = 1;

			// count=6
			pattern = {3'b100, 9'h000, 8'h00, 8'h00, 4'h6};

			for(i=31; i>=0; i=i-1) begin

				@(negedge clk);
				scan_in = pattern[i];

			end

			@(negedge clk);

			scan_enable = 0;

			// force shift state
			force dut.state = 3'd4;

			@(posedge clk);

			#1;

			release dut.state;

			if(dut.cnt == 4'd7 && dut.last == 1'b1)
				$display("C4 PASS");
			else
				$display("C4 FAIL");

		end

	endtask

	// main test sequence


	initial begin

		#12 rst = 0;

		// C1 functional tests
		run(13, 11);
		run(0, 0);
		run(255, 255);
		run(1, 255);
		run(128, 2);
		run(170, 85);

		// C2
		scan_shift_test();

		// C3
		shift_capture_shift_test();

		// C4
		at_speed_test();

		$display("\nAll tests completed\n");

		#20;
		$finish;

	end

	// timeout
	initial begin

	#5000;

	if(!done) begin
		$display("TIMEOUT ERROR");
		$finish;
	end

end

endmodule
