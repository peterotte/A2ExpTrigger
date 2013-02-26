----------------------------------------------------------------------------------
-- Company: GSI
-- Engineer: S.Minami
-- 
-- Create Date:    10:44:28 04/09/2008 
-- Design Name: 	vuprom_tdc_v1
-- Module Name:    tdc_tst - RTL 
-- Project Name: 	vuprom_tdc_v1
-- Target Devices:
-- Tool versions: 
-- Description: creating test signals to test tdc function.
--	
-- Dependencies: tdc.vhd
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments:
--  appointment on friday to go auslaenderbehoerde. 8:40.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tdc_tst is
	Generic ( Nch : integer );
    Port ( CLK : in  STD_LOGIC;
           START_IN : in  STD_LOGIC;
           START_OUT : out  STD_LOGIC_VECTOR ( (Nch-1) downto 0);
           STOP_OUT : out  STD_LOGIC);
end tdc_tst;
--

architecture RTL of tdc_tst is --------------------------------------------------------

signal start_reg : std_logic_vector ( (Nch-1) downto 0);
signal stop_reg : std_logic;
type tst_state	is (idle, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18);
signal tst_state_1 : tst_state; 

----------------------------------------------------------------------------------------


begin

	START_OUT <= start_reg;
	STOP_OUT <= stop_reg;


	process(CLK, START_IN)
	begin
		if( rising_edge(CLK)) then
			case tst_state_1 is
				when idle => -- reset counters, wait for action.
					if( START_IN='1') then
						tst_state_1 <= s0;
					end if;
				when s0 => 
					tst_state_1 <= s1;
				when s1 => 
					tst_state_1 <= s2;
				when s2 => 
					tst_state_1 <= s3;
				when s3 => 
					tst_state_1 <= s4;	
				when s4 => 
					tst_state_1 <= s5;		
				when s5 => 
					tst_state_1 <= s6;		
				when s6 => 
					tst_state_1 <= s7;		
				when s7 => 
					tst_state_1 <= s8;							
--					
				when s8 => 
					if(start_reg(Nch-1) = '1') then
						tst_state_1 <= s9;
					end if;
				when s9 =>
					if(start_reg(Nch-1) = '0') then
						tst_state_1 <= s10;
					end if;
--
				when s10 =>
					tst_state_1 <= s11;			
				when s11 =>
					tst_state_1 <= s12;			
				when s12 =>
					tst_state_1 <= s13;			
				when s13 =>
					tst_state_1 <= s14;								
				when s14 =>
					tst_state_1 <= s15;		
				when s15 =>
					tst_state_1 <= s16;							
				when s16 =>
					tst_state_1 <= s17;		
				when s17 =>
					tst_state_1 <= s18;		
					
				when s18=>
					if( START_IN='0' ) then
						tst_state_1 <= idle;
					end if;
--				
				when others =>
					tst_state_1 <= idle;
			end case;						
--
			if(tst_state_1 = s0 or tst_state_1 = s1 or tst_state_1 = s2 or  tst_state_1 = s3 
				or tst_state_1 = s4 or tst_state_1 = s5 or tst_state_1= s6 or tst_state_1 = s7 ) then
				start_reg(0) <= '1';
			else
				start_reg(0) <= '0';
			end if;
			for I in 0 to Nch-2 loop
					start_reg(I+1)<=start_reg(I);
			end loop;	
--			
			if(tst_state_1 = s10 or tst_state_1 = s11 or tst_state_1 = s12 or  tst_state_1 = s13
				or tst_state_1 = s14 or tst_state_1 = s15 or tst_state_1 = s16 or  tst_state_1 = s17 ) then
				stop_reg <= '1';
			else
				stop_reg <= '0';
			end if;

		end if;
	end process;
	
	
	

end RTL;

