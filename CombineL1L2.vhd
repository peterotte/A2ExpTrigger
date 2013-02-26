-- Peter-Bernd Otte
-- 2.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity CombineL1L2 is
    Port ( L2Fulfilled : in  STD_LOGIC;
           BypassL2Hold : in  STD_LOGIC;
			  L2Okay : out STD_logic;
           L1TriggerHold : in  STD_LOGIC;
			  L1TriggerHold_ExtDelayed : in  STD_LOGIC;
           DeadOut : out  STD_LOGIC;
			  ExternalExpTrigger : in  STD_LOGIC;
			  SelectExpTrigger : in std_logic;
           ExpTrigger : out  STD_LOGIC;
           FastClear : out  STD_LOGIC;
			  Reset : in std_logic;
			  clock : in  STD_LOGIC);
end CombineL1L2;

architecture Behavioral of CombineL1L2 is
	component GateShortener
		generic ( 
			NCh : integer
		);  
		Port ( sig_in : in  STD_LOGIC;
			  sig_out : out  STD_LOGIC;
			  clock : in  STD_LOGIC);
	end component;
	
   COMPONENT SingleBitStorage
   PORT( Data	:	IN	STD_LOGIC; 
          Clock	:	IN	STD_LOGIC; 
          Clear	:	IN	STD_LOGIC; 
          Output	:	OUT	STD_LOGIC);
   END COMPONENT;
	
	signal Inter_L2Okay, Inter_L2Okay_Inv : std_logic;
	signal L2Trigger : std_logic;
	signal Inter_FastClear : std_logic;
	signal Pre_ExpTrigger, Pre_FastClear : std_logic;

begin
	Inter_L2Okay <= BypassL2Hold or L2Fulfilled;
	L2Okay <= Inter_L2Okay;
	DeadOut <= L1TriggerHold or L1TriggerHold_ExtDelayed;
	
	--L2 Trigger
	Inst_SingleBitStorage_1: SingleBitStorage PORT MAP(
		Data => Inter_L2Okay, 
		Clock => L1TriggerHold_ExtDelayed, 
		Clear => Reset, 
		Output => L2Trigger
   );

	--FastClear
	Inter_L2Okay_Inv <= not Inter_L2Okay;
	Inst_SingleBitStorage_2: SingleBitStorage PORT MAP(
		Data => Inter_L2Okay_Inv, 
		Clock => L1TriggerHold_ExtDelayed, 
		Clear => Reset, 
		Output => Inter_FastClear
   );
	
	Pre_ExpTrigger <= L2Trigger when SelectExpTrigger = '0' else ExternalExpTrigger;
	
	GateShortener_1 : GateShortener GENERIC MAP (NCh => 4) PORT MAP (sig_in => Pre_ExpTrigger, sig_out => ExpTrigger, clock => clock);
	GateShortener_2 : GateShortener GENERIC MAP (NCh => 4) PORT MAP (sig_in => Inter_FastClear, sig_out => FastClear, clock => clock);

	
end Behavioral;
