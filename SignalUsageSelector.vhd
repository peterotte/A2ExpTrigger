-- Peter-Bernd Otte
-- 1.4.2012
-- last update 25.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SignalUsageSelector is
    Port ( Input : in  STD_LOGIC;
           SelectBypassL2 : in  STD_LOGIC;
           SelectUsage_Inv : in  STD_LOGIC;
           SelectUsage_DontCare : in  STD_LOGIC;
           Output : out  STD_LOGIC;
           BypassL2Out : out  STD_LOGIC);
end SignalUsageSelector;

architecture Behavioral of SignalUsageSelector is
	signal Pre_Out : std_logic;
begin
	Pre_Out <= Input when SelectUsage_Inv = '0' else (not Input);
	
	Output <= Pre_Out when SelectUsage_DontCare = '0' else '1';
	
	BypassL2Out <= Input when SelectBypassL2 = '1' else '0';

end Behavioral;

