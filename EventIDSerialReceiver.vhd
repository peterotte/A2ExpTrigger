----------------------------------------------------------------------------------
-- Create Date:    08:37 17.08.2012 
-- Peter-Bernd Otte
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EventIDSerialReceiver is
    Port ( clock : in  STD_LOGIC;
           SerialIn : in  STD_LOGIC;
			  OutputUserEventID : out std_logic_vector(31 downto 0);
			  ResetSenderCounter : in std_logic;
			  DebugOut : out STD_LOGIC_VECTOR(5 downto 0)
			  );
end EventIDSerialReceiver;

architecture Behavioral of EventIDSerialReceiver is
	signal Last_SignalIn : std_logic_vector(1 downto 0) := "00";
	signal StartDetected : std_logic;
	signal StatusCounter : std_logic_vector(9 downto 0) := "1111111111";
	signal LastInputSignals : std_logic_vector(33 downto 0);
	signal UserEventID : std_logic_vector(31 downto 0);
	signal UserParityBit : std_logic;
	signal UserControlBit : std_logic;
	signal CalculatedParityBit : std_logic;

begin

	process(clock)
	begin
		if rising_edge(clock) then
			Last_SignalIn(0) <= SerialIn;
			Last_SignalIn(1) <= Last_SignalIn(0);
		end if;
	end process;
	StartDetected <= '1' when Last_SignalIn = "01" else '0';
	DebugOut(5) <= StartDetected;

	process (clock)
	begin
		if rising_edge(clock) then
			DebugOut(0) <= '0';								--rising edge shows, when Receiver looks or data
			if StatusCounter(2 downto 0) = "011" then
				DebugOut(0) <= '1';
				LastInputSignals(33) <= SerialIn;
				for i in 33 downto 1 loop
					LastInputSignals(i-1) <= LastInputSignals(i);
				end loop;
			end if;
		end if;
	end process;

	CalculatedParityBit <= UserEventID(0) xor UserEventID(1) xor UserEventID(2) xor UserEventID(3) xor UserEventID(4) xor UserEventID(5) xor 
		UserEventID(6) xor UserEventID(7) xor UserEventID(8) xor UserEventID(9) xor UserEventID(10) xor UserEventID(11) xor UserEventID(12) xor 
		UserEventID(13) xor UserEventID(14) xor UserEventID(15) xor UserEventID(16) xor UserEventID(17) xor UserEventID(18) xor UserEventID(19) xor 
		UserEventID(20) xor UserEventID(21) xor UserEventID(22) xor UserEventID(23) xor UserEventID(24) xor UserEventID(25) xor UserEventID(26) xor 
		UserEventID(27) xor UserEventID(28) xor UserEventID(29) xor UserEventID(30) xor UserEventID(31) xor UserParityBit;
	

	process(clock)
	begin
		if rising_edge(clock) then
			UserEventID <= UserEventID;
			UserParityBit <= UserParityBit;
			UserControlBit <= UserControlBit;
			StatusCounter <= StatusCounter;
			--OutputUserEventID <= OutputUserEventID;
			DebugOut(4 downto 1) <= (others => '0');
			
			if ResetSenderCounter = '1' then
				StatusCounter <= "1000000001";
				UserEventID <= (others => '0');
				OutputUserEventID <= x"f0000000"; --(others => '0');
			elsif StatusCounter(9 downto 0) = "0100011000" then --after last control bit '1' was read
				DebugOut(4) <= '1';
				UserEventID <= LastInputSignals(31 downto 0);
				UserParityBit <= LastInputSignals(32);
				UserControlBit <= LastInputSignals(33);
				StatusCounter <= "1100000000";

			elsif StatusCounter(9) = '0' then
				StatusCounter <= StatusCounter +1;

			elsif (StatusCounter(9) = '1') and (StatusCounter(0) = '1') and (StartDetected = '1') then
				StatusCounter <= "0000000000";
			
			elsif (StatusCounter(9) = '1') and (StatusCounter(8) = '1') and (UserControlBit = '0') then --control bit missing
				StatusCounter <= "1010000000";
				OutputUserEventID <= x"fffffffe";
				DebugOut(1) <= '1';
			elsif (StatusCounter(9) = '1') and (StatusCounter(8) = '1') and (CalculatedParityBit = '0') and (UserControlBit = '1') then --Parity bit correct, control bit present
				StatusCounter <= "1000100000";
				OutputUserEventID <= UserEventID;
				DebugOut(2) <= '1';
			elsif (StatusCounter(9) = '1') and (StatusCounter(8) = '1') and (CalculatedParityBit = '1') and (UserControlBit = '1') then --Parity bit incorrect, control bit present
				StatusCounter <= "1001000000";
				OutputUserEventID <= x"ffffffff";
				DebugOut(3) <= '1';
			end if;
			
		end if;
	end process;

end Behavioral;
