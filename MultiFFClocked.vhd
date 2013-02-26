-- Peter-Bernd Otte
-- 3.5.2012
-- 20.9.2012: This component does not work well. Solution: Introduce second Last_Inputs and then compare those two

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MultiFFClocked is
	GENERIC (
		NCh : integer := 8
	);
    Port ( Inputs : in  STD_LOGIC_VECTOR (NCh-1 downto 0);
           Outputs : out  STD_LOGIC_VECTOR (NCh-1 downto 0);
			  clock : in Std_logic;
           Reset : in  STD_LOGIC);
end MultiFFClocked;

architecture Behavioral of MultiFFClocked is
	signal Inter_Outputs : STD_LOGIC_VECTOR (NCh-1 downto 0);
	signal Last_Inputs : STD_LOGIC_VECTOR (NCh-1 downto 0);
begin
	process (clock)
	begin
		if rising_edge(clock) then
			Last_Inputs <= Inputs;
		end if;
	end process;
	
	process (clock)
	begin
		if rising_edge(clock) then
			for i in 0 to (NCh-1) loop
				if Reset = '1' then
					Inter_Outputs(i) <= '0';
				elsif (Last_Inputs(i) = '0') and (Inputs(i) = '1') then
					Inter_Outputs(i) <= '1';
				else
					Inter_Outputs(i) <= Inter_Outputs(i);
				end if;
			end loop;	
		end if;
	end process;
	
	Outputs <= Inter_Outputs;

end Behavioral;

