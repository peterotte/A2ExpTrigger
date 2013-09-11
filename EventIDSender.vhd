----------------------------------------------------------------------------------
-- Engineer: Peter-Bernd Otte
-- Create Date:    08:47:24 09/10/2013 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;																						
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all; --  for bufg

entity EventIDSender is
    Port ( StatusCounter : out  STD_LOGIC_VECTOR (7 downto 0);
           UserEventID : in  STD_LOGIC_VECTOR (31 downto 0);
           ResetSenderCounter : in  STD_LOGIC;
           OutputPin : out  STD_LOGIC;
           clock50 : in  STD_LOGIC);
end EventIDSender;

architecture Behavioral of EventIDSender is

	signal CalculatedParityBit : std_logic;
	signal SenderClock : std_logic;
	signal ClockPreScaleCounter : std_logic_vector(3 downto 0);
	signal Inter_StatusCounter : STD_LOGIC_VECTOR (7 downto 0);

begin
	StatusCounter <= Inter_StatusCounter;

	process(clock50)
	begin
		if rising_edge(clock50) then
			ClockPreScaleCounter <= ClockPreScaleCounter +1;
		end if;
		SenderClock <= ClockPreScaleCounter(1);
	end process;


	CalculatedParityBit <= UserEventID(0) xor UserEventID(1) xor UserEventID(2) xor UserEventID(3) xor UserEventID(4) xor UserEventID(5) xor 
		UserEventID(6) xor UserEventID(7) xor UserEventID(8) xor UserEventID(9) xor UserEventID(10) xor UserEventID(11) xor UserEventID(12) xor 
		UserEventID(13) xor UserEventID(14) xor UserEventID(15) xor UserEventID(16) xor UserEventID(17) xor UserEventID(18) xor UserEventID(19) xor 
		UserEventID(20) xor UserEventID(21) xor UserEventID(22) xor UserEventID(23) xor UserEventID(24) xor UserEventID(25) xor UserEventID(26) xor 
		UserEventID(27) xor UserEventID(28) xor UserEventID(29) xor UserEventID(30) xor UserEventID(31);
	

	process(SenderClock)
	begin
		if rising_edge(SenderClock) then
			if Inter_StatusCounter(7) = '0' then
				Inter_StatusCounter <= Inter_StatusCounter +1;
			end if;
			if Inter_StatusCounter(6) = '1' then
				Inter_StatusCounter <= x"ff";
			end if;
			if ResetSenderCounter = '1' then
				Inter_StatusCounter <= x"00";
			end if;
		end if;
	end process;


	OutputPin <= '1' when Inter_StatusCounter = x"01" else
						UserEventID(0) when Inter_StatusCounter = x"02" else
						UserEventID(1) when Inter_StatusCounter = x"03" else
						UserEventID(2) when Inter_StatusCounter = x"04" else
						UserEventID(3) when Inter_StatusCounter = x"05" else
						UserEventID(4) when Inter_StatusCounter = x"06" else
						UserEventID(5) when Inter_StatusCounter = x"07" else
						UserEventID(6) when Inter_StatusCounter = x"08" else
						UserEventID(7) when Inter_StatusCounter = x"09" else
						UserEventID(8) when Inter_StatusCounter = x"0a" else
						UserEventID(9) when Inter_StatusCounter = x"0b" else
						UserEventID(10) when Inter_StatusCounter = x"0c" else
						UserEventID(11) when Inter_StatusCounter = x"0d" else
						UserEventID(12) when Inter_StatusCounter = x"0e" else
						UserEventID(13) when Inter_StatusCounter = x"0f" else
						UserEventID(14) when Inter_StatusCounter = x"10" else
						UserEventID(15) when Inter_StatusCounter = x"11" else
						UserEventID(16) when Inter_StatusCounter = x"12" else
						UserEventID(17) when Inter_StatusCounter = x"13" else
						UserEventID(18) when Inter_StatusCounter = x"14" else
						UserEventID(19) when Inter_StatusCounter = x"15" else
						UserEventID(20) when Inter_StatusCounter = x"16" else
						UserEventID(21) when Inter_StatusCounter = x"17" else
						UserEventID(22) when Inter_StatusCounter = x"18" else
						UserEventID(23) when Inter_StatusCounter = x"19" else
						UserEventID(24) when Inter_StatusCounter = x"1a" else
						UserEventID(25) when Inter_StatusCounter = x"1b" else
						UserEventID(26) when Inter_StatusCounter = x"1c" else
						UserEventID(27) when Inter_StatusCounter = x"1d" else
						UserEventID(28) when Inter_StatusCounter = x"1e" else
						UserEventID(29) when Inter_StatusCounter = x"1f" else
						UserEventID(30) when Inter_StatusCounter = x"20" else
						UserEventID(31) when Inter_StatusCounter = x"21" else
						CalculatedParityBit when Inter_StatusCounter = x"22" else
						'1' when Inter_StatusCounter = x"23" else
						'0';
	



end Behavioral;

