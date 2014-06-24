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
	signal Inter_Comp_Reg											: std_logic;
	signal counter														: unsigned(15 downto 0);
	signal InputCE														: std_logic;
begin
	InputCE				 <= not Inhibit;
	
	Inter_Reset		 <= Reset or Inter_Comp_reg;

	gen_SYNC : if SYNC_LEADING_EDGE = 1 generate
		Inter_out	<= Inter_Q when rising_edge(clock);
		Inter_Comp_reg <= Inter_Comp;
	end generate;
	gen_ASYNC : if SYNC_LEADING_EDGE = 0 generate
		Inter_out	<= Inter_Q;
		Inter_Comp_reg <= Inter_Comp when rising_edge(clock);
	end generate;
	
	
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
		variable counter_is_zero : boolean;
	begin
		wait until rising_edge(clock);
		counter_is_zero := counter = x"0000";
		if Inter_out = '1' and not counter_is_zero then
			counter <= counter-1;
		elsif Inter_out = '0' then
			counter <= unsigned(WIDTH)-1;
		end if;
		if counter_is_zero then
			Inter_Comp <= '1';
		else
			Inter_Comp <= '0';
		end if;
	end process;

	Output <= Inter_comp or Inter_out;	
	DeadOut <= Inter_Comp;
	
end arch;
