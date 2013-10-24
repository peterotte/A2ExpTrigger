--
-- Peter-Bernd Otte
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;																						
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all; --  for bufg

entity trigger is
	port (
		clock50 : in STD_LOGIC;
		clock100 : in STD_LOGIC;
		clock200 : in STD_LOGIC;
		clock400 : in STD_LOGIC; 
		clock1 : in STD_LOGIC;
		clock0_5 : in STD_LOGIC;
		trig_in : in STD_LOGIC_VECTOR (191 downto 0);		
		trig_out : out STD_LOGIC_VECTOR (63 downto 0);
		nim_in   : in  STD_LOGIC;
		nim_out  : out STD_LOGIC;
		ToScalerOut : out STD_LOGIC_VECTOR(191 downto 0);
		Debug_ActualState_Out : out STD_LOGIC_VECTOR(3 downto 0);
		SC_Scalers_L1Out : out STD_LOGIC_VECTOR(7 downto 0);
		SC_Scalers_L2Out : out STD_LOGIC_VECTOR(7 downto 0);
		led	     : out STD_LOGIC_VECTOR(8 downto 1); -- 8 LEDs onboard
		pgxled   : out STD_LOGIC_VECTOR(8 downto 1); -- 8 LEDs on PIG board
		Global_Reset_After_Power_Up : in std_logic;
--............................. vme interface ....................
		u_ad_reg :in std_logic_vector(11 downto 2);
		u_dat_in :in std_logic_vector(31 downto 0);
		u_data_o :out std_logic_vector(31 downto 0);
		oecsr, ckcsr:in std_logic
	);
end trigger;


architecture RTL of trigger is

	subtype sub_Address is std_logic_vector(11 downto 4);
	constant BASE_TRIG_FIXED : sub_Address 							:= x"f0" ; -- r
	constant TRIG_FIXED_Master : std_logic_vector(31 downto 0)  := x"13102462";

	--Pre L1
	constant BASE_TRIG_PreTriggerMask : sub_Address								:= x"15"; --r/w
	constant BASE_TRIG_PreL1_PreScalerFactor_0 : sub_Address					:= x"16"; --r/w
	constant BASE_TRIG_PreL1_PreScalerFactor_1 : sub_Address					:= x"17"; --r/w
	--Main Section
	constant BASE_TRIG_RMAL1_web : sub_Address									:= x"20"; --r/w
	constant BASE_TRIG_RMAL1_addrb : sub_Address									:= x"21"; --r/w
	constant BASE_TRIG_RMAL1_dinb : sub_Address									:= x"22"; --r/w
	constant BASE_TRIG_RMAL1_doutb : sub_Address									:= x"23"; --r
	constant BASE_TRIG_RMAL2_web : sub_Address									:= x"24"; --r/w
	constant BASE_TRIG_RMAL2_addrb : sub_Address									:= x"25"; --r/w
	constant BASE_TRIG_RMAL2_dinb : sub_Address									:= x"26"; --r/w
	constant BASE_TRIG_RMAL2_doutb : sub_Address									:= x"27"; --r
	constant BASE_TRIG_L12_DataAfterRegister : sub_Address					:= x"2a"; --r
	constant BASE_TRIG_EndSection_Register : sub_Address						:= x"2b"; --r
	constant BASE_TRIG_WidthL1Trigger_Gated : sub_Address						:= x"2c"; --r/w
	constant BASE_TRIG_L1_InternalDelayTime : sub_Address						:= x"2d"; --r/w
	constant BASE_TRIG_L2_InternalDelayTime : sub_Address						:= x"2e"; --r/w
	constant BASE_TRIG_WidthL1Trigger2_Gated : sub_Address					:= x"2f"; --r/w
	
	constant BASE_TRIG_L1_PreScalerFactor_0 : sub_Address						:= x"30"; --r/w
	constant BASE_TRIG_L1_PreScalerFactor_1 : sub_Address						:= x"31"; --r/w
	constant BASE_TRIG_L1_PreScalerFactor_2 : sub_Address						:= x"32"; --r/w
	constant BASE_TRIG_L1_PreScalerFactor_3 : sub_Address						:= x"33"; --r/w
	constant BASE_TRIG_L2_PreScalerFactor_0 : sub_Address						:= x"34"; --r/w
	constant BASE_TRIG_L2_PreScalerFactor_1 : sub_Address						:= x"35"; --r/w
	constant BASE_TRIG_L2_PreScalerFactor_2 : sub_Address						:= x"36"; --r/w
	constant BASE_TRIG_L2_PreScalerFactor_3 : sub_Address						:= x"37"; --r/w

	--Readout / Total Dead Time
	constant BASE_TRIG_SelectIncludeCPU : sub_Address							:= x"40"; --r/w
	constant BASE_TRIG_DisableTriggerSignal : sub_Address						:= x"41"; --r/w
	constant BASE_TRIG_EnableTAPSSignal : sub_Address							:= x"42"; --r/w
	constant BASE_TRIG_ResetVMEbusCPUsState : sub_Address 					:= x"43"; --w   <-- write a 0x1 to it
	constant BASE_TRIG_PerformSignalOnMasterReset : sub_Address 			:= x"44"; --w   <-- write a 0x1 to it
	constant BASE_TRIG_SingleVMECPUsReadoutComplete_Local : sub_Address 	:= x"45"; --w  <-- acts like ACK of CBD
	constant BASE_TRIG_ExpTrigger_Delayed_Local : sub_Address 				:= x"46"; --r/w  <-- acts like INT of CBD
	constant BASE_TRIG_OutputForARTCS : sub_Address 							:= x"47"; --w  <-- acts like ouptut registers for TCS
	
	--Delay: CPU Interrupt Signals / FastClear
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_0 : sub_Address		:= x"50"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_1 : sub_Address		:= x"51"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_2 : sub_Address		:= x"52"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_3 : sub_Address		:= x"53"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_4 : sub_Address		:= x"54"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_5 : sub_Address		:= x"55"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_6 : sub_Address		:= x"56"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_7 : sub_Address		:= x"57"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_8 : sub_Address		:= x"58"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_9 : sub_Address		:= x"59"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_10 : sub_Address		:= x"5A"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_11 : sub_Address		:= x"5b"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_12 : sub_Address		:= x"5c"; --r/w
	constant BASE_TRIG_CPUInterruptSignalsDelayTime_13 : sub_Address		:= x"5d"; --r/w
	constant BASE_TRIG_FastClearDelayTime : sub_Address						:= x"5f"; --r/w
	
	--debug
	constant BASE_TRIG_Debug_ActualState : sub_Address							:= x"e0"; --r
	constant BASE_TRIG_SelectedDebugInput_1 : sub_Address						:= x"e1"; --r/w
	constant BASE_TRIG_SelectedDebugInput_2 : sub_Address						:= x"e2"; --r/w
	constant BASE_TRIG_SelectedDebugInput_3 : sub_Address						:= x"e3"; --r/w
	constant BASE_TRIG_SelectedDebugInput_4 : sub_Address						:= x"e4"; --r/w
	
	constant BASE_TRIG_Oszi_AddressReadout : sub_Address						:= x"ef"; --r/w
	constant BASE_TRIG_Oszi_DataOut_0 : sub_Address								:= x"d0"; --r
	constant BASE_TRIG_Oszi_DataOut_1 : sub_Address								:= x"d1"; --r
	constant BASE_TRIG_Oszi_DataOut_2 : sub_Address								:= x"d2"; --r
	constant BASE_TRIG_Oszi_DataOut_3 : sub_Address								:= x"d3"; --r
	constant BASE_TRIG_Oszi_DataOut_4 : sub_Address								:= x"d4"; --r
	constant BASE_TRIG_Oszi_DataOut_5 : sub_Address								:= x"d5"; --r
	constant BASE_TRIG_Oszi_DataOut_6 : sub_Address								:= x"d6"; --r
	constant BASE_TRIG_Oszi_DataOut_7 : sub_Address								:= x"d7"; --r
	

	--Event ID
	constant BASE_TRIG_EventID_SetUserEventID : sub_Address					:= x"a0"; --r
	constant BASE_TRIG_EventID_ResetSending : sub_Address						:= x"a1"; --w  --write 1 to it to reset
	constant BASE_TRIG_EventID_ReadStatus : sub_Address						:= x"a2"; --r  



	------------------------------------------------------------------------------	

	COMPONENT HelicityBitGenerator
	PORT(
		clock0_5 : IN std_logic;
		clock100 : IN std_logic;          
		HelicityOutput : OUT std_logic;
		InhibitOut : OUT std_logic;
		debug_out : out std_logic_vector(3 downto 0)
		);
	END COMPONENT;

	------------------------------------------------------------------------------	
	
	--InputSection
	constant NRawInputs : integer := 16; 
	constant NConditions : integer := 8;
	signal RawL1Triggers : std_logic_VECTOR(NRawInputs-1 downto 0);

	COMPONENT InputSection is
	 Generic (
 		NRawL1Inputs : integer := 16
	 );
    Port ( RawL1Triggers : in  STD_LOGIC_VECTOR (NRawL1Inputs-1 downto 0);
           VetoInput : in  STD_LOGIC;
			  RawL1Triggers_PreScaled : out  STD_LOGIC_VECTOR (NRawL1Inputs-1 downto 0);
           PreTriggerOut : out  STD_LOGIC;
           SelectPreScalerFactor : in  STD_LOGIC_VECTOR (NRawL1Inputs*4-1 downto 0);
			  PreTriggerMask : in std_logic_vector(NRawL1Inputs-1 downto 0);
			  clock : in STD_LOGIC);
	end COMPONENT;
	signal PreL1Trigger : std_logic;
	signal RawL1Triggers_PreScaled : std_logic_vector(NRawInputs-1 downto 0);
	signal PreTriggerMask : std_logic_vector(NRawInputs-1 downto 0);
	signal PreL1_PreScalerFactor : std_logic_vector(NRawInputs*4-1 downto 0);
	

	--MainSection
	--L1
	signal TAPSPulser : std_logic;
	signal TAPSLED1OR, TAPSLED2M2Plus : std_logic;
	attribute keep : string;
	signal L1Busy : std_logic;
	signal PreL1Trigger_Stored, PreL1Trigger_Stored_ExtDelayed, Inter_Delayed : std_logic;
	signal L1_AllORRawTriggers_IntDelayed, L2_AllORRawTriggers_IntDelayed : std_logic;
	attribute keep of PreL1Trigger_Stored_ExtDelayed: signal is "TRUE";
	attribute keep of PreL1Trigger_Stored: signal is "TRUE";
	signal L1Trigger, L1Trigger_Gated, L1Trigger2_Gated : std_logic;
	signal WidthL1Trigger_Gated, WidthL1Trigger2_Gated : std_logic_vector(15 downto 0) := x"0001";
	signal ImmediateReset : std_logic;
	signal ConditionsOutL1 : STD_LOGIC_VECTOR (NConditions-1 downto 0);
	signal L1_PreScalerFactor : STD_LOGIC_VECTOR (NConditions*16-1 downto 0) := (others => '1');
	signal L1_DataAfterRegister : STD_LOGIC_VECTOR (NRawInputs-1 downto 0);
	signal L1_InternalDelayTime, L2_InternalDelayTime : std_logic_vector(15 downto 0) := x"0001";

	COMPONENT TriggerLevelSection 
		Generic (
			NRawInputs : integer := 16; --if this is changed from default values, the IP cores also need to be updated
			NConditions : integer := 8 --if this is changed from default values, the IP cores also need to be updated
			--InternalDelayTime : integer := 2
		);
		Port ( 
			RawTriggers : in STD_LOGIC_VECTOR (NRawInputs-1 downto 0);
			AllORRawTriggers : in std_logic;
			AllORRawTriggers_Stored : out std_logic;
			AllORRawTriggers_Stored_ExtDelayed : in std_logic;
			ConditionsOut : out std_logic_vector(NConditions-1 downto 0);
			AcceptSignal : out std_logic;
			RejectSignal : out std_logic;
			MasterReset : in std_logic;
			Busy : out std_logic;
			
			--For debug resasons
			AllORRawTriggers_IntDelayed : out std_logic;
			RawTriggers_AfterRegister : out STD_LOGIC_VECTOR (NRawInputs-1 downto 0);
			RawTriggers_AfterRAM : out STD_LOGIC_VECTOR (NConditions-1 downto 0);
			RawTriggers_AfterPreScaler : out STD_LOGIC_VECTOR (NConditions-1 downto 0);
			TriggerSignal : out std_logic;
			
			--VME
			SelectPreScalerFactor : in STD_LOGIC_VECTOR (NConditions*16-1 downto 0);
			SelectInternalDelayTime : in STD_LOGIC_VECTOR (15 downto 0);
			--VME RAM
			RMA_web: IN std_logic_VECTOR(0 downto 0);
			RMA_addrb: IN std_logic_VECTOR(NRawInputs-1 downto 0);
			RMA_dinb: IN std_logic_VECTOR(NConditions-1 downto 0);
			RMA_doutb: OUT std_logic_VECTOR(NConditions-1 downto 0);

			clock200 : in std_logic;
			clock50 : in std_logic
		);
	end COMPONENT;
	signal RMAL1_web, RMAL2_web : std_logic_VECTOR(0 downto 0);
	signal RMAL1_addrb, RMAL2_addrb : std_logic_VECTOR(NRawInputs-1 downto 0);
	signal RMAL1_dinb, RMAL1_doutb, RMAL2_dinb, RMAL2_doutb : std_logic_VECTOR(NConditions-1 downto 0);
	
	--L2
	signal CoplanarityL2 : std_logic_vector(1 downto 0);
	signal Multiplicity0123Many : std_logic_vector(4 downto 0);
	signal L2Busy : std_logic;
	signal RawL2Triggers : std_logic_VECTOR(NRawInputs-1 downto 0);
	signal L1Trigger_Stored, L1Trigger_Stored_ExtDelayed : std_logic;
	attribute keep of L1Trigger_Stored: signal is "TRUE";
	attribute keep of L1Trigger_Stored_ExtDelayed: signal is "TRUE";
	signal ConditionsOutL2 : STD_LOGIC_VECTOR (NConditions-1 downto 0);
	signal L2Trigger, FastClear, FastClear_Delayed : std_logic;
	signal L2_PreScalerFactor : STD_LOGIC_VECTOR (NConditions*16-1 downto 0) := (others => '1');
	signal L2_DataAfterRegister : STD_LOGIC_VECTOR (NRawInputs-1 downto 0);

	--Delay of FastClear
	signal FastClearDelayTime : std_logic_vector(15 downto 0);

	--L1 Trigger Signal to PID
	signal L1Trigger_Gated_Reset : std_logic;
	component PreciseGateByCounterVariable
    Port ( Input : in  STD_LOGIC;
           Output : out  STD_LOGIC; -- 20ns deadtime after pulse
			  DeadOut : out  STD_LOGIC; --during reset (20ns) is this signal = '1'
			  Inhibit : in std_logic; -- normal operation = '0'. Not sensitive to input edge if = '1' (inhibit)
			  Reset : in std_logic;
  				WIDTH : in std_logic_vector(15 downto 0) := x"0001"; 
           clock : in  STD_LOGIC);
	end component;
	
	--EndSection
	signal EndSection_Register : std_logic_vector(NConditions-1 downto 0);
	COMPONENT EndSection
		Generic (
			NConditions : integer := 8 --if this is changed from default values, the IP cores also need to be updated
		);
		Port ( 
			ConditionsIn : in std_logic_vector(NConditions-1 downto 0);
			ExperimentTrigger : in std_logic;
			MasterReset : in std_logic;
			--VME Register
			Register_dout: OUT std_logic_VECTOR(NConditions-1 downto 0);

			clock100 : in std_logic
		);
	end COMPONENT;

	-----------------------------------------------------------------------------
	-- To save VME output registers
	signal ckcsr_delayed : std_logic;

	-----------------------------------------------------------------------------

	-----------------------------------------------------------------------------
	-- All CPUs Readout
	signal ExperimentTrigger : std_logic;
	constant NVMEbusChs : integer := 14;
	signal SingleVMECPUsReadoutComplete, SelectIncludeCPU : std_logic_vector(NVMEbusChs-1 downto 0);
	signal BusyAllCPUs_Signal : std_logic;
	signal ReadoutCompleteReset_Signal : std_logic;
	signal ResetVMEbusCPUsState : std_logic;
	signal PerformSignalOnMasterReset : std_logic;
	signal SingleVMECPUsBusy : std_logic_vector(NVMEbusChs-1 downto 0);
	--For VMECPU AcquRoot
	signal SingleVMECPUsReadoutComplete_Local : std_logic; --needs to be w via VME
	signal ExpTrigger_Delayed_Local : std_logic; --needs r via VME
	signal OutputForARTCS, OutputForARTCS_Saved, OutputForARTCS_Saved2, OutputForARTCS_Gated : std_logic_vector(1 downto 0); --needs w via VME

	COMPONENT AllCPUs
		generic (
			NVMEbusChs : integer
		);
    Port ( ExpTriggerIn : in  STD_LOGIC;
				Interrupt_Delayed : out std_logic_vector(NVMEbusChs-1 downto 0);
			  SingleVMECPUsReadoutComplete : in  STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
           ReadoutCompleteReset : out  STD_LOGIC;
			  Reset : in std_logic;
			  SingleVMECPUsBusy : out  STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
			  SelectIncludeCPU : in  STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
			  SelectInterruptDelayTimes : in std_logic_vector(NVMEbusChs*16-1 downto 0);
           VMECPUsBusy : out  STD_LOGIC;
			  clock100 : in  std_logic;
			  Debug_Out : out std_logic_vector(NVMEbusChs-1 downto 0));
	end COMPONENT;
	--Delay of Interrupt signals to CPUs
	signal CPUInterruptSignalsDelayTime : std_logic_vector(16*NVMEbusChs-1 downto 0);
	COMPONENT DelayByCounterFixedWidth
		Generic (
			OutputTime : integer := 4
		);
		 Port ( Clock : in  STD_LOGIC;
				  Input : in  STD_LOGIC;
					DelayTime : in STD_LOGIC_VECTOR(15 downto 0);
				  ExternalReset : in std_logic;
				  DelayedOutput : out  STD_LOGIC);
	end COMPONENT;
	signal CPUInterruptSignalsDelayed : std_logic_vector(NVMEbusChs-1 downto 0);


	-- Master Reset
	signal MasterReset : std_logic;
	

	----------------------------------------------------------------------------------
	--Total Dead Time
	signal TotalDeadTime_Signal : std_logic;
	signal DisableTriggerSignal : std_logic := '1';
	signal BusyTAPS, Inter_BusyTAPS : std_logic;
	signal BusyTagger : std_logic;
	signal EnableTAPSSignal : STD_LOGIC;

	COMPONENT BusyChannel
	PORT(
		BusyIn : IN std_logic;
		SelectIn : IN std_logic;          
		BusyOut : OUT std_logic
		);
	END COMPONENT;
	----------------------------------------------------------------------------------


	COMPONENT DebugChSelector
	PORT(
		DebugSignalsIn : IN std_logic_vector(479 downto 0);
		SelectedInput : IN std_logic_vector(8 downto 0);          
		SelectedOutput : OUT std_logic
		);
	END COMPONENT;

	------------------------------------------------------------------------------
	
	component Pulser
		generic (
			DividingPower : integer;
			OutputWidth : integer
			);
		 Port ( clock : in  STD_LOGIC;
				  Sig_Out : out  STD_LOGIC);
	end component;
	
	COMPONENT OsziCh
    Port ( clockRAMA : in  STD_LOGIC;
			  clockRAMB : in  STD_LOGIC;
           InputSignals : in  STD_LOGIC_VECTOR (255 downto 0);
           AddressReadout : in  STD_LOGIC_VECTOR (9 downto 0);
           DataOut : out  STD_LOGIC_VECTOR (255 downto 0);
           TriggerSignalIn : in  STD_LOGIC;
			  Reset : in std_logic;
			  debug_out : out std_logic_vector(4 downto 0));
	END COMPONENT;

	
	------------------------------------------------------------------------------
	
	signal PulserOutput : std_logic;
	
	-- For all components
	constant NDebugSignalOutputs : integer := 4;
	signal DebugSignals : std_logic_vector(479 downto 0);
	signal SelectedDebugInput : std_logic_vector(9*NDebugSignalOutputs-1 downto 0);
	signal Debug_ActualState : std_logic_vector(NDebugSignalOutputs-1 downto 0);
		
	
	--inst Oszi test
	signal Oszi_AddressReadout : std_logic_vector(9 downto 0);
	signal Oszi_DataOut : std_logic_vector(255 downto 0);
	signal Oszi_Debug_Out : std_logic_vector(4 downto 0);
	
	----------------------------------------------------------------------------------------------
	-- EventID Sender
	signal EventID_UserEventID : std_logic_vector(31 downto 0);
	signal EventID_ResetSenderCounter : std_logic;
	signal EventID_StatusCounter : std_logic_vector(7 downto 0);
	signal EventID_OutputPin : std_logic;

	COMPONENT EventIDSender
	PORT(
		UserEventID : IN std_logic_vector(31 downto 0);
		ResetSenderCounter : IN std_logic;
		clock50 : IN std_logic;          
		StatusCounter : OUT std_logic_vector(7 downto 0);
		OutputPin : OUT std_logic
		);
	END COMPONENT;
	----------------------------------------------------------------------------------------------

	signal SignalsToCountingHouse, SignalsToCountingHouse_Gated : std_logic_vector(10 downto 1);
	
	COMPONENT delay_by_shiftregister
		Generic (
			DELAY : integer
		);
		 Port ( CLK : in  STD_LOGIC;
				  SIG_IN : in  STD_LOGIC;
				  DELAY_OUT : out  STD_LOGIC);
	end COMPONENT;

	signal CBHighESum, CBHighESum_Delayed : std_logic;
	
	COMPONENT gate_by_shiftreg
		Generic (
			WIDTH : integer
		);
		 Port ( CLK : in STD_LOGIC;
				  SIG_IN : in  STD_LOGIC;
				  GATE_OUT : out  STD_LOGIC);
	end COMPONENT;

		
begin

	----------------------------------------------------------------------------------------------
	-- EventID Sender

	Inst_EventIDSender: EventIDSender PORT MAP(
		StatusCounter => EventID_StatusCounter,
		UserEventID => EventID_UserEventID,
		ResetSenderCounter => EventID_ResetSenderCounter,
		OutputPin => EventID_OutputPin,
		clock50 => clock50
	);
	----------------------------------------------------------------------------------------------


	----------------------------------------------------------------------------------------------
	-- Oszi
	DebugSignals(479 downto 256) <= x"00000000"&trig_in(191 downto 0);
	DebugSignals(255 downto 247) <= Oszi_Debug_Out&Debug_ActualState;
	
	Inst_OsziCh: OsziCh PORT MAP(
		clockRAMA => clock100,
		clockRAMB => clock50,
		InputSignals => DebugSignals(255 downto 0),
		AddressReadout => Oszi_AddressReadout,
		DataOut => Oszi_DataOut,
		TriggerSignalIn => Debug_ActualState(0),
		Reset => PerformSignalOnMasterReset, --0x44
		debug_out => Oszi_Debug_Out
	);
	
	------------------------------------------------------------------------------------------------
	-- Generate Pulser
	PedestalPulser : Pulser Generic Map (
		DividingPower => 11, 
		OutputWidth => 10) Port Map (
		clock => clock50, 
		Sig_Out => PulserOutput); -- 11 = 50MHz/2**(11+1) = 12.2kHz
	--trig_out(28) <= clock0_5; ---needs to be changed to other output
	--trig_out(29) <= clock1; --1MHz Clock  ---needs to be changed to other output

	ToScalerOut(31 downto 0) <= EventID_StatusCounter(7 downto 0) & trig_in(31-8 downto 0);
	
	ToScalerOut(175 downto 32) <= trig_in(175 downto 32);

	Inst_CPUsLiveTime_Scalers : for i in 0 to NVMEbusChs-1 generate begin
		ToScalerOut(176+i) <= clock1 when SingleVMECPUsBusy(i) = '0' else '0';
	end generate;
	ToScalerOut(190) <= clock1 when TotalDeadTime_Signal = '0' else '0';
	ToScalerOut(191) <= clock1;
	------------------------------------------------------------------------------------------------


	------------------------------------------------------------------------------------------------
	-- MainSection: InputSection
   TAPSLED1OR <= '1' when trig_in(2*32+5 downto 2*32+0) /= "0" else '0'; --ch5..0: LED 1 Sector ORs
	------------------------------------------------------------------------------------------------
		
	
	------------------------------------------------------------------------------------------------
	-- MainSection: InputSection
	TAPSPulser <= trig_in(2*32+30); --IN3, ch30
	TAPSLED2M2Plus <= trig_in(2*32+29); --IN3, ch29
	
	RawL1Triggers <= TAPSPulser&PulserOutput& TAPSLED2M2Plus&TAPSLED1OR& Debug_ActualState(1 downto 0) & trig_in(9 downto 0);    -- IN1 ch0..11 --NRawInputs

	Inst_InputSection : InputSection GENERIC MAP (
		NRawL1Inputs => NRawInputs
	 )
    Port MAP ( 
		RawL1Triggers => RawL1Triggers,
		VetoInput => TotalDeadTime_Signal,
		RawL1Triggers_PreScaled => RawL1Triggers_PreScaled,
		PreTriggerOut => PreL1Trigger,
		SelectPreScalerFactor => PreL1_PreScalerFactor,
		PreTriggerMask => PreTriggerMask,
		clock => clock200
	);
	DebugSignals(15 downto 0) <= RawL1Triggers_PreScaled;
	------------------------------------------------------------------------------------------------
	
	
	------------------------------------------------------------------------------------------------
	-- MainSection: TLS L1
	--
	trig_out(30) <= PreL1Trigger_Stored;
	PreL1Trigger_Stored_ExtDelayed <= trig_in(30); --PreL1Trigger delayed by 6ns cable

--	Inst_delayL1Stored_by_shiftregister: delay_by_shiftregister 
--		GENERIC MAP (
--			DELAY => 24 --60/2.5
--		)
--		PORT MAP(
--			CLK => clock400,
--			SIG_IN => PreL1Trigger_Stored,
--			DELAY_OUT => PreL1Trigger_Stored_ExtDelayed
--	);


	-- either delayed with cable or internally
	-- IMPORTANT: switch on line in ucf file!
	--Inst_DelayByCounter_L1 : DelayByCounter GENERIC MAP(DelayTime => 24,OutputTime => 12 )
	--   Port MAP ( Clock => clock400, Input => PreL1Trigger_Stored, DelayedOutput => PreL1Trigger_Stored_ExtDelayed );
	
	
	-- TLS L1
	Inst_TLSL1: TriggerLevelSection GENERIC MAP (
			NRawInputs => NRawInputs, --if this is changed from default values, the IP cores also need to be updated
			NConditions => NConditions --if this is changed from default values, the IP cores also need to be updated
			--InternalDelayTime => 2 -- Signals from Prescaler need to have length > InternalDelayTime*clock + jitter
		)
		Port MAP ( 
			RawTriggers => RawL1Triggers_PreScaled,
			AllORRawTriggers => PreL1Trigger,
			AllORRawTriggers_Stored => PreL1Trigger_Stored,
			AllORRawTriggers_Stored_ExtDelayed => PreL1Trigger_Stored_ExtDelayed,
			ConditionsOut => ConditionsOutL1,
			AcceptSignal => L1Trigger,
			RejectSignal => ImmediateReset,
			MasterReset => MasterReset, --trig_in(18),
			Busy => L1Busy,
			--For debug resasons
			AllORRawTriggers_IntDelayed => L1_AllORRawTriggers_IntDelayed,
			RawTriggers_AfterRegister => L1_DataAfterRegister,
			RawTriggers_AfterRAM => DebugSignals(43 downto 36),
			RawTriggers_AfterPreScaler => DebugSignals(51 downto 44),
			TriggerSignal => DebugSignals(52),
			--VME
			SelectPreScalerFactor => L1_PreScalerFactor,
			SelectInternalDelayTime => L1_InternalDelayTime,
			--VME RAM
			RMA_web => RMAL1_web,
			RMA_addrb => RMAL1_addrb,
			RMA_dinb => RMAL1_dinb,
			RMA_doutb => RMAL1_doutb,
			--
			clock200 => clock200, --clock100
			clock50 => clock50
		);
	DebugSignals(18) <= L1_AllORRawTriggers_IntDelayed;
	DebugSignals(35 downto 20) <= L1_DataAfterRegister;
	DebugSignals(17) <= PreL1Trigger_Stored;
	DebugSignals(19) <= PreL1Trigger_Stored_ExtDelayed;
	DebugSignals(53) <= L1Trigger;
	DebugSignals(54) <= ImmediateReset;
	DebugSignals(62 downto 55) <= ConditionsOutL1;
	SC_Scalers_L1Out <= ConditionsOutL1;
	
	nim_out <= PreL1Trigger_Stored;
	
	-- Gate of L1 Trigger Signal to PID QDC
	L1Trigger_Gated_Reset <= trig_in(28) or MasterReset;
	GateGen_L1Trigger_Gated: PreciseGateByCounterVariable
		Port MAP ( Input => L1Trigger,
			Output => L1Trigger_Gated,
			DeadOut => open,
			Inhibit => '0',
			Reset => L1Trigger_Gated_Reset,
			WIDTH => WidthL1Trigger_Gated,
         clock => clock200);
	DebugSignals(63) <= L1Trigger_Gated;
	-- Gate of L1 Trigger Signal to Ref TDC
	GateGen_L1Trigger2_Gated: PreciseGateByCounterVariable
		Port MAP ( Input => L1Trigger,
			Output => L1Trigger2_Gated,
			DeadOut => open,
			Inhibit => '0',
			Reset => MasterReset,
			WIDTH => WidthL1Trigger2_Gated,
         clock => clock200);
	DebugSignals(64) <= L1Trigger2_Gated;
	------------------------------------------------------------------------------------------------


	------------------------------------------------------------------------------------------------
	-- MainSection: TLS L2
	--
	CBHighESum <= trig_in(12); --L2, Ch7
	HighESumDelay: delay_by_shiftregister Generic map ( DELAY => 20)
		 Port map ( CLK => clock200, SIG_IN => CBHighESum, DELAY_OUT => CBHighESum_Delayed );
	
	CoplanarityL2 <= trig_in(32+1)&trig_in(32+0); --IN2, ch1,0
	Multiplicity0123Many <= trig_in(23+32*3)&trig_in(18+32*3)&trig_in(17+32*3)&trig_in(16+32*3)&trig_in(15+32*3); --INOUT1, ch 23,18,17,16,15
	
	RawL2Triggers <= CBHighESum_Delayed&CoplanarityL2& Multiplicity0123Many & ConditionsOutL1; 	--IN1
	--RawL2Triggers <= trig_in(32+7 downto 32) & ConditionsOutL1; --For debugging the co planarity trigger
	DebugSignals(85 downto 78) <= RawL2Triggers(15 downto 8);

	trig_out(31) <= L1Trigger_Stored;
	L1Trigger_Stored_ExtDelayed <= trig_in(31); --PreL1Trigger delayed by 6ns delay cable

	-- either delayed with cable or internally
	-- IMPORTANT: switch on line in ucf file!
	--	Inst_DelayByCounter_L2 : DelayByCounter GENERIC MAP(DelayTime => 20,OutputTime => 12 )
	--    Port MAP ( Clock => clock400, Input => L1Trigger, DelayedOutput => L1Trigger_ExtDelayed );
	
--	Inst_delayL2Stored_by_shiftregister: delay_by_shiftregister 
--		GENERIC MAP (
--			DELAY => 80 --200/2.5
--		)
--		PORT MAP(
--			CLK => clock400,
--			SIG_IN => L1Trigger_Stored,
--			DELAY_OUT => L1Trigger_Stored_ExtDelayed
--	);


	
	-- TLS L2
	Inst_TLSL2: TriggerLevelSection GENERIC MAP (
			NRawInputs => NRawInputs, --if this is changed from default values, the IP cores also need to be updated
			NConditions => NConditions --if this is changed from default values, the IP cores also need to be updated
			--InternalDelayTime => 2
		)
		Port MAP ( 
			RawTriggers => RawL2Triggers,
			AllORRawTriggers => L1Trigger,
			AllORRawTriggers_Stored => L1Trigger_Stored, 
			AllORRawTriggers_Stored_ExtDelayed => L1Trigger_Stored_ExtDelayed,
			ConditionsOut => ConditionsOutL2,
			AcceptSignal => L2Trigger,
			RejectSignal => FastClear,
			MasterReset => MasterReset, --trig_in(18),
			Busy => L2Busy,
			--For debug resasons
			AllORRawTriggers_IntDelayed => L2_AllORRawTriggers_IntDelayed,
			RawTriggers_AfterRegister => L2_DataAfterRegister,
			RawTriggers_AfterRAM => DebugSignals(112 downto 105),
			RawTriggers_AfterPreScaler => DebugSignals(120 downto 113),
			TriggerSignal => DebugSignals(121),
			--VME
			SelectPreScalerFactor => L2_PreScalerFactor,
			SelectInternalDelayTime => L2_InternalDelayTime,
			--VME RAM
			RMA_web => RMAL2_web,
			RMA_addrb => RMAL2_addrb,
			RMA_dinb => RMAL2_dinb,
			RMA_doutb => RMAL2_doutb,
			--
			clock200 => clock200,
			clock50 => clock50
		);
	DebugSignals(87) <= L2_AllORRawTriggers_IntDelayed;
	DebugSignals(104 downto 89) <= L2_DataAfterRegister;
	DebugSignals(86) <= L1Trigger_Stored;
	DebugSignals(88) <= L1Trigger_Stored_ExtDelayed;
	DebugSignals(122) <= L2Trigger;
	DebugSignals(123) <= FastClear;
	DebugSignals(131 downto 124) <= ConditionsOutL2;
	SC_Scalers_L2Out <= ConditionsOutL2;
	ExperimentTrigger <= L2Trigger;
	
	-- Delay of FastClear signal
	Inst_DelayFastClear: DelayByCounterFixedWidth
		Generic MAP (
			OutputTime => 3
		)
		 Port MAP ( Clock => clock100,
				  Input => FastClear,
					DelayTime => FastClearDelayTime,
				  ExternalReset => MasterReset,
				  DelayedOutput => FastClear_Delayed);
	DebugSignals(132) <= FastClear_Delayed;
	------------------------------------------------------------------------------------------------


	------------------------------------------------------------------------------------------------
	-- MainSection: EndSection
	Inst_EndSection: EndSection Generic MAP (NConditions => 8 )
		Port MAP ( 
			ConditionsIn => ConditionsOutL2,
			ExperimentTrigger => L2Trigger,
			MasterReset => MasterReset, --trig_in(18),
			Register_dout => EndSection_Register,
			clock100 => clock200
		);
	DebugSignals(140 downto 133) <= EndSection_Register;
	------------------------------------------------------------------------------------------------
	
	
	------------------------------------------------------------------------------------------------
	--This is used for the case, the trigger comes on the tagger side in use
--	Inst_HelicityBitGenerator: HelicityBitGenerator PORT MAP(
--		clock0_5 => clock0_5,
--		clock100 => clock100,
--		HelicityOutput => trig_out(16),
--		InhibitOut => trig_out(17),
--		debug_out => open
--	);
	------------------------------------------------------------------------------------------------
	
	------------------------------------------------------------------------------------------------
	-- OUT1 and ExpTrigger_Delayed_Local
	trig_out(0) <= L1Trigger;
	trig_out(1) <= L1Trigger_Gated;
	trig_out(2) <= ExperimentTrigger; --for TCS
	trig_out(3) <= L1Trigger2_Gated;
	trig_out(10 downto 4) <= (10 downto 4 => '0');
	trig_out(11) <= ExperimentTrigger; --for TAPS
	trig_out(12) <= L1Trigger;
	trig_out(13) <= MasterReset;
	
	
	
	SignalsToCountingHouse(1) <= '0'; --not connected to Counting house at the moment
	SignalsToCountingHouse(2) <= '0'; --not connected to Counting house at the moment 
	SignalsToCountingHouse(3) <= RawL1Triggers(0); --Esum
	SignalsToCountingHouse(4) <= FastClear; --fast clear
	SignalsToCountingHouse(5) <= Debug_ActualState(0); --Debug_ActualState(0)
	SignalsToCountingHouse(6) <= Debug_ActualState(1); --Debug_ActualState(1)
	SignalsToCountingHouse(7) <= '1' when Multiplicity0123Many(4 downto 1) /= "0" else '0'; --M1 or M2 or M3 or M4+
	SignalsToCountingHouse(8) <= CoplanarityL2(0); --Copl
	SignalsToCountingHouse(9) <= trig_in(3*32+31); --CB OR from Multiplcitiy Trigger
	SignalsToCountingHouse(10) <= clock1 when TotalDeadTime_Signal = '0' else '0'; --LiveTime Pulser;
	
	GateForCoutinghouse: for i in 1 to 10 generate
		CHGate: gate_by_shiftreg Generic map ( WIDTH => 10)
		 Port map ( CLK=> clock100, SIG_IN => SignalsToCountingHouse(i), 
			GATE_OUT => SignalsToCountingHouse_Gated(i));
	end generate;

	trig_out(19 downto 14) <= SignalsToCountingHouse_Gated(8 downto 3);

	OutputForARTCS_Saved2 <= OutputForARTCS_Saved when ckcsr_delayed = '1' else "00";
   TCSGates: for i in 0 to 1 generate
		TCSGate: gate_by_shiftreg Generic map ( WIDTH => 20)
		 Port map ( CLK=> clock100, SIG_IN => OutputForARTCS_Saved2(i), GATE_OUT => OutputForARTCS_Gated(i));
	end generate;
--	trig_out(14) <= ckcsr;
--	trig_out(15) <= ckcsr_delayed;
--	trig_out(17 downto 16) <= OutputForARTCS_Gated;
--	trig_out(19 downto 18) <= OutputForARTCS_Saved;
	trig_out(21 downto 20) <= OutputForARTCS_Gated;
	trig_out(23 downto 22) <= FastClear&FastClear;
	trig_out(25 downto 24) <= SignalsToCountingHouse_Gated(10 downto 9);


	trig_out(32+12 downto 32+0) <= CPUInterruptSignalsDelayed(12 downto 0);
	ExpTrigger_Delayed_Local <= CPUInterruptSignalsDelayed(13);
	trig_out(32+31) <= EventID_OutputPin;
	
	------------------------------------------------------------------------------------------------

	
	------------------------------------------------------------------------------------------------
	-- AllCPUs Readout
	SingleVMECPUsReadoutComplete <= SingleVMECPUsReadoutComplete_Local & trig_in(2*32+31) & trig_in(16+(NVMEbusChs-1)-2 downto 16);  --IN 1
			--TAPS busy comes via: IN3, ch31 
	DebugSignals(143+(NVMEbusChs-1) downto 143) <= SingleVMECPUsReadoutComplete;
	
	Inst_AllCPUs: AllCPUs GENERIC MAP(
		NVMEbusChs => NVMEbusChs
	) PORT MAP(
		ExpTriggerIn => ExperimentTrigger,
		Interrupt_Delayed => CPUInterruptSignalsDelayed,
		SingleVMECPUsReadoutComplete => SingleVMECPUsReadoutComplete,
		ReadoutCompleteReset => ReadoutCompleteReset_Signal,
		Reset => ResetVMEbusCPUsState, --for debug reasons, to trigger a Master Reset via VME bus
		SingleVMECPUsBusy => SingleVMECPUsBusy,
		SelectIncludeCPU => SelectIncludeCPU,  --- needs VME write
		SelectInterruptDelayTimes => CPUInterruptSignalsDelayTime, --needs VME read/write
		VMECPUsBusy => BusyAllCPUs_Signal,
		clock100 => clock100,
		Debug_Out => DebugSignals(185+(NVMEbusChs-1) downto 185)
	);
	DebugSignals(157+(NVMEbusChs-1) downto 157) <= SingleVMECPUsBusy;
	DebugSignals(142) <= ReadoutCompleteReset_Signal;
	DebugSignals(141) <= BusyAllCPUs_Signal;
	DebugSignals(171+(NVMEbusChs-1) downto 171) <= CPUInterruptSignalsDelayed;
	------------------------------------------------------------------------------------------------


	------------------------------------------------------------------------------------------------
	-- Master Reset
	MasterReset <= ImmediateReset or FastClear_Delayed or ReadoutCompleteReset_Signal or PerformSignalOnMasterReset;
	DebugSignals(16) <= MasterReset;
	------------------------------------------------------------------------------------------------
	

	------------------------------------------------------------------------------------------------
	-- Total Dead Time
	BusyTAPS <= trig_in(31+2*32); --IN3, ch31
	DebugSignals(68) <= BusyTAPS;
	BusyTagger <= '0'; -- was before 9.9.2013 trig_in(22);
	DebugSignals(69) <= BusyTagger;
	
	Inst_BusyChannel_TAPS: BusyChannel PORT MAP(
		BusyIn => BusyTAPS,
		BusyOut => Inter_BusyTAPS,
		SelectIn => EnableTAPSSignal
	);
	
	TotalDeadTime_Signal <= BusyTagger or L1Busy or L2Busy or 
		BusyAllCPUs_Signal or DisableTriggerSignal or Inter_BusyTAPS or
		L1Trigger_Gated or L1Trigger2_Gated;

	
	DebugSignals(65) <= TotalDeadTime_Signal;
	DebugSignals(66) <= L1Busy;
	DebugSignals(67) <= L2Busy;
	-------------------------------------------------------------------------------------------------


	-------------------------------------------------------------------------------------------------
	-- Debug Selector
	DebugChSelectors: for i in 0 to NDebugSignalOutputs-1 generate
   begin
		Inst_DebugChSelector: DebugChSelector PORT MAP(
			DebugSignalsIn => DebugSignals,
			SelectedInput => SelectedDebugInput((i+1)*9-1 downto i*9),  ---needs VME write
			SelectedOutput => Debug_ActualState(i)
		);
	end generate;
	Debug_ActualState_Out <= Debug_ActualState;
	trig_out(26+NDebugSignalOutputs-1 downto 26) <= Debug_ActualState;
	-------------------------------------------------------------------------------------------------



	------------------------------------------------------------------------------------------------
	-- Switch on corresponding LED if cable is connected
	led(1) <= '0' when (trig_in(31+0*32 downto 0*32) = x"00000000") else '1';
	led(2) <= '0';					
	led(3) <= '0' when (trig_in(31+1*32 downto 1*32) = x"00000000") else '1';
	led(4) <= '0';
	led(5) <= '0' when (trig_in(31+2*32 downto 2*32) = x"00000000") else '1';
	led(6) <= '0';
	pgxled(1) <= '0' when (trig_in(31+3*32 downto 3*32) = x"00000000") else '1';
	pgxled(2) <= '0';
	pgxled(3) <= '0' when (trig_in(31+4*32 downto 4*32) = x"00000000") else '1';
	pgxled(4) <= '1';
	pgxled(5) <= '0' when (trig_in(31+5*32 downto 5*32) = x"00000000") else '1';
	pgxled(6) <= '0';
	led(8 downto 7) <= "00";
	pgxled(8 downto 7) <= (others => '1');
	------------------------------------------------------------------------------------------------
	


	---------------------------------------------------------------------------------------------------------	
	-- Code for VME handling / access
	-- handle read commands from vmebus
	---------------------------------------------------------------------------------------------------------	
	process(clock50, oecsr, u_ad_reg)
	begin
		if (clock50'event and clock50 = '1' and oecsr = '1') then
			u_data_o <= (others => '0');
				
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_FIXED) then u_data_o(31 downto 0) <= TRIG_FIXED_Master; end if;
			--	Pre L1
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreTriggerMask) then 					u_data_o(NRawInputs-1 downto 0) <= PreTriggerMask; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreL1_PreScalerFactor_0) then 		u_data_o(31 downto 0) <= PreL1_PreScalerFactor(31 downto 0); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_PreL1_PreScalerFactor_1) then 		u_data_o(31 downto 0) <= PreL1_PreScalerFactor(63 downto 32); end if;
			--Main Section
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL1_web) then 							u_data_o(0 downto 0) <= RMAL1_web; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL1_addrb) then 						u_data_o(NRawInputs-1 downto 0) <= RMAL1_addrb; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL1_dinb) then 							u_data_o(NConditions-1 downto 0) <= RMAL1_dinb; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL1_doutb) then 						u_data_o(NConditions-1 downto 0) <= RMAL1_doutb; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL2_web) then 							u_data_o(0 downto 0) <= RMAL2_web; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL2_addrb) then 						u_data_o(NRawInputs-1 downto 0) <= RMAL2_addrb; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL2_dinb) then 							u_data_o(NConditions-1 downto 0) <= RMAL2_dinb; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL2_doutb) then 						u_data_o(NConditions-1 downto 0) <= RMAL2_doutb; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_L1_PreScalerFactor_0) then 			u_data_o(31 downto 0) <= L1_PreScalerFactor(31+32*0 downto 0+32*0); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_L1_PreScalerFactor_1) then 			u_data_o(31 downto 0) <= L1_PreScalerFactor(31+32*1 downto 0+32*1); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_L1_PreScalerFactor_2) then 			u_data_o(31 downto 0) <= L1_PreScalerFactor(31+32*2 downto 0+32*2); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_L1_PreScalerFactor_3) then 			u_data_o(31 downto 0) <= L1_PreScalerFactor(31+32*3 downto 0+32*3); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_L2_PreScalerFactor_0) then 			u_data_o(31 downto 0) <= L2_PreScalerFactor(31+32*0 downto 0+32*0); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_L2_PreScalerFactor_1) then 			u_data_o(31 downto 0) <= L2_PreScalerFactor(31+32*1 downto 0+32*1); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_L2_PreScalerFactor_2) then 			u_data_o(31 downto 0) <= L2_PreScalerFactor(31+32*2 downto 0+32*2); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_L2_PreScalerFactor_3) then 			u_data_o(31 downto 0) <= L2_PreScalerFactor(31+32*3 downto 0+32*3); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_L12_DataAfterRegister) then 			u_data_o(31 downto 0) <= L2_DataAfterRegister&L1_DataAfterRegister; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_EndSection_Register) then 				u_data_o(NConditions-1 downto 0) <= EndSection_Register; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_WidthL1Trigger_Gated) then 			u_data_o(15 downto 0) <= WidthL1Trigger_Gated; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_WidthL1Trigger2_Gated) then 			u_data_o(15 downto 0) <= WidthL1Trigger2_Gated; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_L1_InternalDelayTime) then 			u_data_o(15 downto 0) <= L1_InternalDelayTime; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_L2_InternalDelayTime) then 			u_data_o(15 downto 0) <= L2_InternalDelayTime; end if;
			--Readout / Total Dead Time
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectIncludeCPU) then 					u_data_o(NVMEbusChs-1 downto 0) <= SelectIncludeCPU; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_DisableTriggerSignal) then 			u_data_o(0) <= DisableTriggerSignal; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_EnableTAPSSignal) then 					u_data_o(0) <= EnableTAPSSignal; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_ExpTrigger_Delayed_Local) then 		u_data_o(0) <= ExpTrigger_Delayed_Local; end if;
			--CPU Interrupt Signals Delays / FastClear
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_0) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*0+15 downto 16*0); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_1) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*1+15 downto 16*1); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_2) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*2+15 downto 16*2); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_3) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*3+15 downto 16*3); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_4) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*4+15 downto 16*4); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_5) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*5+15 downto 16*5); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_6) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*6+15 downto 16*6); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_7) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*7+15 downto 16*7); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_8) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*8+15 downto 16*8); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_9) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*9+15 downto 16*9); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_10) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*10+15 downto 16*10); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_11) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*11+15 downto 16*11); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_12) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*12+15 downto 16*12); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_13) then 	u_data_o(15 downto 0) <= CPUInterruptSignalsDelayTime(16*13+15 downto 16*13); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_FastClearDelayTime) then 				u_data_o(15 downto 0) <= FastClearDelayTime; end if;
			--debug
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_1) then 			u_data_o(8 downto 0) <= SelectedDebugInput(9*1-1 downto 9*0); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_2) then 			u_data_o(8 downto 0) <= SelectedDebugInput(9*2-1 downto 9*1); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_3) then 			u_data_o(8 downto 0) <= SelectedDebugInput(9*3-1 downto 9*2); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_4) then 			u_data_o(8 downto 0) <= SelectedDebugInput(9*4-1 downto 9*3); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Debug_ActualState) then 				u_data_o(NDebugSignalOutputs-1 downto 0) <= Debug_ActualState; end if;
			--Oszi
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Oszi_AddressReadout) then 				u_data_o(9 downto 0) <= Oszi_AddressReadout; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Oszi_DataOut_0) then 					u_data_o(31 downto 0) <= Oszi_DataOut(32*1-1 downto 32*0); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Oszi_DataOut_1) then 					u_data_o(31 downto 0) <= Oszi_DataOut(32*2-1 downto 32*1); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Oszi_DataOut_2) then 					u_data_o(31 downto 0) <= Oszi_DataOut(32*3-1 downto 32*2); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Oszi_DataOut_3) then 					u_data_o(31 downto 0) <= Oszi_DataOut(32*4-1 downto 32*3); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Oszi_DataOut_4) then 					u_data_o(31 downto 0) <= Oszi_DataOut(32*5-1 downto 32*4); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Oszi_DataOut_5) then 					u_data_o(31 downto 0) <= Oszi_DataOut(32*6-1 downto 32*5); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Oszi_DataOut_6) then 					u_data_o(31 downto 0) <= Oszi_DataOut(32*7-1 downto 32*6); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Oszi_DataOut_7) then 					u_data_o(31 downto 0) <= Oszi_DataOut(32*8-1 downto 32*7); end if;
			--EventID
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_EventID_SetUserEventID) then 			u_data_o(31 downto 0) <= EventID_UserEventID; end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_EventID_ReadStatus) then 				u_data_o(7 downto 0) <= EventID_StatusCounter; end if;

		end if;
	end process;

	---------------------------------------------------------------------------------------------------------	
	-- Code for VME handling / access
	-- decoder for data registers
	-- handle write commands from vmebus
	---------------------------------------------------------------------------------------------------------	
	Delay_ckcsr: delay_by_shiftregister	Generic map ( DELAY => 6 )
		Port map ( CLK => clock50, SIG_IN => ckcsr, DELAY_OUT => ckcsr_delayed);

	process(clock50)
	begin
		if rising_edge(ckcsr_delayed) then
			OutputForARTCS_Saved <= OutputForARTCS;
		end if;
	end process;

	
	process(clock50, ckcsr, u_ad_reg)
	begin
		if (clock50'event and clock50 = '1') then
			ResetVMEbusCPUsState <= '0';
			PerformSignalOnMasterReset <= '0';
			OutputForARTCS <= "00";
			SingleVMECPUsReadoutComplete_Local <= '0';
			--	Pre L1
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_PreTriggerMask) ) then 					PreTriggerMask <= u_dat_in(NRawInputs-1 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_PreL1_PreScalerFactor_0) ) then 		PreL1_PreScalerFactor(31 downto 0) <= u_dat_in(31 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_PreL1_PreScalerFactor_1) ) then 		PreL1_PreScalerFactor(63 downto 32) <= u_dat_in(31 downto 0); end if;
			--Main Section
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL1_web) ) then 							RMAL1_web <= u_dat_in(0 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL1_addrb) ) then 						RMAL1_addrb <= u_dat_in(NRawInputs-1 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL1_dinb) ) then 						RMAL1_dinb <= u_dat_in(NConditions-1 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL2_web) ) then 							RMAL2_web <= u_dat_in(0 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL2_addrb) ) then 						RMAL2_addrb <= u_dat_in(NRawInputs-1 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_RMAL2_dinb) ) then 						RMAL2_dinb <= u_dat_in(NConditions-1 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_L1_PreScalerFactor_0) ) then 			L1_PreScalerFactor(31+32*0 downto 0+32*0) <= u_dat_in(31 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_L1_PreScalerFactor_1) ) then 			L1_PreScalerFactor(31+32*1 downto 0+32*1) <= u_dat_in(31 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_L1_PreScalerFactor_2) ) then 			L1_PreScalerFactor(31+32*2 downto 0+32*2) <= u_dat_in(31 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_L1_PreScalerFactor_3) ) then 			L1_PreScalerFactor(31+32*3 downto 0+32*3) <= u_dat_in(31 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_L2_PreScalerFactor_0) ) then 			L2_PreScalerFactor(31+32*0 downto 0+32*0) <= u_dat_in(31 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_L2_PreScalerFactor_1) ) then 			L2_PreScalerFactor(31+32*1 downto 0+32*1) <= u_dat_in(31 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_L2_PreScalerFactor_2) ) then 			L2_PreScalerFactor(31+32*2 downto 0+32*2) <= u_dat_in(31 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_L2_PreScalerFactor_3) ) then 			L2_PreScalerFactor(31+32*3 downto 0+32*3) <= u_dat_in(31 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_WidthL1Trigger_Gated) ) then 			WidthL1Trigger_Gated <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_WidthL1Trigger2_Gated) ) then 			WidthL1Trigger2_Gated <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_L1_InternalDelayTime) ) then 			L1_InternalDelayTime <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_L2_InternalDelayTime) ) then 			L2_InternalDelayTime <= u_dat_in(15 downto 0); end if;
			--Readout / Total Dead Time
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectIncludeCPU) ) then 				SelectIncludeCPU <= u_dat_in(NVMEbusChs-1 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_DisableTriggerSignal) ) then 			DisableTriggerSignal <= u_dat_in(0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_EnableTAPSSignal) ) then 				EnableTAPSSignal <= u_dat_in(0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_ResetVMEbusCPUsState) ) then 			ResetVMEbusCPUsState <= u_dat_in(0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_PerformSignalOnMasterReset) ) then 	PerformSignalOnMasterReset <= u_dat_in(0); end if;			
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SingleVMECPUsReadoutComplete_Local) ) then SingleVMECPUsReadoutComplete_Local <= u_dat_in(0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_OutputForARTCS) ) then 					OutputForARTCS <= u_dat_in(1 downto 0); end if;
			--CPUs Interrupt Signal Delay / FastClear
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_0) ) then CPUInterruptSignalsDelayTime(16*0+15 downto 16*0) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_1) ) then CPUInterruptSignalsDelayTime(16*1+15 downto 16*1) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_2) ) then CPUInterruptSignalsDelayTime(16*2+15 downto 16*2) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_3) ) then CPUInterruptSignalsDelayTime(16*3+15 downto 16*3) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_4) ) then CPUInterruptSignalsDelayTime(16*4+15 downto 16*4) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_5) ) then CPUInterruptSignalsDelayTime(16*5+15 downto 16*5) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_6) ) then CPUInterruptSignalsDelayTime(16*6+15 downto 16*6) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_7) ) then CPUInterruptSignalsDelayTime(16*7+15 downto 16*7) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_8) ) then CPUInterruptSignalsDelayTime(16*8+15 downto 16*8) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_9) ) then CPUInterruptSignalsDelayTime(16*9+15 downto 16*9) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_10) ) then CPUInterruptSignalsDelayTime(16*10+15 downto 16*10) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_11) ) then CPUInterruptSignalsDelayTime(16*11+15 downto 16*11) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_12) ) then CPUInterruptSignalsDelayTime(16*12+15 downto 16*12) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_CPUInterruptSignalsDelayTime_13) ) then CPUInterruptSignalsDelayTime(16*13+15 downto 16*13) <= u_dat_in(15 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_FastClearDelayTime) ) then 				FastClearDelayTime <= u_dat_in(15 downto 0); end if;
			--debug
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_1) ) then 			SelectedDebugInput(9*1-1 downto 9*0) <= u_dat_in(8 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_2) ) then 			SelectedDebugInput(9*2-1 downto 9*1) <= u_dat_in(8 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_3) ) then 			SelectedDebugInput(9*3-1 downto 9*2) <= u_dat_in(8 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_4) ) then 			SelectedDebugInput(9*4-1 downto 9*3) <= u_dat_in(8 downto 0); end if;
			--Oszi
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_Oszi_AddressReadout) ) then 			Oszi_AddressReadout <= u_dat_in(9 downto 0); end if;
			--EventID
			EventID_ResetSenderCounter <= '0';
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_EventID_SetUserEventID) ) then 		EventID_UserEventID <= u_dat_in; end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_EventID_ResetSending) ) then 			EventID_ResetSenderCounter <= u_dat_in(0); end if;

		end if;
	end process;


end RTL;
