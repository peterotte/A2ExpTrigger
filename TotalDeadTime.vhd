-- Peter-Bernd Otte
-- 2.4.2012
-- Last update: 8.5.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TotalDeadTime is
    Port ( L1Busy : in  STD_LOGIC;
			  L2Busy : in  STD_LOGIC;
           BusyTAPS : in  STD_LOGIC;
           BusyCPUs : in  STD_LOGIC;
           TotalBusyOut : out  STD_LOGIC;
			  EnableTrigger : in  STD_LOGIC;
			  EnableTAPS : in  STD_LOGIC);
end TotalDeadTime;

architecture Behavioral of TotalDeadTime is
begin

end Behavioral;

