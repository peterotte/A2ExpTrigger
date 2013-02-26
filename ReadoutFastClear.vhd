-- Peter-Bernd Otte
-- 16.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ReadoutFastClear is
	generic (
		NVMEbusChs : integer
	);
    Port ( ExpTriggerIn : in  STD_LOGIC;
			  SingleVMECPUsReadoutComplete : in STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
			  SelectIncludeCPU : in STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
			  SingleVMECPUsBusy : out STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
			  ImmediateReset : in  STD_LOGIC;
           CPUsBusy : out  STD_LOGIC;
			  Reset : in std_logic;
			  PerformSignalOnMasterReset : in Std_logic;
			  clock100 : in std_logic;
			  debug_out : out  STD_LOGIC_VECTOR(3 downto 0)
			 );
end ReadoutFastClear;

architecture Behavioral of ReadoutFastClear is

begin

end Behavioral;

