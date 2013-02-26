-- Peter-Bernd Otte
-- 29.8.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OsziCh is
    Port ( clockRAMA : in  STD_LOGIC;
			  clockRAMB : in  STD_LOGIC;
           InputSignals : in  STD_LOGIC_VECTOR (255 downto 0);
           AddressReadout : in  STD_LOGIC_VECTOR (9 downto 0);
           DataOut : out  STD_LOGIC_VECTOR (255 downto 0);
           TriggerSignalIn : in  STD_LOGIC;
			  Reset : in std_logic;
			  debug_out : out std_logic_vector(4 downto 0));
end OsziCh;

architecture Behavioral of OsziCh is
	COMPONENT OsziChControl
	PORT(
		TriggerSignalIn : IN std_logic;
		Clock : IN std_logic;
		Reset : IN std_logic;          
		RAMEnable : OUT std_logic;
		debug_out : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

	component MyMemory
		port (
		clka: IN std_logic;
		ena: IN std_logic;
		wea: IN std_logic_VECTOR(0 downto 0);
		addra: IN std_logic_VECTOR(9 downto 0);
		dina: IN std_logic_VECTOR(255 downto 0);
		clkb: IN std_logic;
		addrb: IN std_logic_VECTOR(9 downto 0);
		doutb: OUT std_logic_VECTOR(255 downto 0));
	end component;
	-- Synplicity black box declaration
	attribute syn_black_box : boolean;
	attribute syn_black_box of MyMemory: component is true;
	
	-- Counter
	signal MyAddressCounter : std_logic_vector(9 downto 0);
	
	signal RAMEnable : std_logic;
	signal Inter_debug_out : std_logic_vector(3 downto 0);

begin
	Inst_OsziChControl: OsziChControl PORT MAP(
		TriggerSignalIn => TriggerSignalIn,
		Clock => clockRAMA,
		Reset => Reset,
		RAMEnable => RAMEnable,
		debug_out => Inter_debug_out
	);
	debug_out <= RAMEnable & Inter_debug_out;

	
	process (clockRAMA)
	begin
		if rising_edge(clockRAMA) then
			MyAddressCounter <= MyAddressCounter + 1;
		end if;
	end process;

	Inst_MyMemory : MyMemory
		port map (
			clka => clockRAMA,
			ena => RAMEnable,
			wea => "1",
			addra => MyAddressCounter,
			dina => InputSignals,
			clkb => clockRAMB,
			addrb => AddressReadout,
			doutb => DataOut);


end Behavioral;

