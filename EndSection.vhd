-- Peter-Bernd Otte
-- 8.5.2012
-- last update: 8.5.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EndSection is
	Generic (
		NConditions : integer := 8 --if this is changed from default values, the IP cores also need to be updated
	);
   Port ( 
		ConditionsIn : in std_logic_vector(NConditions-1 downto 0);
		ExperimentTrigger : in std_logic;
		MasterReset : in std_logic;
		--VME Register
		Register_dout: OUT std_logic_VECTOR(NConditions-1 downto 0);

		clock100 : in std_logic
	);
end EndSection;

architecture Behavioral of EndSection is
	--Register of ConditionsIn Signals
	COMPONENT ClockedRegister is
		GENERIC (
			NCh : integer
		);
		Port ( Inputs : in  STD_LOGIC_VECTOR (NCh-1 downto 0);
           Outputs : out  STD_LOGIC_VECTOR (NCh-1 downto 0);
			  ClockedClock : in std_logic;
			  Clock : in std_logic;
           Reset : in  STD_LOGIC);
	end COMPONENT;
	
begin
	--Register of ConditionsIn Signals
	Inst_Register: ClockedRegister GENERIC MAP ( NCh => NConditions )
		PORT MAP(
		Inputs => ConditionsIn,
		Outputs => Register_dout,
		ClockedClock => ExperimentTrigger,
		Clock => clock100,
		Reset => MasterReset
	);
	
end Behavioral;

