-- Peter-Bernd Otte
-- 27.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MultiFF is
	GENERIC (
		NCh : integer := 8
	);
    Port ( Inputs : in  STD_LOGIC_VECTOR (NCh-1 downto 0);
           Outputs : out  STD_LOGIC_VECTOR (NCh-1 downto 0);
           Reset : in  STD_LOGIC);
end MultiFF;

architecture Behavioral of MultiFF is
	COMPONENT SingleBitStorage
   PORT( Data	:	IN	STD_LOGIC; 
          Clock	:	IN	STD_LOGIC; 
          CE	:	IN	STD_LOGIC; 
          Clear	:	IN	STD_LOGIC; 
          Output	:	OUT	STD_LOGIC);
   END COMPONENT;

begin

	Inst_SingleBitStorages: for i in 0 to NCh-1 generate
   begin
		Inst_SingleBitStorage: SingleBitStorage PORT MAP(
			Data => '1', 
			Clock => Inputs(i), 
			CE => '1',
			Clear => Reset, 
			Output => Outputs(i)
		);
	end generate;


end Behavioral;

