----------------------------------------------------------------------------------
-- Engineer: 		Peter-Bernd Otte
-- Create Date:    18.9.2012
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MultiplicityCh is
	Generic (
		WhereToPlace_AND : string;
		WhereToPlace_OR : string
	);
    Port ( MultiplicityValueIN : in  STD_LOGIC_VECTOR (6 downto 0);
           TriggerOut : out  STD_LOGIC;
           debug_out : out  STD_LOGIC_VECTOR (4 downto 0);
			  Threshold : in  STD_LOGIC_VECTOR (6 downto 0);
			  GateGenClock : in std_logic
			);
end MultiplicityCh;

architecture Behavioral of MultiplicityCh is
	--Delay by internal wire
   COMPONENT AnalogDelayLine
   PORT( Delay_Out9	:	OUT	STD_LOGIC; 
          Delay_Out3	:	OUT	STD_LOGIC; 
          Delay_Out12	:	OUT	STD_LOGIC; 
          Delay_IN	:	IN	STD_LOGIC);
   END COMPONENT;
	attribute RLOC_ORIGIN       : string ;
	attribute RLOC_ORIGIN of Delay_AND : label is WhereToPlace_AND; --"X0Y0"
	attribute RLOC_ORIGIN of Delay_OR : label is WhereToPlace_OR; --"X2Y0"

	--GG
	COMPONENT PreciseGateByCounter
	GENERIC (
		WIDTH : integer --in numbers of clock, max 2^22-1 (because of counter signal)
								-- total length: 5 = 8*clock
								-- total length: 3 = 6*clock
	);
	PORT(
		Input : IN std_logic;
		Inhibit : IN std_logic;
		clock : IN std_logic;          
		Output : OUT std_logic;
		DeadOut : OUT std_logic
		);
	END COMPONENT;

	--
	signal PreMultiplicityTrigger, PreMultiplicityTrigger_Delayed,
		PreMultiplicityTrigger_AND, PreMultiplicityTrigger_AND_Delayed,
		Inter_MultiplicityTrigger : std_logic;
begin
	--Comparator
	PreMultiplicityTrigger <= '1' when MultiplicityValueIN > Threshold else '0';

	--Delay by internal wire
   Delay_AND: AnalogDelayLine PORT MAP(
		Delay_Out9 => PreMultiplicityTrigger_Delayed, 
		Delay_Out3 => open, 
		Delay_Out12 => open, --17ns
		Delay_IN => PreMultiplicityTrigger
   );
	PreMultiplicityTrigger_AND <= PreMultiplicityTrigger_Delayed and PreMultiplicityTrigger;
	
   Delay_OR: AnalogDelayLine PORT MAP(
		Delay_Out9 => PreMultiplicityTrigger_AND_Delayed, 
		Delay_Out3 => open, 
		Delay_Out12 => open, 
		Delay_IN => PreMultiplicityTrigger_AND
   );
	Inter_MultiplicityTrigger <= PreMultiplicityTrigger_AND_Delayed or PreMultiplicityTrigger_AND;
	

	GGTriggerOut: PreciseGateByCounter GENERIC MAP (WIDTH => 18) --@200MHz: 18=100ns, 3=30ns
			PORT MAP(
			Input => Inter_MultiplicityTrigger,
			Output => TriggerOut,
			DeadOut => open, --this needs migth need to be connected
			Inhibit => PreMultiplicityTrigger_AND_Delayed,
			clock => GateGenClock
		);

	debug_out(0) <= PreMultiplicityTrigger;
	debug_out(1) <= PreMultiplicityTrigger_Delayed;
	debug_out(2) <= PreMultiplicityTrigger_AND;
	debug_out(3) <= PreMultiplicityTrigger_AND_Delayed;
	debug_out(4) <= Inter_MultiplicityTrigger;


end Behavioral;
