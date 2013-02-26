--
-- Clock Input, e.g. 50MHz
-- Now provide the DividingPower integer:
-- 0 --> Rate(Sig_Out) = clock/2**1
-- 1 --> Rate(Sig_Out) = clock/2**2
-- 2 --> Rate(Sig_Out) = clock/2**3
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Pulser is
	generic (
		DividingPower : integer;
		OutputWidth : integer
		);
    Port ( clock : in  STD_LOGIC;
           Sig_Out : out  STD_LOGIC);
end Pulser;

architecture Behavioral of Pulser is
	signal ClockCounter : std_logic_vector(DividingPower downto 0);
	signal InterSig_Out : std_logic;
	
	component GateShortener
		 	generic ( 
				NCh : integer
			);  
			Port ( sig_in : in  STD_LOGIC;
				  sig_out : out  STD_LOGIC;
				  clock : in  STD_LOGIC);
	end component;

begin

	process (clock)
	begin
		if rising_edge(clock) then
			ClockCounter <= ClockCounter +1;
		end if;
	end process;
	
	InterSig_Out <= ClockCounter(DividingPower);
	
	GateShortener_1 : GateShortener GENERIC MAP (NCh => OutputWidth) PORT MAP (sig_in => InterSig_Out, sig_out => Sig_Out, clock => clock);

	
end Behavioral;

