`timescale 1ns/1ns
module UCIE_ctl_CNTL_FSM_tb ();	
import UCIE_ctl_shared_pkg::*;


	parameter clk_period=10;
	/////////////////////////////////////////////////// DUT INPUTS ///////////////////////////////////////////////////
	// FDI Signals
	bit 			i_clk, i_rst_n;
	e_request		i_fdi_lp_state_req;
	logic 			i_fdi_lp_rx_active_sts;
	bit				i_fdi_lp_linkerror;
	bit 			i_fdi_pl_error;

	// RDI Signals 
	e_status 		i_rdi_pl_state_sts;
	bit 			i_rdi_pl_inband_pres;
	e_speed 		i_rdi_pl_speedmode;
	e_lnk_cfg 		i_rdi_pl_lnk_cfg;
	bit 			i_rdi_pl_phyinrecenter;
	e_SB_msg 		i_rdi_pl_sb_decode;
	bit 			i_valid_pl_sb;
	bit 	[31:0] 	i_rdi_pl_adv_cap_val;

	// CSR Signals
	bit  		 	i_CSR_UCIe_Link_Control_Retrain;
	bit 	[31:0] 	i_CSR_ADVCAP;

	// TX Signals
	bit 			i_overflow_TX;

	// RX Signals
	bit 			i_overflow_RX;


	/////////////////////////////////////////////////// DUT OUTPUTS ///////////////////////////////////////////////////
	// FDI Signals
	logic 	[3:0]	o_fdi_pl_state_sts_port;
	logic 			o_fdi_pl_inband_pres;
	logic 			o_fdi_pl_rx_active_req;
	logic 	[2:0]		o_fdi_pl_protocol_port;
	logic 	[3:0]		o_fdi_pl_protocol_flitfmt_port;
	logic 			o_fdi_pl_protocol_vld;
	logic	[2:0]		o_fdi_pl_speedmode_port;
	logic	[2:0]		o_fdi_pl_lnk_cfg_port;
	logic 			o_pl_phyinrecenter_i; // INTERNAL IN ADAPTER IT SELF when go to retrain state
	logic 			o_pl_trainerror_i; // INTERNAL IN ADAPTER IT SELF when parameter negotiation fail

	// RDI Signals
	logic 	[3:0]	o_rdi_lp_state_req_port;
	logic 			o_rdi_lp_linkerror;
	logic	[4:0]	o_rdi_lp_sb_decode_port;
	logic 			o_valid_lp_sb;
	logic 	[31:0]	o_rdi_lp_adv_cap_val;
	logic 			i_sb_busy_flag=0;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	e_states cs,ns ;

	typedef enum  { REQS_RSPR_REQR_RSPS,
					REQR_RSPS_REQS_RSPR,
					REQS_REQR_RSPS_RSPR,
					WAITRX_LPSTATEREQ_ACTIVE_REQS_RSPR_REQR_RSPS} e_mode;


	e_status 		o_fdi_pl_state_sts;

	e_protocol 		o_fdi_pl_protocol;

	e_format 		o_fdi_pl_protocol_flitfmt;

	e_speed			o_fdi_pl_speedmode;

	e_lnk_cfg		o_fdi_pl_lnk_cfg;

	e_request 		o_rdi_lp_state_req;

	e_SB_msg		o_rdi_lp_sb_decode;




	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// Clock Generation
	initial begin
		i_clk=0;
		forever begin
		#(clk_period /2 ) i_clk = ~i_clk;
		end
	end

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




	assign cs=e_states'(DUT.cs);
	assign ns=e_states'(DUT.ns);

	assign o_fdi_pl_state_sts 			= e_status'(o_fdi_pl_state_sts_port);
	assign o_fdi_pl_protocol 			= e_protocol'(o_fdi_pl_protocol_port);
	assign o_fdi_pl_protocol_flitfmt	= e_format'(o_fdi_pl_protocol_flitfmt_port);
	assign o_fdi_pl_speedmode  			= e_speed'(o_fdi_pl_speedmode_port);
	assign o_fdi_pl_lnk_cfg  			= e_lnk_cfg'(o_fdi_pl_lnk_cfg_port);
	assign o_rdi_lp_state_req  			= e_request'(o_rdi_lp_state_req_port);
	assign o_rdi_lp_sb_decode   		= e_SB_msg'(o_rdi_lp_sb_decode_port);

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	// DUT Instantiation
	UCIE_ctl_CNTL_FSM DUT (

		// FDI signals

		.i_clk(i_clk), 
		.i_rst_n(i_rst_n),
	 	.i_fdi_lp_state_req(i_fdi_lp_state_req),
		.i_fdi_lp_rx_active_sts(i_fdi_lp_rx_active_sts),
		.i_fdi_lp_linkerror(i_fdi_lp_linkerror),
		.i_fdi_pl_error(i_fdi_pl_error),
	 	.o_fdi_pl_state_sts(o_fdi_pl_state_sts_port),
		.o_fdi_pl_inband_pres(o_fdi_pl_inband_pres),
		.o_fdi_pl_rx_active_req(o_fdi_pl_rx_active_req),
	 	.o_fdi_pl_protocol(o_fdi_pl_protocol_port),
	 	.o_fdi_pl_protocol_flitfmt(o_fdi_pl_protocol_flitfmt_port),
		.o_fdi_pl_protocol_vld(o_fdi_pl_protocol_vld),
		.o_fdi_pl_speedmode(o_fdi_pl_speedmode_port),
		.o_fdi_pl_lnk_cfg(o_fdi_pl_lnk_cfg_port),
		.o_pl_phyinrecenter_i(o_pl_phyinrecenter_i), // INTERNAL IN ADAPTER IT SELF when go to retrain state
		.o_pl_trainerror_i(o_pl_trainerror_i), // INTERNAL IN ADAPTER IT SELF when parameter negotiation fail


	// RDI signals 
	//input i_rdi_lclk,
	 	.i_rdi_pl_state_sts(i_rdi_pl_state_sts),
		.i_rdi_pl_inband_pres(i_rdi_pl_inband_pres),
	 	.i_rdi_pl_speedmode(i_rdi_pl_speedmode),
	 	.i_rdi_pl_lnk_cfg(i_rdi_pl_lnk_cfg),
	 	.i_rdi_pl_sb_decode(i_rdi_pl_sb_decode),
		.i_valid_pl_sb(i_valid_pl_sb),
	 	.i_rdi_pl_adv_cap_val(i_rdi_pl_adv_cap_val),
		.o_rdi_lp_state_req(o_rdi_lp_state_req_port),
		.o_rdi_lp_linkerror(o_rdi_lp_linkerror),
		.o_rdi_lp_sb_decode(o_rdi_lp_sb_decode_port),
		.o_valid_lp_sb(o_valid_lp_sb),
		.o_rdi_lp_adv_cap_val(o_rdi_lp_adv_cap_val),



	// CSR Signals
	  	.i_CSR_UCIe_Link_Control_Retrain(i_CSR_UCIe_Link_Control_Retrain),
	 	.i_CSR_ADVCAP(i_CSR_ADVCAP),

	// TX Signals
	 	.i_overflow_TX(i_overflow_TX),
	 	.i_overflow_RX(i_overflow_RX),
	 	.i_sb_busy_flag(i_sb_busy_flag)

	);


	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


				
	
	task Active_Entry_Link_initialization (input e_mode mode=REQS_RSPR_REQR_RSPS, input train_entry=0,input protocol_trigger_entry=0);
	
		i_fdi_lp_rx_active_sts = 0;

		//i_fdi_lp_state_req = NOP;
		repeat (2) @(negedge i_clk);
		//i_fdi_lp_state_req = Active;

		// here we assume after global reset by 2 cycles phy finished training and pl_inband_pres asserted
		if(protocol_trigger_entry==1) begin

			$display("[%0t] ************************************************** ACTIVE Entry from Remote Die Partner Started **************************************************\n", $time());

			i_fdi_lp_state_req = NOP_REQ;

			repeat (2) @(negedge i_clk);

			i_fdi_lp_state_req = ACTIVE_REQ;

		end
		else begin
			$display("[%0t] ******************************************************** ACTIVE Entry from Reset Started *********************************************************\n", $time());
			i_rdi_pl_inband_pres=1;
		end

		i_rdi_pl_speedmode=GT_4;
		i_rdi_pl_lnk_cfg=X8;



		// fsm must send req active state on phy 
		@(negedge i_clk);

		if ( (o_fdi_pl_state_sts==RESET_STS ) && i_rdi_pl_inband_pres) begin
			if (o_rdi_lp_state_req 	!=  ACTIVE_REQ ) begin
				$display("[%0t] ERROR IN ADAPTER IN STATE REQ_ACTIVE_ON_PHY o_rdi_lp_state_req=active must be asserted", $time());
				$stop;
			end
		end

		else  begin

			if (o_rdi_lp_state_req 	!=  NOP_REQ ) begin
				$display("[%0t] ERROR IN ADAPTER IN STATE REQ_ACTIVE_ON_PHY o_rdi_lp_state_req=NOP_REQ must be asserted", $time());
				$stop;
			end
			
			
			@(negedge i_clk);

			if (o_rdi_lp_state_req 	!=  ACTIVE_REQ ) begin
				$display("[%0t] ERROR IN ADAPTER IN STATE REQ_ACTIVE_ON_PHY o_rdi_lp_state_req=ACTIVE_REQ must be asserted", $time());
				$stop;
			end


		end


		

		repeat(4) @(negedge i_clk);

		i_rdi_pl_state_sts=ACTIVE_STS;

		 if (!o_fdi_pl_inband_pres) begin
		 	//here we go to see caps
			// fsm send sb for adv caps


			@(negedge i_clk);

			busy_trigger();

			if (o_rdi_lp_sb_decode 	!=  SB_ADV_CAP_ADAPTER ||  o_valid_lp_sb !=1 || o_rdi_lp_adv_cap_val != i_CSR_ADVCAP ) begin
				$display("[%0t] ERROR IN ADAPTER IN ADV_CAP STATE ", $time());
			end


			repeat(2) @(negedge i_clk);

			i_valid_pl_sb = 1;
			i_rdi_pl_sb_decode =SB_ADV_CAP_ADAPTER;
			i_rdi_pl_adv_cap_val=32'b1_0001;
			i_CSR_ADVCAP=32'b1_0001;

			fork
				begin
					@(negedge i_clk) ;
					if (o_fdi_pl_inband_pres 	!=  1 ) begin
						$display("[%0t] ERROR IN PARAMETER NEGOTIATION DONE STATE", $time());
						$stop;
					end
				end
			join_none


			// here fsm go to parameter negotiation done

		 end



		


		if (mode== REQS_RSPR_REQR_RSPS || train_entry==1) begin
			
			if (!train_entry) begin
				@(negedge i_clk);

				i_fdi_lp_state_req=ACTIVE_REQ;
			end

			@(negedge i_clk);
				// here cntl will send sb to remote die partner
			
			busy_trigger();
 
			if (o_rdi_lp_sb_decode != SB_ADAPTER_REQ_ACTIVE || !o_valid_lp_sb  ) begin
				$display("[%0t] ERROR IN SEND SB ACTIVE REQ  STATE", $time());
				$stop;
			end


			repeat(2) @(negedge i_clk);

			i_valid_pl_sb = 1;
			i_rdi_pl_sb_decode = SB_ADAPTER_RSP_ACTIVE;

			//here we will go to SB ACTIVE RESPONSE RECEIVED
			
			@(negedge i_clk);
			if (DUT.TX_done_flag != 1 ) begin
				$display("[%0t] ERROR IN SB ACTIVE RSP RECEIVED STATE ", $time());
				$stop;
			end

			//here fsm we will wait till other partner start handshake


			repeat(3) @(negedge i_clk);

			i_valid_pl_sb = 1;
			i_rdi_pl_sb_decode = SB_ADAPTER_REQ_ACTIVE;

			@(negedge i_clk);
			// HERE WE WILL SEND TO PROTOCOL TO OPEN RX

			if (!o_fdi_pl_rx_active_req) begin

				$display("[%0t] ERROR IN OPEN RX STATE", $time());
				$stop;

			end


			repeat(2) @(negedge i_clk);
			i_fdi_lp_rx_active_sts = 1;
			@(negedge i_clk);

			busy_trigger();


			if (o_rdi_lp_sb_decode != SB_ADAPTER_RSP_ACTIVE || !o_valid_lp_sb || !DUT.RX_done_flag ) begin

				$display("[%0t] ERROR IN SEND SB ACTIVE RESPONSE", $time());
				$stop;

			end

			repeat(2) @(negedge i_clk);


		end








		else if (mode== REQR_RSPS_REQS_RSPR) begin
			repeat(5) @(negedge i_clk);



			i_valid_pl_sb = 1;
			i_rdi_pl_sb_decode = SB_ADAPTER_REQ_ACTIVE;

			@(negedge i_clk);
			// HERE WE WILL SEND TO PROTOCOL TO OPEN RX

			if (!o_fdi_pl_rx_active_req) begin

				$display("[%0t] ERROR IN OPEN RX STATE", $time());
				$stop;

			end

			repeat(2) @(negedge i_clk);
			i_fdi_lp_rx_active_sts = 1;


			@(negedge i_clk);

			busy_trigger();

			if (o_rdi_lp_sb_decode != SB_ADAPTER_RSP_ACTIVE || !o_valid_lp_sb || !DUT.RX_done_flag ) begin

				$display("[%0t] ERROR IN SEND SB ACTIVE RESPONSE", $time());
				$stop;

			end


			repeat(2) @(negedge i_clk);


			i_fdi_lp_state_req=ACTIVE_REQ;

			/// note any state send sb messages will need min 2 cycles delay

			 @(negedge i_clk);
			// here cntl will send sb to remote die partner

			busy_trigger();
			
			if (o_rdi_lp_sb_decode != SB_ADAPTER_REQ_ACTIVE || !o_valid_lp_sb  ) begin
				$display("[%0t] ERROR IN SEND SB ACTIVE REQ  STATE", $time());
				$stop;
			end



			repeat(2) @(negedge i_clk);



			i_valid_pl_sb = 1;
			i_rdi_pl_sb_decode = SB_ADAPTER_RSP_ACTIVE;

			@(negedge i_clk)

			//here we will go to SB ACTIVE RESPONSE RECEIVED
			if (DUT.TX_done_flag != 1 ) begin
				$display("[%0t] ERROR IN SB ACTIVE RSP RECEIVED STATE ", $time());
				$stop;
			end

			@(negedge i_clk);


		end

		else if (mode == REQS_REQR_RSPS_RSPR) begin
			 @(negedge i_clk);

			i_fdi_lp_state_req=ACTIVE_REQ;

			 @(negedge i_clk);
			// here cntl will send sb to remote die partner

			busy_trigger();

			if (o_rdi_lp_sb_decode != SB_ADAPTER_REQ_ACTIVE || !o_valid_lp_sb  ) begin
				$display("[%0t] ERROR IN SEND SB ACTIVE REQ  STATE", $time());
				$stop;
			end


			repeat(2) @(negedge i_clk);

			i_valid_pl_sb = 1;
			i_rdi_pl_sb_decode = SB_ADAPTER_REQ_ACTIVE;

			@(negedge i_clk);
			//here we will go directly to open RX state 


			if (!o_fdi_pl_rx_active_req) begin

				$display("[%0t] ERROR IN OPEN RX STATE", $time());
				$stop;

			end


			repeat(2) @(negedge i_clk);
			i_fdi_lp_rx_active_sts = 1;


			@(negedge i_clk);
			//HERE WE SHALL SEND SB ACTIVE RSP
			busy_trigger();
			if (o_rdi_lp_sb_decode != SB_ADAPTER_RSP_ACTIVE || !o_valid_lp_sb || !DUT.RX_done_flag ) begin

				$display("[%0t] ERROR IN SEND SB ACTIVE RESPONSE", $time());
				$stop;

			end

			

			repeat(2) @(negedge i_clk);

			//here we have corner case

			i_valid_pl_sb = 1;
			i_rdi_pl_sb_decode = SB_ADAPTER_RSP_ACTIVE;

			@(negedge i_clk);

			//here we will go to SB ACTIVE RESPONSE RECEIVED
			if (DUT.TX_done_flag != 1 ) begin
				$display("[%0t] ERROR IN SB ACTIVE RSP RECEIVED STATE ", $time());
				$stop;
			end
			@(negedge i_clk);
			
		end

		else if (mode == WAITRX_LPSTATEREQ_ACTIVE_REQS_RSPR_REQR_RSPS) begin
			repeat(5) @(negedge i_clk);




			i_fdi_lp_state_req=ACTIVE_REQ;
			@(negedge i_clk);
			// here cntl will send sb to remote die partner

		
			busy_trigger();
			if (o_rdi_lp_sb_decode != SB_ADAPTER_REQ_ACTIVE || !o_valid_lp_sb  ) begin
				$display("[%0t] ERROR IN SEND SB ACTIVE REQ  STATE", $time());
				$stop;
			end


			repeat(2) @(negedge i_clk);

			i_valid_pl_sb = 1;
			i_rdi_pl_sb_decode = SB_ADAPTER_RSP_ACTIVE;

			@(negedge i_clk);
			//here we will go to SB ACTIVE RESPONSE RECEIVED
			if (DUT.TX_done_flag != 1 ) begin
				$display("[%0t] ERROR IN SB ACTIVE RSP RECEIVED STATE ", $time());
				$stop;
			end

			//here fsm we will wait till other partner start handshake


			repeat(3) @(negedge i_clk);

			i_valid_pl_sb = 1;
			i_rdi_pl_sb_decode = SB_ADAPTER_REQ_ACTIVE;

			@(negedge i_clk);
			// HERE WE WILL SEND TO PROTOCOL TO OPEN RX

			if (!o_fdi_pl_rx_active_req) begin

				$display("[%0t] ERROR IN OPEN RX STATE", $time());
				$stop;

			end


			repeat(2) @(negedge i_clk);
			i_fdi_lp_rx_active_sts = 1;
			@(negedge i_clk);

			busy_trigger();
			if (o_rdi_lp_sb_decode != SB_ADAPTER_RSP_ACTIVE || !o_valid_lp_sb || !DUT.RX_done_flag ) begin

				$display("[%0t] ERROR IN SEND SB ACTIVE RESPONSE", $time());
				$stop;

			end
			repeat(2)@(negedge i_clk);

		end 



		if (o_fdi_pl_state_sts != ACTIVE_STS  || !o_fdi_pl_protocol_vld ) begin

				$display("[%0t] ERROR IN  ACTIVE STATE", $time());
				$stop;

		end

		$display("[%0t] ******************************************************* Successfully Entered ACTIVE State ********************************************************\n", $time());

	 	 @(negedge i_clk);

	endtask

	task initialize_inputs;
		// FDI Signals
		i_rst_n 				= 0;
		i_fdi_lp_state_req 		= NOP_REQ;
		i_fdi_lp_rx_active_sts 	= 0;
		i_fdi_lp_linkerror 		= 0;
		i_fdi_pl_error 			= 0;

		// RDI Signals 
		i_rdi_pl_state_sts 		= RESET_STS;
		i_rdi_pl_inband_pres 	= 0;
		i_rdi_pl_speedmode 		= GT_4;
		i_rdi_pl_lnk_cfg 		= X8;
		i_rdi_pl_phyinrecenter  = 0;
		i_rdi_pl_sb_decode 		= SB_ADV_CAP_ADAPTER; 	// Garbage Value
		i_valid_pl_sb 			= 0;
		i_rdi_pl_adv_cap_val 	= 0;

		// CSR Signals
		i_CSR_UCIe_Link_Control_Retrain = 0;
		i_CSR_ADVCAP 					= 32'b10001;

		// TX Signals
		i_overflow_TX 					= 0;

		// RX Signals
		i_overflow_RX 					= 0;
		i_sb_busy_flag 					= 0;

	endtask : initialize_inputs

	task global_reset();
		initialize_inputs();

		$display("[%0t] ***************************************************************** Reset Asserted *****************************************************************\n", $time());
		
		i_rst_n=0;

		repeat (5) @(negedge i_clk);

		i_rst_n=1;

		$display("[%0t] **************************************************************** Reset Deasserted ****************************************************************\n", $time());
		
	endtask


	// Tasks
	task enter_linkerror_trigger_protocol;
		$display("[%0t] ************************************************** LINKERROR Entry from Protocol Layer Started ***************************************************\n", $time());

		i_fdi_lp_linkerror = 1;
		i_rdi_pl_state_sts = o_fdi_pl_state_sts;		// Assuming Stable State (Adapter State = Phy State)
		i_overflow_RX 		= 0;
		i_overflow_TX 		= 0;
		i_rdi_pl_inband_pres =0;

		@(negedge i_clk);
		if (o_rdi_lp_linkerror != 1) begin
			$display("[%0t] ERROR - LINKERROR_ENTRY - Trigger: Protocol Layer - i_fdi_lp_linkerror = 1", $time());
			$display("Adapter did not forward lp_linkerror to Phy --- o_rdi_lp_linkerror = %0d, should = 1", o_rdi_lp_linkerror);
			$stop();
		end
		if (o_fdi_pl_state_sts == LINKERROR_STS) begin
			$display("[%0t] ERROR - LINKERROR_ENTRY - Trigger: Protocol Layer - i_fdi_lp_linkerror = 1", $time());
			$display("Adapter should wait for Phy Status (LINKERROR_STS) before transitioning to LINKERROR");
			$stop();
		end


		if (o_rdi_lp_linkerror == 1) begin
			// Respond to Adapter's Request from Phy
			repeat (5) @(negedge i_clk);
			i_rdi_pl_state_sts = LINKERROR_STS;
			@(negedge i_clk);

			if (o_fdi_pl_state_sts != LINKERROR_STS) begin
				$display("[%0t] ERROR - LINKERROR_ENTRY - Trigger: Protocol Layer - i_rdi_pl_state_sts = LINKERROR_STS", $time());
				$display("Adapter did not transition to LINKERROR --- o_fdi_pl_state_sts = %s, should = 1", o_fdi_pl_state_sts);

				$stop();
			end
			$display("[%0t] ***************************************************** Successfully Entered LINKERROR State *******************************************************\n", $time());

		end

	endtask : enter_linkerror_trigger_protocol


	// The following two tasks should be used when DUT is in Active State
	task enter_linkerror_trigger_TX;
		$display("[%0t] ************************************************** LINKERROR Entry due to TX Overflow Started ****************************************************\n", $time());

		i_fdi_lp_linkerror 	= 0;
		i_overflow_RX 		= 0;
		i_overflow_TX 		= 1;
		i_rdi_pl_state_sts 	= o_fdi_pl_state_sts;		// Assuming Stable State (Adapter State = Phy State)
		i_fdi_lp_state_req 	= NOP_REQ;
		i_rdi_pl_inband_pres =0;


		@(negedge i_clk);
		if (o_fdi_pl_state_sts == ACTIVE_STS) begin
			if (o_rdi_lp_linkerror != 1) begin
				$display("[%0t] ERROR - LINKERROR_ENTRY - Trigger: TX Overflow - i_overflow_TX = 1", $time());
				$display("Adapter did not forward lp_linkerror to Phy --- o_rdi_lp_linkerror = %0d, should = 1", o_rdi_lp_linkerror);
				$stop();
			end
			if (o_fdi_pl_state_sts == LINKERROR_STS) begin
				$display("[%0t] ERROR - LINKERROR_ENTRY - Trigger: TX Overflow - i_overflow_TX = 1", $time());
				$display("Adapter should wait for Phy Status (LINKERROR_STS) before transitioning to LINKERROR");
				$stop();
			end


			if (o_rdi_lp_linkerror == 1) begin
				// Respond to Adapter's Request from Phy
				repeat (5) @(negedge i_clk);
				i_rdi_pl_state_sts = LINKERROR_STS;
				@(negedge i_clk);

				if (o_fdi_pl_state_sts != LINKERROR_STS) begin
					$display("[%0t] ERROR - LINKERROR_ENTRY - Trigger: TX Overflow - i_rdi_pl_state_sts = LINKERROR_STS", $time());
					$display("Adapter did not transition to LINKERROR --- o_fdi_pl_state_sts = %s, should = 1", o_fdi_pl_state_sts);

					$stop();
				end

				$display("[%0t] ***************************************************** Successfully Entered LINKERROR State *******************************************************\n", $time());

			end
		end
	endtask : enter_linkerror_trigger_TX




	task enter_linkerror_trigger_RX;
		$display("[%0t] ************************************************** LINKERROR Entry due to RX Overflow Started ****************************************************\n", $time());

		i_fdi_lp_linkerror 	= 0;
		i_overflow_TX 		= 0;
		i_overflow_RX 		= 1;
		i_fdi_lp_state_req 	= NOP_REQ;
		i_rdi_pl_state_sts 	= o_fdi_pl_state_sts;		// Assuming Stable State (Adapter State = Phy State)
		i_rdi_pl_inband_pres =0;


		@(negedge i_clk);
		if (o_fdi_pl_state_sts == ACTIVE_STS) begin
			if (o_rdi_lp_linkerror != 1) begin
				$display("[%0t] ERROR - LINKERROR_ENTRY - Trigger: RX Overflow - i_overflow_RX = 1", $time());
				$display("Adapter did not forward lp_linkerror to Phy --- o_rdi_lp_linkerror = %0d, should = 1", o_rdi_lp_linkerror);
				$stop();
			end
			if (o_fdi_pl_state_sts == LINKERROR_STS) begin
				$display("[%0t] ERROR - LINKERROR_ENTRY - Trigger: RX Overflow - i_overflow_RX = 1", $time());
				$display("Adapter should wait for Phy Status (LINKERROR_STS) before transitioning to LINKERROR");
				$stop();
			end
			

			if (o_rdi_lp_linkerror == 1) begin
				// Respond to Adapter's Request from Phy
				repeat (5) @(negedge i_clk);
				i_rdi_pl_state_sts = LINKERROR_STS;
				@(negedge i_clk);

				if (o_fdi_pl_state_sts != LINKERROR_STS) begin
					$display("[%0t] ERROR - LINKERROR_ENTRY - Trigger: RX Overflow - i_rdi_pl_state_sts = LINKERROR_STS", $time());
					$display("Adapter did not transition to LINKERROR --- o_fdi_pl_state_sts = %s, should = LINKERROR_STS", o_fdi_pl_state_sts);

					$stop();
				end

				$display("[%0t] ***************************************************** Successfully Entered LINKERROR State *******************************************************\n", $time());

			end
		end
	endtask : enter_linkerror_trigger_RX



	task enter_linkerror_trigger_PHY;
		$display("[%0t] ************************************************** LINKERROR Entry from Physical Layer Started ***************************************************\n", $time());

		i_fdi_lp_linkerror 	= 0;
		i_overflow_TX 		= 0;
		i_overflow_RX 		= 0;
		i_rdi_pl_state_sts 	= LINKERROR_STS;
		i_rdi_pl_inband_pres =0;

		@(negedge i_clk);
		if (o_fdi_pl_state_sts != LINKERROR_STS) begin
			$display("[%0t] ERROR - LINKERROR_ENTRY - Trigger: Physical Layer - i_rdi_pl_state_sts = LINKERROR_STS", $time());
			$display("Adapter did not transition to LINKERROR --- o_fdi_pl_state_sts = %s, should = LINKERROR_STS", o_fdi_pl_state_sts);

			$stop();
		end
		else
			$display("[%0t] ***************************************************** Successfully Entered LINKERROR State *******************************************************\n", $time());

	endtask : enter_linkerror_trigger_PHY





	task enter_linkreset_trigger_protocol;
		$display("[%0t] ************************************************** LINKRESET Entry from Protocol Layer Started ***************************************************\n", $time());

		i_fdi_lp_linkerror 	= 0;
		i_overflow_TX 		= 0;
		i_overflow_RX 		= 0;
		i_rdi_pl_state_sts 	= o_fdi_pl_state_sts; 		// Assuming Stable State (Adapter State = Phy State)
		i_valid_pl_sb		= 0;						// Only Trigger by Protocol

		
		if (o_fdi_pl_state_sts == RESET_STS) begin
			i_fdi_lp_state_req 	= NOP_REQ;
			@(negedge i_clk);
			i_fdi_lp_state_req 	= LINKRESET_REQ;
		end
		else if (o_fdi_pl_state_sts != LINKERROR_STS) begin
			i_fdi_lp_state_req 	= LINKRESET_REQ;
		end

		@(negedge i_clk);
		if (i_rdi_pl_state_sts != LINKERROR_STS) begin
			busy_trigger();

			if (o_rdi_lp_sb_decode != SB_ADAPTER_REQ_LINKRESET) begin
				$display("[%0t] ERROR - LINKRESET_ENTRY - Trigger: Protocol Layer - i_fdi_lp_state_req = LINKRESET_REQ", $time());
				$display("Adapter did not send LINKRESET_REQ SB MSG --- o_rdi_lp_sb_decode = %s, should = SB_ADAPTER_REQ_LINKRESET", o_rdi_lp_sb_decode);

				$stop();
			end

			if (o_valid_lp_sb != 1) begin
				$display("[%0t] ERROR - LINKRESET_ENTRY - Trigger: Protocol Layer - i_fdi_lp_state_req = LINKRESET_REQ", $time());
				$display("Adapter did not send LINKRESET_REQ SB MSG --- o_valid_lp_sb = %s, should = 1", o_valid_lp_sb);

				$stop();
			end

			// Respond to Adapter's SB Request from Phy (Remote Adapter)
			repeat(5) @(negedge i_clk);
			i_rdi_pl_sb_decode 	= SB_ADAPTER_RSP_LINKRESET;
			i_valid_pl_sb 		= 1;
			@(negedge i_clk);

			if (o_fdi_pl_state_sts != LINKRESET_STS) begin
				$display("[%0t] ERROR - LINKRESET_ENTRY - Trigger: Protocol Layer - i_fdi_lp_state_req = LINKRESET_REQ", $time());
				$display("Adapter did not transition to LINKRESET --- o_fdi_pl_state_sts = %s, should = LINKRESET_STS", o_fdi_pl_state_sts);

				$stop();
			end

			if (o_rdi_lp_state_req != LINKRESET_REQ) begin
				$display("[%0t] ERROR - LINKRESET_ENTRY - Trigger: Protocol Layer - i_fdi_lp_state_req = LINKRESET_REQ", $time());
				$display("Adapter did not propagate LINKRESET_REQ to Phy --- o_rdi_lp_state_req = %s, should = LINKRESET_REQ", o_rdi_lp_state_req);

				$stop();
			end


			// Respond to Adapter's RDI Request from Phy
			repeat(5) @(negedge i_clk);
			i_rdi_pl_state_sts = LINKRESET_STS;
			@(negedge i_clk);


			$display("[%0t] ***************************************************** Successfully Entered LINKRESET State *******************************************************\n", $time());
		end


	endtask : enter_linkreset_trigger_protocol




	task enter_linkreset_trigger_SB_MSG;
		$display("[%0t] ************************************************ LINKRESET Entry from Remote Die Partner Started *************************************************\n", $time());

		i_fdi_lp_linkerror 	= 0;
		i_overflow_TX 		= 0;
		i_overflow_RX 		= 0;
		i_rdi_pl_state_sts 	= o_fdi_pl_state_sts; 		// Assuming Stable State (Adapter State = Phy State)
		i_fdi_lp_state_req 	= NOP_REQ;

		i_rdi_pl_sb_decode 	= SB_ADAPTER_REQ_LINKRESET;
		i_valid_pl_sb 		= 1;

		@(negedge i_clk);

		if (i_rdi_pl_state_sts != LINKERROR_STS) begin
			busy_trigger();
			if (o_fdi_pl_state_sts != LINKRESET_STS) begin
				$display("[%0t] ERROR - LINKRESET_ENTRY - Trigger: SB MSG - i_rdi_pl_sb_decode = SB_ADAPTER_REQ_LINKRESET", $time());
				$display("Adapter did not transition to LINKRESET --- o_fdi_pl_state_sts = %s, should = LINKRESET_STS", o_fdi_pl_state_sts);

				$stop();
			end

			if (o_rdi_lp_sb_decode != SB_ADAPTER_RSP_LINKRESET) begin
				$display("[%0t] ERROR - LINKRESET_ENTRY - Trigger: SB MSG - i_rdi_pl_sb_decode = SB_ADAPTER_REQ_LINKRESET", $time());
				$display("Adapter did not send LINKRESET_RSP SB MSG --- o_rdi_lp_sb_decode = %s, should = SB_ADAPTER_RSP_LINKRESET", o_rdi_lp_sb_decode);

				$stop();
			end

			if (o_valid_lp_sb != 1) begin
				$display("[%0t] ERROR - LINKRESET_ENTRY - Trigger: SB MSG - i_rdi_pl_sb_decode = SB_ADAPTER_REQ_LINKRESET", $time());
				$display("Adapter did not send LINKRESET_RSP SB MSG --- o_valid_lp_sb = %s, should = 1", o_valid_lp_sb);

				$stop();
			end


			// Report Phy LINKRESET transition to Adapter
			repeat(5) @(negedge i_clk);
			i_rdi_pl_state_sts = LINKRESET_STS;
			@(negedge i_clk);


			$display("[%0t] ***************************************************** Successfully Entered LINKRESET State *******************************************************\n", $time());
		end

	endtask : enter_linkreset_trigger_SB_MSG




	task enter_retrain_trigger_protocol;
		$display("[%0t] *************************************************** RETRAIN Entry from Protocol Layer Started ****************************************************\n", $time());

		i_fdi_lp_linkerror 	= 0;
		i_overflow_TX 		= 0;
		i_overflow_RX 		= 0;
		i_rdi_pl_state_sts 	= o_fdi_pl_state_sts; 		// Assuming Stable State (Adapter State = Phy State)
		i_valid_pl_sb		= 0;						// Only Trigger by Protocol
		i_fdi_lp_state_req 	= RETRAIN_REQ;

		@(negedge i_clk);
		if (i_rdi_pl_state_sts != LINKERROR_STS) begin
			if (o_rdi_lp_state_req != RETRAIN_REQ) begin
				$display("[%0t] ERROR - RETRAIN_ENTRY - Trigger: Protocol Layer - i_fdi_lp_state_req = RETRAIN_REQ", $time());
				$display("Adapter did not propagate Protocol RETRAIN_REQ to Phy --- o_rdi_lp_state_req = %s, should = RETRAIN_REQ", o_rdi_lp_state_req);

				$stop();
			end

			// Respond to Adapter's RDI Request from Phy
			repeat(5) @(negedge i_clk);
			i_rdi_pl_state_sts = RETRAIN_STS;
			@(negedge i_clk);

			if (o_fdi_pl_state_sts != RETRAIN_STS) begin
				$display("[%0t] ERROR - RETRAIN_ENTRY - Trigger: Protocol Layer - i_fdi_lp_state_req = RETRAIN_REQ", $time());
				$display("Adapter did not report RETRAIN_STS to Protocol --- o_fdi_pl_state_sts = %s, should = RETRAIN_STS", o_fdi_pl_state_sts);

				$stop();
			end

			$display("[%0t] ****************************************************** Successfully Entered RETRAIN State ********************************************************\n", $time());
		
		end
	endtask : enter_retrain_trigger_protocol




	task enter_retrain_trigger_CSR;
		$display("[%0t] ********************************************************* RETRAIN Entry from CSR Started *********************************************************\n", $time());

		i_fdi_lp_linkerror 	= 0;
		i_overflow_TX 		= 0;
		i_overflow_RX 		= 0;
		i_rdi_pl_state_sts 	= o_fdi_pl_state_sts; 		// Assuming Stable State (Adapter State = Phy State)
		i_valid_pl_sb		= 0;
		i_fdi_lp_state_req 	= NOP_REQ;
		i_CSR_UCIe_Link_Control_Retrain = 1;

		@(negedge i_clk);
		if (i_rdi_pl_state_sts != LINKERROR_STS) begin
			if (o_rdi_lp_state_req != RETRAIN_REQ) begin
				$display("[%0t] ERROR - RETRAIN_ENTRY - Trigger: CSR - i_CSR_UCIe_Link_Control_Retrain = 1", $time());
				$display("Adapter did not propagate CSR RETRAIN_REQ to Phy --- o_rdi_lp_state_req = %s, should = RETRAIN_REQ", o_rdi_lp_state_req);

				$stop();
			end

			// Respond to Adapter's RDI Request from Phy
			repeat(5) @(negedge i_clk);
			i_rdi_pl_state_sts = RETRAIN_STS;
			@(negedge i_clk);

			if (o_fdi_pl_state_sts != RETRAIN_STS) begin
				$display("[%0t] ERROR - RETRAIN_ENTRY - Trigger: Protocol Layer - i_fdi_lp_state_req = RETRAIN_REQ", $time());
				$display("Adapter did not report RETRAIN_STS to Protocol --- o_fdi_pl_state_sts = %s, should = RETRAIN_STS", o_fdi_pl_state_sts);

				$stop();
			end

			$display("[%0t] ****************************************************** Successfully Entered RETRAIN State ********************************************************\n", $time());
		
		end
	endtask : enter_retrain_trigger_CSR




	task enter_retrain_trigger_error;
		$display("[%0t] ************************************************** RETRAIN Entry due to Internal Error Started ***************************************************\n", $time());

		i_fdi_lp_linkerror 	= 0;
		i_overflow_TX 		= 0;
		i_overflow_RX 		= 0;
		i_rdi_pl_state_sts 	= o_fdi_pl_state_sts; 		// Assuming Stable State (Adapter State = Phy State)
		i_valid_pl_sb		= 0;
		i_fdi_lp_state_req 	= NOP_REQ;
		i_CSR_UCIe_Link_Control_Retrain = 0;
		i_fdi_pl_error 		= 1;

		@(negedge i_clk);
		if (i_rdi_pl_state_sts != LINKERROR_STS) begin
			if (o_rdi_lp_state_req != RETRAIN_REQ) begin
				$display("[%0t] ERROR - RETRAIN_ENTRY - Trigger: Internal - i_fdi_pl_error = 1", $time());
				$display("Adapter did not propagate RETRAIN_REQ to Phy --- o_rdi_lp_state_req = %s, should = RETRAIN_REQ", o_rdi_lp_state_req);

				$stop();
			end

			// Respond to Adapter's RDI Request from Phy
			repeat(5) @(negedge i_clk);
			i_rdi_pl_state_sts = RETRAIN_STS;
			@(negedge i_clk);

			if (o_fdi_pl_state_sts != RETRAIN_STS) begin
				$display("[%0t] ERROR - RETRAIN_ENTRY - Trigger: Internal - i_fdi_pl_error = 1", $time());
				$display("Adapter did not report RETRAIN_STS to Protocol --- o_fdi_pl_state_sts = %s, should = RETRAIN_STS", o_fdi_pl_state_sts);

				$stop();
			end

			$display("[%0t] ****************************************************** Successfully Entered RETRAIN State ********************************************************\n", $time());
		
		end
	endtask : enter_retrain_trigger_error




	task enter_retrain_trigger_PHY;
		$display("[%0t] *************************************************** RETRAIN Entry from Physical Layer Started ****************************************************\n", $time());

		i_fdi_lp_linkerror 	= 0;
		i_overflow_TX 		= 0;
		i_overflow_RX 		= 0;
		i_valid_pl_sb		= 0;
		i_fdi_lp_state_req 	= NOP_REQ;
		i_CSR_UCIe_Link_Control_Retrain = 0;
		i_fdi_pl_error 		= 0;
		i_rdi_pl_state_sts 	= RETRAIN_STS;

		@(negedge i_clk);
		if (o_fdi_pl_state_sts != RETRAIN_STS) begin
			$display("[%0t] ERROR - RETRAIN_ENTRY - Trigger: Physical Layer - i_rdi_pl_state_sts = RETRAIN_STS", $time());
			$display("Adapter did not report RETRAIN_STS to Protocol --- o_fdi_pl_state_sts = %s, should = RETRAIN_STS", o_fdi_pl_state_sts);

			$stop();
		end

		$display("[%0t] ****************************************************** Successfully Entered RETRAIN State ********************************************************\n", $time());
		
	endtask : enter_retrain_trigger_PHY



	task enter_reset_trigger_Protocol;
		$display("[%0t] **************************************************** RESET Entry from Protocol Layer Started *****************************************************\n", $time());

		i_fdi_lp_linkerror 	= 0;
		i_overflow_TX 		= 0;
		i_overflow_RX 		= 0;
		i_rdi_pl_state_sts 	= o_fdi_pl_state_sts;			// Assuming Stable State (Adapter State = Phy State)
		i_valid_pl_sb		= 0;
		i_fdi_lp_state_req 	= ACTIVE_REQ;
		i_CSR_UCIe_Link_Control_Retrain = 0;
		i_fdi_pl_error 		= 0;

		
		if (o_fdi_pl_state_sts == LINKERROR_STS) begin
			repeat(41) @(negedge i_clk);
		end
		else begin
			@(negedge i_clk);
		end
		
		if (o_rdi_lp_state_req != ACTIVE_REQ) begin
			$display("[%0t] ERROR - RESET_ENTRY - Trigger: Protocol Layer - i_fdi_lp_state_req = ACTIVE_REQ", $time());
			$display("Adapter did not propagate Protocol ACTIVE_REQ to Phy --- o_rdi_lp_state_req = %s, should = ACTIVE_REQ", o_rdi_lp_state_req);

			$stop();
		end

		// Respond to Adapter's RDI Request from Phy
		repeat(5) @(negedge i_clk);
		i_rdi_pl_state_sts = RESET_STS;
		@(negedge i_clk);

		if (o_fdi_pl_state_sts != RESET_STS) begin
			$display("[%0t] ERROR - RESET_ENTRY - Trigger: Protocol Layer - i_fdi_lp_state_req = ACTIVE_REQ", $time());
			$display("Adapter did not report RESET_STS to Protocol --- o_fdi_pl_state_sts = %s, should = RESET_STS", o_fdi_pl_state_sts);

			$stop();
		end

		$display("[%0t] ******************************************************* Successfully Entered RESET State *********************************************************\n", $time());		
	

	endtask : enter_reset_trigger_Protocol



	task enter_reset_trigger_PHY;
		$display("[%0t] **************************************************** RESET Entry from Physical Layer Started *****************************************************\n", $time());

		i_fdi_lp_linkerror 	= 0;
		i_overflow_TX 		= 0;
		i_overflow_RX 		= 0;
		i_rdi_pl_state_sts 	= RESET_STS;
		i_valid_pl_sb		= 0;
		i_fdi_lp_state_req 	= NOP_REQ;
		i_CSR_UCIe_Link_Control_Retrain = 0;
		i_fdi_pl_error 		= 0;

		

		@(negedge i_clk);
		if (o_fdi_pl_state_sts != RESET_STS) begin
			$display("[%0t] ERROR - RESET_ENTRY - Trigger: Physical Layer - i_rdi_pl_state_sts = RESET_STS", $time());
			$display("Adapter did not report RESET_STS to Protocol --- o_fdi_pl_state_sts = %s, should = RESET_STS", o_fdi_pl_state_sts);

			$stop();
		end

		$display("[%0t] ******************************************************* Successfully Entered RESET State *********************************************************\n", $time());		

	endtask : enter_reset_trigger_PHY



	task busy_trigger ;
		fork
			begin
				i_sb_busy_flag=0;

				@(posedge i_clk);

				i_sb_busy_flag=1;

				 @(posedge i_clk);

				i_sb_busy_flag=0;
			end
		join_none
	endtask

	task retrain_flow_diagram_TX_protocol_RX_phy();
		$display("[%0t] ******************************************************* RETRAIN Flow Diagram Test Started ********************************************************\n", $time());

		/////////////////////////////////////////////////////////////////////////////////
						// Active to Retrain  RETRAIN FLOW TX FROM PROTOCOL
		enter_retrain_trigger_protocol();



		repeat (10) @(negedge i_clk); 		// Retrain State

		Active_Entry_Link_initialization(REQS_RSPR_REQR_RSPS,1,1);

		///////////////////////////////////////////////////////////////////////////////


		/////////////////////////////////////////////////////////////////////////////////
						// Active to Retrain  RETRAIN FLOW RX FROM PHY
		enter_retrain_trigger_PHY();



		repeat (10) @(negedge i_clk); 		// Retrain State

		Active_Entry_Link_initialization(REQS_RSPR_REQR_RSPS,1,1);
		repeat (10) @(negedge i_clk); 		// Retrain State



		$display("[%0t] ********************************************** RETRAIN Flow Diagram Test is Completed Successfully ***********************************************\n", $time());


		///////////////////////////////////////////////////////////////////////////////

	endtask

	task linkerror_flow_diagram_TX_protocol_RX_phy();
		$display("[%0t] ****************************************************** LINKERROR Flow Diagram Test Started *******************************************************\n", $time());

		/////////////////////////////////////////////////////////////////////////////////////////////
						// Active to LINKERROR   FLOW TX FROM PROTOCOL
		enter_linkerror_trigger_protocol();
		enter_reset_trigger_Protocol();


		repeat (10) @(negedge i_clk); 	

		Active_Entry_Link_initialization(REQS_REQR_RSPS_RSPR,0,1);

		///////////////////////////////////////////////////////////////////////////////


		/////////////////////////////////////////////////////////////////////////////////
						// Active to LINKERROR   FLOW RX FROM PHY
		enter_linkerror_trigger_PHY();
		enter_reset_trigger_PHY();

		repeat (10) @(negedge i_clk); 	


		Active_Entry_Link_initialization(REQS_REQR_RSPS_RSPR,0,1);

		repeat (10) @(negedge i_clk); 



		$display("[%0t] ********************************************* LINKERROR Flow Diagram Test is Completed Successfully **********************************************\n", $time());


		///////////////////////////////////////////////////////////////////////////////
	endtask

	task linkreset_flow_diagram_TX_protocol_RX_SB_MESSAGE();
		$display("[%0t] ****************************************************** LINKRESET Flow Diagram Test Started *******************************************************\n", $time());

		///////////////////////////////////////////////////////////////////////////////////////////////////
		enter_linkreset_trigger_protocol();
		enter_reset_trigger_Protocol();


		repeat (10) @(negedge i_clk); 		// Retrain State

		Active_Entry_Link_initialization(REQS_REQR_RSPS_RSPR,0,1);

		enter_linkreset_trigger_SB_MSG();
		enter_reset_trigger_PHY();
				repeat (10) @(negedge i_clk); 		// Retrain State
				
		Active_Entry_Link_initialization(REQS_REQR_RSPS_RSPR,0,1);

		///////////////////////////////////////////////////////////////////////////////////////////////////



		$display("[%0t] ********************************************* LINKRESET Flow Diagram Test is Completed Successfully **********************************************\n", $time());


	endtask

	initial begin

		global_reset();
		// 	task Active_Entry_Link_initialization (input e_mode mode=REQS_RSPR_REQR_RSPS, input train_entry=0,input protocol_trigger_entry=0);

		Active_Entry_Link_initialization(REQS_RSPR_REQR_RSPS,0,0);
		repeat (10) @(negedge i_clk); 		// Active  State
				global_reset();


		Active_Entry_Link_initialization(REQR_RSPS_REQS_RSPR,0,0);
		repeat (10) @(negedge i_clk); 		// Active  State
				global_reset();


		Active_Entry_Link_initialization(REQS_REQR_RSPS_RSPR,0,0);
		repeat (10) @(negedge i_clk); 		// Active  State
				global_reset();


		Active_Entry_Link_initialization(WAITRX_LPSTATEREQ_ACTIVE_REQS_RSPR_REQR_RSPS,0,0);
		repeat (10) @(negedge i_clk); 		// Active  State


		////// After Active Entry//////////////////

		retrain_flow_diagram_TX_protocol_RX_phy();

		linkerror_flow_diagram_TX_protocol_RX_phy();

		linkreset_flow_diagram_TX_protocol_RX_SB_MESSAGE();


		$display("\n\n******************************************************************************************** ALL TESTS PASSED ********************************************************************************************");

		$stop();

	end

endmodule
