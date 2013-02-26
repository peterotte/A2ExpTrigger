----------------------------------------------------------------------------------
-- Engineer: Peter-Bernd Otte
-- Create Date:    31.8.2012 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity StrobeDelay is
    Port ( Enable : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           SignalOut : out  STD_LOGIC;
           Reset : in  STD_LOGIC;
           DelayTime : in  STD_LOGIC_VECTOR (15 downto 0)
			  );
end StrobeDelay;

architecture Behavioral of StrobeDelay is
	signal Counter : std_logic_vector(15 downto 0);
	signal Internal_Enable : std_logic;
	signal AboveTreshold : std_logic;
	signal notClock : std_logic;
	
begin
	process (clock)
	begin
		if rising_edge(clock) then
			if Reset = '1' then
				Internal_Enable <= '0';
			else
				Internal_Enable <= Enable;
			end if;
		end if;	
	end process;
	
--	notClock <= not clock;
	notClock <= clock;
	process (notClock)
	begin
		if rising_edge(notClock) then
			if Reset = '1' then
				Counter <= (others => '1');
			elsif (Internal_Enable = '1') then
				Counter <= Counter +1;
			end if;
		end if;
	end process;

	process (clock)
	begin
		if rising_edge(clock) then
			if Reset = '1' then
				AboveTreshold <= '0';
			elsif Counter = DelayTime then
				AboveTreshold <= '1';
			end if;
		end if;
	end process;

	SignalOut <= Internal_Enable when DelayTime = x"ffff" else AboveTreshold;
end Behavioral;

