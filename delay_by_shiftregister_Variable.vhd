----------------------------------------------------------------------------------
-- Peter-Bernd Otte
-- 30.8.2012
--   Delay = DELAY times clock cycle
--   Delay = 3 means delays by 2*clock lengths + 0..1*clock length
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity delay_by_shiftregister_Variable is
    Port ( CLK : in  STD_LOGIC;
           SIG_IN : in  STD_LOGIC;
			  DELAY : in std_logic_vector(2 downto 0); 
           DELAY_OUT : out  STD_LOGIC);
end delay_by_shiftregister_Variable;

architecture Behavioral of delay_by_shiftregister_Variable is

constant MaxDelay : integer := 8; -- = 2^3
signal sr : std_logic_vector ( (MaxDelay-1) downto 0);

begin

	process (CLK, SIG_IN)
	begin
		if(rising_edge(CLK)) then
			sr(0) <= SIG_IN;
			for i in 1 to (MaxDelay-1) loop
				sr(i)<=sr(i-1);				
			end loop;	
		end if;
	end process;
	
	DELAY_OUT <= sr(0) when DELAY = "000" else
		sr(1) when DELAY = "001" else
		sr(2) when DELAY = "010" else
		sr(3) when DELAY = "011" else
		sr(4) when DELAY = "100" else
		sr(5) when DELAY = "101" else
		sr(6) when DELAY = "110" else
		sr(7) when DELAY = "111";
	
end Behavioral;

