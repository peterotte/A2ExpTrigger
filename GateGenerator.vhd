library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity GateGenerator is
	generic (
		SYNC_LEADING_EDGE : integer range 0 to 1 := 0
   -- 0=Leading Edge of output
	 -- jitter-free => width has
	 -- jitter,
	 -- 1=Leading Edge of output
	 -- with jitter, but width is
	 -- jitter-free
		);
	
	port (Input		: in	std_logic;
				Output	: out std_logic;				-- 20ns deadtime after pulse
				DeadOut : out std_logic;	--during reset (20ns) is this signal = '1'
				Inhibit : in	std_logic;	-- normal operation = '0'. Not sensitive to input edge if = '1' (inhibit)
				Reset		: in	std_logic;
				WIDTH		: in	std_logic_vector(15 downto 0) := x"0002";
				clock		: in	std_logic);
end GateGenerator;

architecture arch of GateGenerator is
	signal Inter_Q : std_logic;
	signal Inter_Reset, Inter_out, Inter_Comp : std_logic;
	signal Input_reg, Input_regreg : std_logic;
	signal Inter_Comp_Reg											: std_logic;
	signal counter														: unsigned(15 downto 0) := x"0000";
	signal InputCE														: std_logic;
begin
	
	
	InputCE				 <= not Inhibit;	
	Inter_Reset		 <= Reset or Inter_Comp_Reg;
	FDCE_inst : FDCE
		generic map (
			INIT => '0') 
		port map (
			Q		=> Inter_Q,
			C		=> Input,
			CE	=> InputCE,
			CLR => Inter_Reset,
			D		=> '1');

	process
	begin
		wait until rising_edge(clock);

		input_reg <= Inter_Q;
		input_regreg <= input_reg;
		Inter_Comp_Reg <= Inter_Comp;
		
		if input_reg = '1' and input_regreg = '0' then
			counter <= unsigned(WIDTH);
			Inter_Comp <= '1';
		elsif counter /= x"0000" then
			counter <= counter-1;
		else
			Inter_Comp <= '0';
		end if;	
			
	end process;

	gen_SYNC : if SYNC_LEADING_EDGE = 1 generate
		Inter_out	<= input_reg;
	end generate;
	gen_ASYNC : if SYNC_LEADING_EDGE = 0 generate
		Inter_out	<= Inter_Q;
	end generate;
	
	
	Output <= Inter_comp or Inter_out;	
	DeadOut <= Inter_Comp;
	
end arch;
