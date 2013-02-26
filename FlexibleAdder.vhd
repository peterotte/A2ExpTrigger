-- Peter-Bernd Otte
-- 2.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;


entity FlexibleAdder is
	generic (SizeOfInput1, SizeOfInput2, SizeOfOutput : integer);
    Port ( BitPattern1 : in  STD_LOGIC_VECTOR (SizeOfInput1-1 downto 0);
           BitPattern2 : in  STD_LOGIC_VECTOR (SizeOfInput2-1 downto 0);
           BitCounts : out  STD_LOGIC_VECTOR (SizeOfOutput-1 downto 0)); --SizeOfOutput always needs to be 1 number greater than biggest
end FlexibleAdder;

architecture Behavioral of FlexibleAdder is
	signal mytest1, mytest2, mytest : unsigned(SizeOfOutput-1 downto 0); --temp
begin
--	temp <= (others => '0');
--	mytest1 <= temp(SizeOfOutput-1 downto SizeOfInput1)&unsigned(BitPattern1);
--		mytest2 <= temp(SizeOfOutput-1 downto SizeOfInput2)&unsigned(BitPattern2);
	process (BitPattern1, BitPattern2)
	begin
		mytest1 <= (others => '0');
		mytest1(SizeOfInput1-1 downto 0) <= unsigned(BitPattern1);
		mytest2 <= (others => '0');
		mytest2(SizeOfInput2-1 downto 0) <= unsigned(BitPattern2);
	end process;
	
	mytest <= mytest1 + mytest2;
	
	BitCounts <= STD_LOGIC_VECTOR( mytest );
end Behavioral;

