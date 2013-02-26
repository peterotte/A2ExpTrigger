library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Input_Enlarger is
	Generic (
		Width : integer
		);
   Port ( 
		clock : in  STD_LOGIC;
		input_signal : in  STD_LOGIC;
      output_signal : out  STD_LOGIC
	);
end Input_Enlarger;

architecture Behavioral of Input_Enlarger is
	type Type_Single_Input_State is (Warten, Ausgabe) ;
	signal Single_Input_State : Type_Single_Input_State;
	
--	signal sr : std_logic_vector ( width downto 0);   -- ShiftRegister
--	signal sig_width : std_logic;

begin

	process (input_signal, CLOCK, Single_Input_State)
		variable Zaehler : integer;
	begin
		if (input_signal = '1') and (Single_Input_State = Warten) then
			Single_Input_State <= Ausgabe;
		elsif (rising_edge(clock)) and (Single_Input_State = Ausgabe) then
			Zaehler := Zaehler + 1;
			if Zaehler >= Width then
				Zaehler := 0;
				Single_Input_State <= Warten;
			end if;
		 end if;
	end process;

	output_signal <= '1' when Single_Input_State = Ausgabe else '0';
	
	
--	process (CLOCK, input_signal)
--	begin
--		if(rising_edge(CLOCK)) then
--			sr(0) <= input_signal;
--			for i in 1 to Width loop
--				sr(i)<=sr(i-1);				
--			end loop;	
--
--			if (sr(1) = '0') and (sr(0)='1') then
--				sig_width <= '1';
--			elsif (sr(Width) = '0') and (sr(Width-1) = '1') then
--				sig_width <= '0';
--			else 
--				sig_width <= sig_width;
--			end if;
--		end if;
--	end process;
--	
--	output_signal <= sig_width;

end Behavioral;

