library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TDCTest1 is
    Port ( Enabled : in  STD_LOGIC;
			  BasicClock : in STD_LOGIC;
           SaveSignal1 : in  STD_LOGIC;
           SaveSignal2 : in  STD_LOGIC;
			  Reset : in STD_LOGIC;
			  Debug1 : out STD_LOGIC;
			  Debug2 : out STD_LOGIC;
           Data1 : out  STD_LOGIC_VECTOR (31 downto 0);
           Data2 : out  STD_LOGIC_VECTOR (31 downto 0));
end TDCTest1;

architecture Behavioral of TDCTest1 is
	constant FastGatesLength : integer := 10;
	constant BigCounterLength : integer := 15;

	signal CounterSignal : std_logic;
	signal SavedInter1, SavedInter2, inter : std_logic_vector(FastGatesLength downto 0);
	signal SavedCounter1, SavedCounter2, counter : std_logic_vector(BigCounterLength downto 0);
	
	signal SavedSmallCounter1, SavedSmallCounter2 : std_logic_vector(4 downto 0);
	
	attribute keep : boolean ;
	attribute keep of inter, SavedInter1, SavedInter2, SavedCounter1, SavedCounter2, counter : signal is true;
	attribute maxdelay : string;	
   attribute maxdelay of inter : signal is "130 ps";
	--attribute maxskew : string;
   --attribute maxskew of inter : signal is "10 ps";
begin
	inter(0) <= Enabled and BasicClock;
	
	inter_connections:
		for i in 1 to FastGatesLength generate
		begin
			inter(i) <= Enabled and inter(i-1);
		end generate;
	CounterSignal <= BasicClock;
	Debug1 <= inter(FastGatesLength);
	Debug2 <= CounterSignal;
	
	BigCounting: process (Reset, CounterSignal)
	begin
		if Reset = '1' then
			counter <= (others => '0');
		elsif rising_edge(CounterSignal) then
			counter <= counter + 1;
		end if;
	end process;
	
	FF1: process (Reset, SaveSignal1)
	begin
		if Reset = '1' then
			SavedInter1 <= (others => '0');
			SavedCounter1 <= (others => '0');
		elsif rising_edge(SaveSignal1) then
			SavedInter1 <= inter;
			SavedCounter1 <= Counter;
		end if;
	end process;
	
--	process (SavedInter1)
--	begin
--		case SavedInter1 is
--			when "0000000000000000" => SavedSmallCounter1 <= '1'&x"0";
--			when "0000000000000001" => SavedSmallCounter1 <= '1'&x"1";
--			when "0000000000000011" => SavedSmallCounter1 <= '1'&x"2";
--			when "0000000000000111" => SavedSmallCounter1 <= '1'&x"3";
--			when "0000000000001111" => SavedSmallCounter1 <= '1'&x"4";
--			when "0000000000011111" => SavedSmallCounter1 <= '1'&x"5";
--			when "0000000000111111" => SavedSmallCounter1 <= '1'&x"6";
--			when "0000000001111111" => SavedSmallCounter1 <= '1'&x"7";
--			when "0000000011111111" => SavedSmallCounter1 <= '1'&x"8";
--			when "0000000111111111" => SavedSmallCounter1 <= '1'&x"9";
--			when "0000001111111111" => SavedSmallCounter1 <= '1'&x"A";
--			when "0000011111111111" => SavedSmallCounter1 <= '1'&x"B";
--			when "0000111111111111" => SavedSmallCounter1 <= '1'&x"C";
--			when "0001111111111111" => SavedSmallCounter1 <= '1'&x"D";
--			when "0011111111111111" => SavedSmallCounter1 <= '1'&x"E";
--			when "0111111111111111" => SavedSmallCounter1 <= '1'&x"F";
--			when "1111111111111111" => SavedSmallCounter1 <= '0'&x"0";
--			when "1111111111111110" => SavedSmallCounter1 <= '0'&x"1";
--			when "1111111111111100" => SavedSmallCounter1 <= '0'&x"2";
--			when "1111111111111000" => SavedSmallCounter1 <= '0'&x"3";
--			when "1111111111110000" => SavedSmallCounter1 <= '0'&x"4";
--			when "1111111111100000" => SavedSmallCounter1 <= '0'&x"5";
--			when "1111111111000000" => SavedSmallCounter1 <= '0'&x"6";
--			when "1111111110000000" => SavedSmallCounter1 <= '0'&x"7";
--			when "1111111100000000" => SavedSmallCounter1 <= '0'&x"8";
--			when "1111111000000000" => SavedSmallCounter1 <= '0'&x"9";
--			when "1111110000000000" => SavedSmallCounter1 <= '0'&x"a";
--			when "1111100000000000" => SavedSmallCounter1 <= '0'&x"b";
--			when "1111000000000000" => SavedSmallCounter1 <= '0'&x"c";
--			when "1110000000000000" => SavedSmallCounter1 <= '0'&x"d";
--			when "1100000000000000" => SavedSmallCounter1 <= '0'&x"e";
--			when "1000000000000000" => SavedSmallCounter1 <= '0'&x"f";
--			when others => SavedSmallCounter1 <= '0'&x"0"; --Error occoured!!!
--		end case; 
--	end process;
	
	Data1 <= SavedCounter1 & b"00000" & SavedInter1 ;
	Data2 <= (others=> '0'); --SavedCounter2 & b"00000000000" & SavedSmallCounter2 ;

end Behavioral;

