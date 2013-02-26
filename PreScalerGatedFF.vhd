----------------------------------------------------------------------------------
-- Engineer: Peter-Bernd Otte
-- 
-- Create Date:    15:29:20 12/28/2012 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity PreScalerGatedFF is
    Port ( SignalIN : in  STD_LOGIC;
           Clock : in  STD_LOGIC;
           SignalOut : out  STD_LOGIC;
           PrescaleResetValue : in  STD_LOGIC_VECTOR (15 downto 0);
           Reset : in  STD_LOGIC;
			  Debug_InputChange : out std_logic);
end PreScalerGatedFF;

architecture Behavioral of PreScalerGatedFF is
	signal SignalIN_Saved_0, SignalIN_Saved_1 : std_logic;
	signal InputChange, CounterCompareTrue, CounterCompareReset : std_logic;
	
	constant CounterLength : integer := 16;
	signal counter : std_logic_vector(CounterLength-1 downto 0) := (0=>'0', others=> '1');
	
   COMPONENT SingleBitStorage
   PORT( Data	:	IN	STD_LOGIC; 
         CE	:	IN	STD_LOGIC; 
          Clock	:	IN	STD_LOGIC; 
          Clear	:	IN	STD_LOGIC; 
          Output	:	OUT	STD_LOGIC);
   END COMPONENT;
begin

   UUT1: SingleBitStorage PORT MAP(
		Data => SignalIN, 
		Clock => Clock, 
		CE => '1',
		Clear => '0', 
		Output => SignalIN_Saved_0
   );
   UUT2: SingleBitStorage PORT MAP(
		Data => SignalIN_Saved_0, 
		Clock => Clock, 
		CE => '1',
		Clear => '0', 
		Output => SignalIN_Saved_1
   );

	
	InputChange <= '1' when (SignalIN_Saved_1 = '0') and (SignalIN_Saved_0 = '1') else '0';
	Debug_InputChange <= InputChange;
	
   UUT3: SingleBitStorage PORT MAP(
		Data => CounterCompareTrue, 
		CE => '1',
		Clock => InputChange, 
		Clear => Reset, 
		Output => SignalOut
   );
	
	
	process (Clock)
	begin
		if rising_edge(Clock) then
			if (CounterCompareReset = '1') then
				counter <= PrescaleResetValue;
			elsif (InputChange = '1') then
				counter <= counter +1;
			end if;
		end if;
	end process;

	-- ='1' when x"ff"
	CounterCompareTrue <= '1' when counter(CounterLength-1 downto 0) = (CounterLength-1 downto 0 => '1') else '0';
	-- ='1' when x"00"
	CounterCompareReset <= '1' when counter(CounterLength-1 downto 0) = (CounterLength-1 downto 0 => '0') else '0';

end Behavioral;

