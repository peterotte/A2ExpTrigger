-- Peter-Bernd Otte
-- Created: 30.5.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HelicityBitGenerator is
    Port ( clock0_5 : in  STD_LOGIC;
           clock100 : in  STD_LOGIC;
           HelicityOutput : out  STD_LOGIC;
           InhibitOut : out  STD_LOGIC;
			  debug_out : out std_logic_vector(3 downto 0));
end HelicityBitGenerator;

architecture Behavioral of HelicityBitGenerator is
	signal counter : std_logic_vector(7 downto 0);

	component HelicityBitROM
		port (
		clka: IN std_logic;
		addra: IN std_logic_VECTOR(7 downto 0);
		douta: OUT std_logic_VECTOR(0 downto 0));
	end component;

	-- Synplicity black box declaration
	attribute syn_black_box : boolean;
	attribute syn_black_box of HelicityBitROM: component is true;

	signal ROM_Output : std_logic_vector(0 downto 0);
	signal Inter_ROM_Output : std_logic;
	signal Inter_ROM_Output_Saved1, Inter_ROM_Output_Saved2 : std_logic;
	
	signal Inhibit_Short, Inhibit_Short_Saved : std_logic;
	
	component PreciseGateByCounter is
	GENERIC (
		WIDTH : integer --in numbers of clock, max 2^18-1 (because of counter signal)
	);
    Port ( Input : in  STD_LOGIC;
           Output : out  STD_LOGIC; -- 20ns deadtime after pulse
			  DeadOut : out STD_LOGIC;--during reset (20ns) is this signal = '1'
			  Inhibit : in std_logic; -- normal operation = '0'. Not sensitive to input edge if = '1' (inhibit)
           clock : in  STD_LOGIC);
	end component;


begin
	process(clock0_5)
	begin
		if falling_edge(clock0_5) then
			counter <= counter +1;
		end if;
	end process;

	Inst_HelicityBitROM : HelicityBitROM
		port map (
			clka => clock0_5,
			addra => counter,
			douta => ROM_Output(0 downto 0));
			
	debug_out(0) <= ROM_Output(0);
	debug_out(1) <= Inter_ROM_Output;
	debug_out(2) <= Inter_ROM_Output_Saved1;
	debug_out(3) <= Inhibit_Short;

	Inter_ROM_Output <= ROM_Output(0) when (clock0_5 = '1') else (not ROM_Output(0));
	
	process (clock100)
	begin
		if rising_edge(clock100) then
			Inter_ROM_Output_Saved1 <= Inter_ROM_Output;
			Inter_ROM_Output_Saved2 <= Inter_ROM_Output_Saved1;
		end if;
	end process;
	
	HelicityOutput <= Inter_ROM_Output_Saved2;
	
	Inhibit_Short <= Inter_ROM_Output xor Inter_ROM_Output_Saved1;
	process (clock100)
	begin
		if rising_edge(clock100) then
			Inhibit_Short_Saved <= Inhibit_Short;
		end if;
	end process;
	
	Inst_PreciseGateByCounter: PreciseGateByCounter GENERIC MAP (
		WIDTH => 1000000 --10ms
	) PORT MAP(
		clock => clock100,
		Input => Inhibit_Short_Saved,
		Output => InhibitOut,
		Inhibit => '0',
		DeadOut => open
	);


end Behavioral;

