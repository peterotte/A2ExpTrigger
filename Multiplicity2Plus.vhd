----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:47:15 10/07/2011 
-- Design Name: 
-- Module Name:    Multiplicity2Plus - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Multiplicity2Plus is
    Port ( Sig_In : in  STD_LOGIC_VECTOR (5 downto 0);
           M1Plus : out  STD_LOGIC;
           M2Plus : out  STD_LOGIC);
end Multiplicity2Plus;

architecture Behavioral of Multiplicity2Plus is

begin
	M1Plus <= '1' when Sig_In /= "0" else '0';
	
	M2Plus <= '1' when 
		(Sig_In(5) = '1' and Sig_In(4 downto 0) /= "0") or
		(Sig_In(4) = '1' and Sig_In(5)&Sig_In(3 downto 0) /= "0") or
		(Sig_In(3) = '1' and Sig_In(5 downto 4)&Sig_In(2 downto 0) /= "0") or
		(Sig_In(2) = '1' and Sig_In(5 downto 3)&Sig_In(1 downto 0) /= "0") or
		(Sig_In(1) = '1' and Sig_In(5 downto 2)&Sig_In(0) /= "0") or
		(Sig_In(0) = '1' and Sig_In(5 downto 1) /= "0") 
		else '0';

end Behavioral;

