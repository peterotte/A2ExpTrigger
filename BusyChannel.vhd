-- Peter-Bernd Otte
-- 17.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BusyChannel is
    Port ( BusyIn : in  STD_LOGIC;
           BusyOut : out  STD_LOGIC;
           SelectIn : in  STD_LOGIC);
end BusyChannel;

architecture Behavioral of BusyChannel is

begin
	BusyOut <= BusyIn when SelectIn = '1' else '0';
end Behavioral;

