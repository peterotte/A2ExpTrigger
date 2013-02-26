-- Peter-Bernd Otte
-- 7.5.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InputSection is
	Generic (
		NRawL1Inputs : integer := 16
	);
    Port ( RawL1Triggers : in  STD_LOGIC_VECTOR (NRawL1Inputs-1 downto 0);
           VetoInput : in  STD_LOGIC;
			  RawL1Triggers_PreScaled : out  STD_LOGIC_VECTOR (NRawL1Inputs-1 downto 0);
           PreTriggerOut : out  STD_LOGIC;
           SelectPreScalerFactor : in  STD_LOGIC_VECTOR (NRawL1Inputs*4-1 downto 0);
			  PreTriggerMask : in std_logic_vector(NRawL1Inputs-1 downto 0);
			  clock : in STD_LOGIC);
end InputSection;

architecture Behavioral of InputSection is
	--PreScaler with Gate generator
	component PreScaler
    generic ( 
				NChLength : integer
			);  
	 Port ( Sig_In : in  STD_LOGIC;
           Sig_Out : out  STD_LOGIC;
           Factor : in  STD_LOGIC_VECTOR (3 downto 0);
			  Inhibit : in std_logic;
			  clock : in std_logic);
	end component;
	
	signal RawL1Triggers_AfterPreScaler, RawL1Triggers_AfterPreScaler_AfterMask : std_logic_vector(NRawL1Inputs-1 downto 0);
begin
	--PreScaler with Gate generator
	Inst_Prescalers: for i in 0 to NRawL1Inputs-1 generate
   begin
		Inst_Prescaler : PreScaler GENERIC MAP (NChLength => 5) 
			Port MAP ( 
				Sig_In => RawL1Triggers(i),
				Sig_Out => RawL1Triggers_AfterPreScaler(i), 
				Factor => SelectPreScalerFactor((i+1)*4-1 downto i*4), 
				Inhibit => VetoInput,
				clock => clock);
	end generate;
	RawL1Triggers_PreScaled <= RawL1Triggers_AfterPreScaler;
	
	RawL1Triggers_AfterPreScaler_AfterMask <= RawL1Triggers_AfterPreScaler and PreTriggerMask;
	
	PreTriggerOut <= '1' when RawL1Triggers_AfterPreScaler_AfterMask /= "0" else '0';

end Behavioral;

