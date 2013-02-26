-- Peter-Bernd Otte
-- 26.4.2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PreScaler is
    generic ( 
				NChLength : integer
			);  
    Port ( Sig_In : in  STD_LOGIC;
           Sig_Out : out  STD_LOGIC;
           Factor : in  STD_LOGIC_VECTOR (3 downto 0);
			  Inhibit : in std_logic;
			  clock : in std_logic);
end PreScaler;

architecture Behavioral of PreScaler is
	signal InterCounter : std_logic_vector(13 downto 0);
	signal InterSig_Out : std_logic;
	
--	component GateShortener
--		 	generic ( 
--				NCh : integer
--			);  
--			Port ( sig_in : in  STD_LOGIC;
--				  sig_out : out  STD_LOGIC;
--				  clock : in  STD_LOGIC);
--	end component;
--	
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


begin
--	GateShortener_1 : GateShortener GENERIC MAP (NCh => NChLength) PORT MAP (InterSig_Out, Sig_Out, clock);
	Inst_PreciseGateByCounter: PreciseGateByCounter GENERIC MAP (
		WIDTH => NChLength
	) PORT MAP(
		clock => clock,
		Input => InterSig_Out,
		Output => Sig_Out,
		DeadOut => open,
		Inhibit => Inhibit
	);


	InterSig_Out <= Sig_In when Factor = x"0" else
		InterCounter(0) when Factor = x"1" else
		InterCounter(1) when Factor = x"2" else
		InterCounter(2) when Factor = x"3" else
		InterCounter(3) when Factor = x"4" else
		InterCounter(4) when Factor = x"5" else
		InterCounter(5) when Factor = x"6" else
		InterCounter(6) when Factor = x"7" else
		InterCounter(7) when Factor = x"8" else
		InterCounter(8) when Factor = x"9" else
		InterCounter(9) when Factor = x"a" else
		InterCounter(10) when Factor = x"b" else
		InterCounter(11) when Factor = x"c" else
		InterCounter(12) when Factor = x"d" else
		InterCounter(13) when Factor = x"e" else
		'0' when Factor = x"f" else
		'0';
		
	process (Sig_In)
	begin
		if rising_edge(Sig_In) then
			if (Inhibit='0') then
				InterCounter <= InterCounter +1;
			end if;
		end if;
	end process;


end Behavioral;

