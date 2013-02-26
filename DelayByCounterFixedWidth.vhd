-- Peter-Bernd Otte
-- 19.5.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DelayByCounterFixedWidth is
	Generic (
		OutputTime : integer := 4
	);
    Port ( Clock : in  STD_LOGIC;
           Input : in  STD_LOGIC;
			  DelayTime : in STD_LOGIC_VECTOR(15 downto 0);
			  ExternalReset : in std_logic;
           DelayedOutput : out  STD_LOGIC);
end DelayByCounterFixedWidth;

architecture Behavioral of DelayByCounterFixedWidth is
	COMPONENT SingleBitStorage
   PORT( Data	:	IN	STD_LOGIC; 
          Clock	:	IN	STD_LOGIC; 
          Clear	:	IN	STD_LOGIC; 
          Output	:	OUT	STD_LOGIC;
          CE	:	IN	STD_LOGIC);
   END COMPONENT;
	
	COMPONENT gate_by_shiftreg
	Generic (
		WIDTH : integer
	);
	PORT(
		CLK : IN std_logic;
		SIG_IN : IN std_logic;          
		GATE_OUT : OUT std_logic
		);
	END COMPONENT;

	signal Counter : std_logic_vector(15 downto 0);
	signal PreCounterEnabled, CounterEnabled : std_logic;
	signal Reset : std_logic;
	signal Treshold1 : std_logic;
	signal Treshold1_Hold : std_logic;
begin

	Inst_SingleBitStorage_1: SingleBitStorage PORT MAP(
		Data => '1', 
		Clock => Input, 
		Clear => Reset, 
		Output => PreCounterEnabled,
		CE => '1'
   );
	Inst_SingleBitStorage_2: SingleBitStorage PORT MAP(
		Data => PreCounterEnabled, 
		Clock => clock, 
		Clear => Reset, 
		Output => CounterEnabled,
		CE => '1'
   );

--	process (clock)
--	begin
--		if rising_edge(clock) then
--			if Reset = '1' then
--				CounterEnabled <= '0';
--			elsif Input = '1' then
--				CounterEnabled <= '1';
--			else 
--				CounterEnabled <= CounterEnabled;
--			end if;
--		end if;
--	end process;

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

--	process (CounterEnabled, Counter, DelayTime)
--	begin
--		if CounterEnabled = '0' then
--			Treshold1 <= '0';
--		elsif Counter = DelayTime then
--			Treshold1 <= '1';
--		end if;
--	end process;
--	
	process (clock)
	begin
		if rising_edge(clock) then
			if CounterEnabled = '0' then
				Treshold1_Hold <= '0';
			elsif Counter = DelayTime then
				Treshold1_Hold <= '1';
			else
				Treshold1_Hold <= Treshold1_Hold;
			end if;
--			Treshold1_Hold <= Treshold1;
		end if;
	end process;
	Reset <= Treshold1_Hold or ExternalReset;
	
	Inst_gate_by_shiftreg: gate_by_shiftreg GENERIC MAP (
		WIDTH => OutputTime
	) PORT MAP(
		CLK => clock,
		SIG_IN => Treshold1_Hold,
		GATE_OUT => DelayedOutput
	);
	
end Behavioral;
