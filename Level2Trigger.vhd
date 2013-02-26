-- Peter-Bernd Otte
-- 2.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity L2Trigger is 
   Generic (
 		NL2Inputs : integer := 3
	 );
    Port ( RawL2Trigger : in  STD_LOGIC_VECTOR (NL2Inputs-1 downto 0);
           SaveL2Inputs : in  STD_LOGIC;
           ResetL2 : in  STD_LOGIC;
           L2Fulfilled : out  STD_LOGIC;
			  clock : in Std_Logic;
  			  SelectUsage_Inv : in STD_LOGIC_VECTOR (NL2Inputs-1 downto 0); 
			  SelectUsage_DontCare : in STD_LOGIC_VECTOR (NL2Inputs-1 downto 0);
  			  StoredRawL2InputPattern : out STD_LOGIC_VECTOR (NL2Inputs-1 downto 0)
	);
end L2Trigger;

architecture Behavioral of L2Trigger is
	signal InterTriggerChOut : std_logic_vector(NL2Inputs-1 downto 0);

	COMPONENT Level2Ch
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
	END COMPONENT;

begin

	L2Inputs: for i in 0 to NL2Inputs-1 generate
   begin
		Inst_Level2Ch: Level2Ch PORT MAP(
			Input => RawL2Trigger(i),
			ExpTriggerInput => SaveL2Inputs,
			Clear => ResetL2,
			TriggerChOut => InterTriggerChOut(i),
			clock => clock,
			StoredBitOut => StoredRawL2InputPattern(i),
			SelectUsage_Inv => SelectUsage_Inv(i),
			SelectUsage_DontCare => SelectUsage_DontCare(i),
			debug_out => open
		);
	end generate;
	
	L2Fulfilled <= '1' when InterTriggerChOut = (NL2Inputs-1 downto 0 => '1') else '0';

end Behavioral;

