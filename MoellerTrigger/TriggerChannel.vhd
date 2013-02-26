library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InputStretcher is
	Generic (
		-- width of output signal:
		-- width of input + 2^(Duration)*T + 0..1*T
		--                                   ^ this is the jitter
		-- T = Length of one clock cycle
		Duration : integer := 1
		);
	PORT (
		Clock : in STD_LOGIC;
		Input : in STD_LOGIC;
		Output : out STD_LOGIC
	);
end InputStretcher;

architecture Behavioral of InputStretcher is
	type ZustandTyp is (Warten, Ausgabe);
	signal AZL : ZustandTyp ;
	signal counter : std_logic_vector(Duration downto 0);
begin

	process (Input, CLOCK)
	begin
		if (Input = '1') then 
			AZL <= Ausgabe;
			
		elsif rising_edge(CLOCK) and (AZL = Ausgabe) then
			counter <= counter + 1;
			if counter(Duration) = '1' then
				AZL <= Warten; 
				counter <= (others => '0');
			else
				AZL <= AZL;
			end if;
		end if;
	end process;

	Output <= '1' when AZL = Ausgabe else '0';

end Behavioral;
