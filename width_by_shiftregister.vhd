----------------------------------------------------------------------------------
-- Company: GSI
-- Engineer: S.Minami 
-- 
-- Create Date:    11:02:22 08/07/2008 
-- Design Name:
-- Module Name:    width_by_shiftregister - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--  SIG_OUT will be 
--  	delayed by one clock cycle.
--		fo the width of WIDTH times clock cycle.
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: Good luck!!
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity width_by_shiftregister is
	Generic (
		WIDTH : integer
	);
    Port ( CLK : in  STD_LOGIC;
           SIG_IN : in  STD_LOGIC;
           SIG_OUT : out  STD_LOGIC);
end width_by_shiftregister;

architecture Behavioral of width_by_shiftregister is
signal sr : std_logic_vector ( WIDTH downto 0);
signal sig_width : std_logic;

begin

	process (CLK, SIG_IN)
	begin
		if(rising_edge(CLK)) then
			sr(0) <= SIG_IN;
			for i in 1 to WIDTH loop
				sr(i)<=sr(i-1);				
			end loop;	

			if(sr(1)='0' and sr(0)='1') then
				sig_width <= '1';
			elsif(sr(WIDTH)='0' and sr(WIDTH-1)='1') then
				sig_width <= '0';
			else sig_width <= sig_width;
			end if;
		end if;
	end process;
	
	SIG_OUT <= sig_width;
	

end Behavioral;

