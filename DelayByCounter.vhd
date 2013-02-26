-- Peter-Bernd Otte
-- 7.5.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DelayByCounter is
	Generic (
		DelayTime : integer := 10;
		OutputTime : integer := 4
	);
    Port ( Clock : in  STD_LOGIC;
           Input : in  STD_LOGIC;
           DelayedOutput : out  STD_LOGIC);
end DelayByCounter;

architecture Behavioral of DelayByCounter is
	COMPONENT SingleBitStorage
   PORT( Data	:	IN	STD_LOGIC; 
          Clock	:	IN	STD_LOGIC; 
          Clear	:	IN	STD_LOGIC; 
          Output	:	OUT	STD_LOGIC);
   END COMPONENT;

	signal Counter : std_logic_vector(11 downto 0);
	signal CounterEnabled : std_logic;
	signal Reset : std_logic;
	signal Treshold1, Treshold2 : std_logic;
	signal Treshold1_Hold, Treshold2_Hold : std_logic;
begin

	Inst_SingleBitStorage_1: SingleBitStorage PORT MAP(
		Data => '1', 
		Clock => Input, 
		Clear => Reset, 
		Output => CounterEnabled
   );

	process (clock)
	begin
		if rising_edge(clock) then
			if CounterEnabled = '1' then
				Counter <= Counter + 1;
			else
				Counter <= (others=> '0');
			end if;
		end if;
	end process;

	process (clock) 
	begin
		if CounterEnabled = '0' then  --this should be replaced by some clocked version
			Treshold1 <= '0';
		elsif Counter = DelayTime then
			Treshold1 <= '1';
		end if;
	end process;
	
	process (clock)
	begin
		if CounterEnabled = '0' then  --this should be replaced by some clocked version
			Treshold2 <= '0';
		elsif Counter = DelayTime+OutputTime then
			Treshold2 <= '1';
		end if;
	end process;
	
	process (clock)
	begin
		if rising_edge(clock) then
			Treshold1_Hold <= Treshold1;
			Treshold2_Hold <= Treshold2;
		end if;
	end process;
	Reset <= Treshold2_Hold;
	
	DelayedOutput <= '1' when (Treshold2_Hold = '0') and (Treshold1_Hold = '1') else '0';
	
end Behavioral;
