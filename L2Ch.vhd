-- Peter-Bernd Otte
-- 2.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Level2Ch is
    Port ( Input : in  STD_LOGIC;
           ExpTriggerInput : in  STD_LOGIC;
           Clear : in  STD_LOGIC;
           TriggerChOut : out  STD_LOGIC;
           clock : in  STD_LOGIC;
           StoredBitOut : out  STD_LOGIC;
  			  SelectUsage_Inv : in std_logic;
			  SelectUsage_DontCare : in std_logic;
			  debug_out : out std_logic_vector(3 downto 0)
			);
end Level2Ch;

architecture Behavioral of Level2Ch is

	COMPONENT gate_by_shiftreg
	Generic (
		WIDTH : integer
	);
	PORT(
		CLK : IN std_logic;
		SIG_IN : IN std_logic;          
		GATE_OUT : OUT std_logic
		);
	END COMPONENT;

   COMPONENT SingleBitStorage
   PORT( Data	:	IN	STD_LOGIC; 
          Clock	:	IN	STD_LOGIC; 
          Clear	:	IN	STD_LOGIC; 
          Output	:	OUT	STD_LOGIC);
   END COMPONENT;

	COMPONENT SignalUsageSelector
	PORT(
		Input : IN std_logic;
		SelectBypassL2 : IN std_logic;
		SelectUsage_Inv : in  STD_LOGIC;
      SelectUsage_DontCare : in  STD_LOGIC;
		Output : OUT std_logic;
		BypassL2Out : OUT std_logic
		);
	END COMPONENT;
	
	signal Input_AfterGG : std_logic;

begin
	Inst_gate_by_shiftreg: gate_by_shiftreg GENERIC MAP (
		WIDTH => 10
	) PORT MAP(
		CLK => clock,
		SIG_IN => Input,
		GATE_OUT => Input_AfterGG
	);
	
	debug_out(0) <= Input_AfterGG;

	--Single Bit Storage
	Inst_SingleBitStorage: SingleBitStorage PORT MAP(
		Data => Input_AfterGG, 
		Clock => ExpTriggerInput, 
		Clear => Clear, 
		Output => StoredBitOut
   );

	--Signal Usage Selector
	Inst_SignalUsageSelector: SignalUsageSelector PORT MAP(
		Input => Input_AfterGG,
		SelectBypassL2 => '0', --this is for L2 the case
		SelectUsage_Inv => SelectUsage_Inv,
      SelectUsage_DontCare => SelectUsage_DontCare,
		Output => TriggerChOut,
		BypassL2Out => open --this is for L2 the case
	);


end Behavioral;

