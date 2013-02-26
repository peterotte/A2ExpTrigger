-- Peter-Bernd Otte
-- 2.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity L1Ch is
    Port ( Input : in  STD_LOGIC;
           VetoIn : in  STD_LOGIC;
           BypassL2Out : out  STD_LOGIC;
           TriggerChOut : out  STD_LOGIC;
           Clear : in  STD_LOGIC;
           SaveInput : in  STD_LOGIC;
			  clock : in STD_LOGIC;
			  StoredBitOut : out std_logic;
			  SelectBypassL2 : in std_logic;
			  SelectUsage_Inv : in std_logic;
			  SelectUsage_DontCare : in std_logic;
			  SelectPreScalerFator : in std_logic_vector(3 downto 0));
end L1Ch;

architecture Behavioral of L1Ch is

	component PreScaler
    generic ( 
				NChLength : integer
			);  
	 Port ( Sig_In : in  STD_LOGIC;
           Sig_Out : out  STD_LOGIC;
           Factor : in  STD_LOGIC_VECTOR (3 downto 0);
			  clock : in std_logic);
	end component;
	
   COMPONENT SingleBitStorage
   PORT( Data	:	IN	STD_LOGIC; 
          Clock	:	IN	STD_LOGIC; 
          Clear	:	IN	STD_LOGIC; 
          Output	:	OUT	STD_LOGIC);
   END COMPONENT;

	COMPONENT SignalUsageSelector
	PORT(
		Input : IN std_logic;
		SelectBypassL2 : IN std_logic;
		SelectUsage_Inv : in  STD_LOGIC;
      SelectUsage_DontCare : in  STD_LOGIC;
		Output : OUT std_logic;
		BypassL2Out : OUT std_logic
		);
	END COMPONENT;

	signal InputAfterVeto : std_logic;
	signal AfterPreScaler : std_logic;
begin

	--Veto of Input
	InputAfterVeto <= '0' when VetoIn = '1' else Input;
	
	--PreScaler with Gate generator
	Inst_Prescaler : PreScaler GENERIC MAP (NChLength => 10) 
		Port MAP ( Sig_In => InputAfterVeto, Sig_Out => AfterPreScaler, Factor => SelectPreScalerFator, clock=>clock);

	--Single Bit Storage
	Inst_SingleBitStorage: SingleBitStorage PORT MAP(
		Data => AfterPreScaler, 
		Clock => SaveInput, 
		Clear => Clear, 
		Output => StoredBitOut
   );

	--Signal Usage Selector
	Inst_SignalUsageSelector: SignalUsageSelector PORT MAP(
		Input => AfterPreScaler,
		SelectBypassL2 => SelectBypassL2,
		SelectUsage_Inv => SelectUsage_Inv,
      SelectUsage_DontCare => SelectUsage_DontCare,
		Output => TriggerChOut,
		BypassL2Out => BypassL2Out
	);

end Behavioral;

