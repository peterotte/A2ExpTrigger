-- Peter-Bernd Otte
-- 24.9.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClockedRegister is
	GENERIC (
		NCh : integer
	);
    Port ( Inputs : in  STD_LOGIC_VECTOR (NCh-1 downto 0);
           Outputs : out  STD_LOGIC_VECTOR (NCh-1 downto 0);
			  ClockedClock : in std_logic;
			  Clock : in std_logic;
           Reset : in  STD_LOGIC);
end ClockedRegister;

architecture Behavioral of ClockedRegister is
	signal Inter_Out : std_logic_vector(NCh-1 downto 0);
	signal LastClockedClock, LastLastClockedClock : std_logic;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			LastClockedClock <= ClockedClock;
			LastLastClockedClock <= LastClockedClock;
		end if;
	end process;
	
	process (clock)
	begin
		if rising_edge(clock) then
			if (Reset = '1') then
				Inter_Out <= (others => '0');
			elsif (LastClockedClock = '1') and (LastLastClockedClock = '0') then
				Inter_Out <= Inputs;
			else
				Inter_Out <= Inter_Out;
			end if;
		end if;
	end process;
	
	Outputs <= Inter_Out;
	
end Behavioral;

