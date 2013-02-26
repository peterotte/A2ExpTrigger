-- Peter-Bernd Otte
-- 2.4.2012
-- last update: 7.5.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TriggerLevelSection is
	Generic (
		NRawInputs : integer := 16; --if this is changed from default values, the IP cores also need to be updated
		NConditions : integer := 8 --if this is changed from default values, the IP cores also need to be updated
--		InternalDelayTime : integer := 2 --n means delays by (n-1)*clock lengths + 0..1*clock length
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
		SelectPreScalerFactor : in STD_LOGIC_VECTOR (NConditions*16-1 downto 0) := (others => '1');
		SelectInternalDelayTime : in STD_LOGIC_VECTOR (15 downto 0);
		--VME RAM
		RMA_web: IN std_logic_VECTOR(0 downto 0);
		RMA_addrb: IN std_logic_VECTOR(NRawInputs-1 downto 0);
		RMA_dinb: IN std_logic_VECTOR(NConditions-1 downto 0);
		RMA_doutb: OUT std_logic_VECTOR(NConditions-1 downto 0);

		clock200 : in std_logic;
		clock50 : in std_logic
	);
end TriggerLevelSection;

architecture Behavioral of TriggerLevelSection is
	--Delay and Store AllORRawTrigger Signal
	COMPONENT delay_by_shiftregister_Variable
	PORT(
		CLK : IN std_logic;
		SIG_IN : IN std_logic;          
	  DELAY : in std_logic_vector(2 downto 0); 
		DELAY_OUT : OUT std_logic
		);
	END COMPONENT;
	signal Inter_AllORRawTriggers_IntDelayed : std_logic;
	COMPONENT StrobeDelay
    Port ( Enable : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           SignalOut : out  STD_LOGIC;
           Reset : in  STD_LOGIC;
           DelayTime : in  STD_LOGIC_VECTOR (15 downto 0)
			  );
	end COMPONENT;


	COMPONENT SingleBitStorage
   PORT( Data	:	IN	STD_LOGIC; 
          Clock	:	IN	STD_LOGIC; 
          Clear	:	IN	STD_LOGIC; 
          Output	:	OUT	STD_LOGIC;
          CE	:	IN	STD_LOGIC);
   END COMPONENT;
	signal Inter_AllORRawTriggers_Stored : std_logic;

	
	--Register of RawTrigger Signals
	COMPONENT ClockedRegister is
		GENERIC (
			NCh : integer
		);
		Port ( Inputs : in  STD_LOGIC_VECTOR (NCh-1 downto 0);
           Outputs : out  STD_LOGIC_VECTOR (NCh-1 downto 0);
			  ClockedClock : in std_logic;
			  Clock : in std_logic;
           Reset : in  STD_LOGIC);
	end COMPONENT;
	signal Inter_RawTriggers_AfterRegister : STD_LOGIC_VECTOR (NRawInputs-1 downto 0);

	--RAM
	signal Inter_RawTriggers_AfterRAM : STD_LOGIC_VECTOR (NConditions-1 downto 0);
	component RAML1
		port (
			clka: IN std_logic;
			rsta: IN std_logic;
			wea: IN std_logic_VECTOR(0 downto 0);
			addra: IN std_logic_VECTOR(15 downto 0);
			dina: IN std_logic_VECTOR(7 downto 0);
			douta: OUT std_logic_VECTOR(7 downto 0);
			clkb: IN std_logic;
			web: IN std_logic_VECTOR(0 downto 0);
			addrb: IN std_logic_VECTOR(15 downto 0);
			dinb: IN std_logic_VECTOR(7 downto 0);
			doutb: OUT std_logic_VECTOR(7 downto 0));
	end component;
	-- Synplicity black box declaration
	attribute syn_black_box : boolean;
	attribute syn_black_box of RAML1: component is true;


	--PreScaler with Gate generator of RAML1ConditionSignals
	component PreScaler
    generic ( 
				NChLength : integer
			);  
	 Port ( Sig_In : in  STD_LOGIC;
           Sig_Out : out  STD_LOGIC;
           Factor : in  STD_LOGIC_VECTOR (3 downto 0);
			  Inhibit : in std_logic;
			  clock : in std_logic);
	end component;
	signal Inter_RawTriggers_AfterPreScaler : STD_LOGIC_VECTOR (NConditions-1 downto 0);
	
	--MultiFF Clocked
	signal Inter_ConditionsOut : std_logic_vector(NConditions-1 downto 0);
	component MultiFF is --MultiFFClocked
		GENERIC (
			NCh : integer
		);
    Port ( Inputs : in  STD_LOGIC_VECTOR (NCh-1 downto 0);
           Outputs : out  STD_LOGIC_VECTOR (NCh-1 downto 0);
			  --clock : in Std_logic; --necessary for MultiFFClocked
           Reset : in  STD_LOGIC);
	end component;

	--Trigger, Accept und Reject Signal
	signal Inter_TriggerSignal, TriggerSignal_Inv : std_logic;
	
	
	COMPONENT PreScalerGatedFF
	PORT(
		SignalIN : IN std_logic;
		Clock : IN std_logic;
		PrescaleResetValue : IN std_logic_vector(15 downto 0);
		Reset : IN std_logic;          
		SignalOut : OUT std_logic;
		Debug_InputChange : OUT std_logic
		);
	END COMPONENT;

	
begin
	--Store element for incoming Trigger signal
	Inst_StoreTriggerSignal: SingleBitStorage PORT MAP(
		Data => '1', 
		Clock => AllORRawTriggers, 
		Clear => MasterReset, 
		Output => Inter_AllORRawTriggers_Stored,
		CE => '1'
   );
	AllORRawTriggers_Stored <= Inter_AllORRawTriggers_Stored;

	--Internal Delay before Register
--	Inst_Delay_AllORRawTriggers: delay_by_shiftregister 
--		GENERIC MAP ( DELAY => InternalDelayTime )
--		PORT MAP(
--			CLK => clock200,
--			SIG_IN => Inter_AllORRawTriggers_Stored,
--			DELAY_OUT => Inter_AllORRawTriggers_IntDelayed
--	);
--	Delay_AllORRawTriggers: delay_by_shiftregister_Variable --commented out on 31.8.2012
--		PORT MAP(
--			CLK => clock200,
--			SIG_IN => Inter_AllORRawTriggers_Stored,
--			DELAY => SelectInternalDelayTime,
--			DELAY_OUT => Inter_AllORRawTriggers_IntDelayed
--	);
	StrobeDelay_1 : StrobeDelay Port MAP ( --new since 31.8.2012
		Enable => Inter_AllORRawTriggers_Stored,
      clock => clock200,
      SignalOut => Inter_AllORRawTriggers_IntDelayed,
      Reset => MasterReset,
      DelayTime => SelectInternalDelayTime
	);

	
	AllORRawTriggers_IntDelayed <= Inter_AllORRawTriggers_IntDelayed;


	--Register of RawTrigger Signals
	Inst_Register: ClockedRegister GENERIC MAP ( NCh => NRawInputs )
		PORT MAP(
		Inputs => RawTriggers,
		Outputs => Inter_RawTriggers_AfterRegister,
		ClockedClock => Inter_AllORRawTriggers_IntDelayed,
		Clock => clock200,
		Reset => MasterReset
	);
	RawTriggers_AfterRegister <= Inter_RawTriggers_AfterRegister;

	--RAML1
	Inst_RAML1 : RAML1
		port map (
			clka => clock200,
			rsta => '0',
			wea => "0",
			addra => Inter_RawTriggers_AfterRegister,
			dina => (others => '0'),
			douta => Inter_RawTriggers_AfterRAM,
			clkb => clock50,
			web => RMA_web,
			addrb => RMA_addrb,
			dinb => RMA_dinb,
			doutb => RMA_doutb);
	RawTriggers_AfterRAM <= Inter_RawTriggers_AfterRAM;

	
--	--PreScaler with Gate generator of RAML1ConditionSignals
--	Inst_Prescalers_Conditions: for i in 0 to NConditions-1 generate
--   begin
--		Inst_Prescaler : PreScaler GENERIC MAP (NChLength => 3) 
--			Port MAP ( 
--				Sig_In => Inter_RawTriggers_AfterRAM(i), 
--				Sig_Out => Inter_RawTriggers_AfterPreScaler(i), 
--				Factor => SelectPreScalerFactor((i+1)*4-1 downto i*4), 
--				Inhibit => '0',
--				clock=>clock200);
--	end generate;
--	RawTriggers_AfterPreScaler <= Inter_RawTriggers_AfterPreScaler;
--	
--	--MultiFF
--	Inst_MultiFF : MultiFF GENERIC MAP (NCh => NConditions)
--		PORT MAP (
--			Inputs => Inter_RawTriggers_AfterPreScaler,
--			Outputs => Inter_ConditionsOut,
--			--clock => clock200,
--			Reset => MasterReset
--		);

	Inst_Prescalers_Conditions: for i in 0 to NConditions-1 generate
   begin
		PreScalerGatedFF_1: PreScalerGatedFF PORT MAP(
			SignalIN => Inter_RawTriggers_AfterRAM(i),
			Clock => clock200,
			SignalOut => Inter_ConditionsOut(i),
			PrescaleResetValue => SelectPreScalerFactor((i+1)*16-1 downto i*16),
			Reset => MasterReset,
			Debug_InputChange => Inter_RawTriggers_AfterPreScaler(i) --this is only a debug signal of PreScaler
		);
	end generate;
	RawTriggers_AfterPreScaler <= Inter_RawTriggers_AfterPreScaler; --this is only a debug signal of PreScaler
	
		
		
	ConditionsOut <= Inter_ConditionsOut;
	Inter_TriggerSignal <= '1' when Inter_ConditionsOut /= "0" else '0';
	TriggerSignal <= Inter_TriggerSignal;
	TriggerSignal_Inv <= not Inter_TriggerSignal;

	--Accept und Reject Signal
	AcceptSignal <= AllORRawTriggers_Stored_ExtDelayed and Inter_TriggerSignal;
	RejectSignal <= AllORRawTriggers_Stored_ExtDelayed and TriggerSignal_Inv;
	
	--Busy Signal
	Busy <= Inter_AllORRawTriggers_IntDelayed or Inter_AllORRawTriggers_Stored or AllORRawTriggers_Stored_ExtDelayed;

	
end Behavioral;

