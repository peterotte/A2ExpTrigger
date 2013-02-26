
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Signal_Delay is
	Generic (
		DelayBy : integer
--		Width : integer
		);
   Port ( 
		clock : in  STD_LOGIC;
		input_signal : in  STD_LOGIC;
      output_signal : out  STD_LOGIC
	);
end Signal_Delay;

architecture Behavioral of Signal_Delay is
--	type Type_Single_Input_State is (Warten, Verzoegern, Ausgabe) ;
--	signal Single_Input_State : Type_Single_Input_State;
	signal sr : std_logic_vector ( (DelayBy-1) downto 0);

begin
	
	process (CLOCK, input_signal)
	begin
		if(rising_edge(CLOCK)) then
			sr(0) <= input_signal;
			for i in 1 to (DelayBy-1) loop
				sr(i)<=sr(i-1);				
			end loop;	
		end if;
	end process;
	
	output_signal <= sr(DelayBy-1);

--	process (input_signal, CLOCK, Single_Input_State)
--		variable Delay_Zaehler, Ausgabe_Zaehler : integer;
--	begin
--		if (input_signal = '1') and (Single_Input_State = Warten) then
--			Single_Input_State <= Verzoegern;
--		elsif (rising_edge(clock)) then
--			if (Single_Input_State = Verzoegern) then
--				Delay_Zaehler := Delay_Zaehler + 1;
--				if Delay_Zaehler >= DelayBy then
--					Single_Input_State <= Ausgabe;
--					Delay_Zaehler := 0;
--				end if;
--			elsif (Single_Input_State = Ausgabe) then
--				Ausgabe_Zaehler := Ausgabe_Zaehler + 1;
--				if Ausgabe_Zaehler >= Width then
--					Ausgabe_Zaehler := 0;
--					Single_Input_State <= Warten;
--				end if;
--			end if;
--		end if;
--	end process;
--
--	output_signal <= '1' when Single_Input_State = Ausgabe else '0';
	
end Behavioral;
