library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ChannelCombination is
	Generic (
		Width : integer
		);
	PORT (
		EingangLinks : in STD_LOGIC;
		EingaengeRechts : in STD_LOGIC_VECTOR(Width-1 downto 0);
		Ausgang : out STD_LOGIC
	);
end ChannelCombination;

architecture Behavioral of ChannelCombination is
begin
	Ausgang <= '1' when (EingangLinks = '1' and EingaengeRechts /= "0") else '0';
end Behavioral;

