-- Peter-Bernd Otte
-- 17.9.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MultiplicityUnit is
	Generic (
		NMultiplicityInputs : integer := 45+6;
		NMultiplicityOutputs : integer := 4
	);
	Port ( 
		SectorsIn : in  STD_LOGIC_VECTOR (NMultiplicityInputs-1 downto 0);
		SectorsIn_Saved : out  STD_LOGIC_VECTOR (NMultiplicityInputs-1 downto 0);
		MultiplicityValue : out STD_LOGIC_VECTOR (6 downto 0);
		MultiplicityValue_Saved : out STD_LOGIC_VECTOR (6 downto 0);
		MultiplicityTrigger : out STD_LOGIC_VECTOR(NMultiplicityOutputs-1 downto 0);
		Thresholds : in  STD_LOGIC_VECTOR (7*NMultiplicityOutputs-1 downto 0);
		GateGenClock : in std_logic;
		Reset : in std_logic;
		PreL1Trigger : in std_logic;
		debug_out : out std_logic_vector(31 downto 0)
	);
end MultiplicityUnit;

architecture Behavioral of MultiplicityUnit is
	attribute keep : string;
	attribute keep of PreL1Trigger: signal is "TRUE";

	--GG
	signal SectorsIn_Gated : std_logic_vector(NMultiplicityInputs-1 downto 0);
	COMPONENT PreciseGateByCounter
	GENERIC (
		WIDTH : integer; --in numbers of clock, max 2^22-1 (because of counter signal)
								-- total length: 5 = 8*clock
								-- total length: 3 = 6*clock
		CounterWidth : integer := 22
	);
	PORT(
		Input : IN std_logic;
		Inhibit : IN std_logic;
		clock : IN std_logic;          
		Output : OUT std_logic;
		DeadOut : OUT std_logic
		);
	END COMPONENT;

	--Multiplicity Calc
	component SpecificAdder is
		Generic (
			NOfInputBits : integer --max 64
		);
    Port ( EnableClusterCouting : in STD_LOGIC;
			  HitPattern : in  STD_LOGIC_VECTOR (NOfInputBits-1 downto 0);
           HitCounts : out  STD_LOGIC_VECTOR (6 downto 0)
			);
	end component;
	signal Inter_MultiplicityValue : std_logic_vector(6 downto 0);


	component MultiplicityCh is
	Generic (
		WhereToPlace_AND : string;
		WhereToPlace_OR : string
	);
    Port ( MultiplicityValueIN : in  STD_LOGIC_VECTOR (6 downto 0);
           TriggerOut : out  STD_LOGIC;
           debug_out : out  STD_LOGIC_VECTOR (4 downto 0);
			  Threshold : in  STD_LOGIC_VECTOR (6 downto 0);
			  GateGenClock : in std_logic
			);
	end component;

	type TypeCellPosition is array(0 to 6*2-1) of string(1 to 6); --requirement: number >= NMultiplicityOutputs
	constant PlaceOfDelayLines : TypeCellPosition := 
		("X00Y00","X02Y00",
		 "X04Y00","X06Y00",
		 "X08Y00","X10Y00",
		 "X12Y00","X14Y00",
		 "X16Y00","X18Y00",
		 "X20Y00","X22Y00" );

begin
	--GG at the beginning
	GGInputs: for i in 0 to NMultiplicityInputs-1 generate
	begin
		GGInput: PreciseGateByCounter GENERIC MAP (WIDTH => 26, CounterWidth => 6) --295ns
			PORT MAP(
			Input => SectorsIn(i),
			Output => SectorsIn_Gated(i),
			DeadOut => open, --this needs migth need to be connected
			Inhibit => '0',
			clock => GateGenClock
		);
	end generate;
	debug_out(31 downto 31-3) <= SectorsIn_Gated(3 downto 0);

	--Multiplicity Calc
	SpecificAdder1: SpecificAdder GENERIC MAP (
		NOfInputBits => NMultiplicityInputs
	) PORT MAP (
		EnableClusterCouting => '1', 
		HitPattern => SectorsIn_Gated, 
		HitCounts => Inter_MultiplicityValue
	);
	MultiplicityValue <= Inter_MultiplicityValue;
	
	
	MultiplicityChs: for i in 0 to NMultiplicityOutputs-1 generate
	begin
		Inst_MultiplicityCh : MultiplicityCh Generic MAP (
				WhereToPlace_AND => PlaceOfDelayLines(i*2),
				WhereToPlace_OR => PlaceOfDelayLines(i*2+1) )
			Port MAP ( MultiplicityValueIN => Inter_MultiplicityValue,
				TriggerOut => MultiplicityTrigger(i),
				debug_out => debug_out(i*5+4 downto i*5),
				Threshold => Thresholds((i+1)*7-1 downto i*7),
				GateGenClock => GateGenClock
			);
	end generate;
	
	process (PreL1Trigger)
	begin
		if reset = '1' then 
			MultiplicityValue_Saved <= (others => '0');
			SectorsIn_Saved <= (others => '0');
		elsif rising_edge(PreL1Trigger) then
			MultiplicityValue_Saved <= Inter_MultiplicityValue;
			SectorsIn_Saved <= SectorsIn_Gated;
		end if;
	end process;

end Behavioral;
