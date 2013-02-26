-- Peter-Bernd Otte
-- 20.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OsziChControl is
    Port ( TriggerSignalIn : in  STD_LOGIC;
           Clock : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           RAMEnable : out  STD_LOGIC;
			  debug_out : out std_logic_vector(3 downto 0));
end OsziChControl;

architecture Behavioral of OsziChControl is
   COMPONENT SingleBitStorage
   PORT( Data	:	IN	STD_LOGIC; 
          Clock	:	IN	STD_LOGIC; 
          Clear	:	IN	STD_LOGIC; 
          Output	:	OUT	STD_LOGIC;
          CE	:	IN	STD_LOGIC);
   END COMPONENT;

	component PreciseGateByCounter is
	GENERIC (
		WIDTH : integer --in numbers of clock, max 2^14-1 (because of counter signal)
	);
    Port ( Input : in  STD_LOGIC;
           Output : out  STD_LOGIC; -- 20ns deadtime after pulse
			  DeadOut : out STD_LOGIC;--during reset (20ns) is this signal = '1'
			  Inhibit : in std_logic; -- normal operation = '0'. Not sensitive to input edge if = '1' (inhibit)
           clock : in  STD_LOGIC);
	end component;


	signal TriggerSignalClocked : std_logic;
	signal TriggerSignalStored, TriggerSignalStored_Delayed : std_logic;
	signal DelayCounter : std_logic_vector(9 downto 0);
	signal PreRAMEnable : std_logic;

	signal Reset_Shaped : std_logic;
begin
	--Used for deletion of complete ram after readout
	Inst_PreciseGateByCounter: PreciseGateByCounter GENERIC MAP (
		WIDTH => 1024 --length of addr register, at the moment 10 bits -> deep = 2^10
	) PORT MAP(
		clock => clock,
		Input => Reset,
		Output => Reset_Shaped,
		DeadOut => open,
		Inhibit => '0'
	);
	

	--Starting here for production of RAM Enable signal.
	Inst_SingleBitStorage_1: SingleBitStorage PORT MAP(
		Data => TriggerSignalIn, 
		Clock => Clock, 
		Clear => Reset_Shaped, 
		Output => TriggerSignalClocked,
		CE => '1'
   );
	Inst_SingleBitStorage_2: SingleBitStorage PORT MAP(
		Data => '1', 
		Clock => TriggerSignalClocked, 
		Clear => Reset_Shaped, 
		Output => TriggerSignalStored,
		CE => '1'
   );
	debug_out(0) <= TriggerSignalClocked;
	debug_out(1) <= TriggerSignalStored;
	debug_out(2) <= TriggerSignalStored_Delayed;
	debug_out(3) <= Reset_Shaped;
	--Delay
	process (Clock)
	begin
		if rising_edge(Clock) then
			if TriggerSignalStored = '0' then
				DelayCounter <= (others => '0');
			else
				DelayCounter <= DelayCounter + 1;
			end if;
		end if;
	end process;
	--Compare for Delay
	process (Clock)
	begin
		if rising_edge(Clock) then
			if DelayCounter >= 500 then --10=160, 20 = 260
				TriggerSignalStored_Delayed <= '1';
			else
				TriggerSignalStored_Delayed <= '0';
			end if;
		end if;
	end process;
	Inst_SingleBitStorage_3: SingleBitStorage PORT MAP(
		Data => '1', 
		Clock => TriggerSignalStored_Delayed, 
		Clear => Reset_Shaped, 
		Output => PreRAMEnable,
		CE => '1'
   );
	RAMEnable <= not PreRAMEnable;


end Behavioral;

