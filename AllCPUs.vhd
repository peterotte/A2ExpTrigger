-- Peter-Bernd Otte
-- 2.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity AllCPUs is
	generic (
		NVMEbusChs : integer
	);
    Port ( ExpTriggerIn : in  STD_LOGIC;
				Interrupt_Delayed : out std_logic_vector(NVMEbusChs-1 downto 0);
			  SingleVMECPUsReadoutComplete : in  STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
           ReadoutCompleteReset : out  STD_LOGIC;
			  Reset : in std_logic;
			  SingleVMECPUsBusy : out  STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
			  SelectIncludeCPU : in  STD_LOGIC_VECTOR(NVMEbusChs-1 downto 0);
			  SelectInterruptDelayTimes : in std_logic_vector(NVMEbusChs*16-1 downto 0);
           VMECPUsBusy : out  STD_LOGIC;
			  clock100 : in  std_logic;
			  Debug_Out : out std_logic_vector(NVMEbusChs-1 downto 0));
end AllCPUs;

architecture Behavioral of AllCPUs is
	COMPONENT VMEbusCh
	PORT(
		Interrupt : IN std_logic;
		Interrupt_Delayed : out std_logic;
		SingleCPUReadoutComplete : in  STD_LOGIC;
		Reset : in STD_LOGIC;
		clock : in std_logic;
		SelectIncludeCPU : IN std_logic;   
		SelectInterruptDelayTime : in std_logic_vector(15 downto 0);
		CPUbusyOut : OUT std_logic;
		Debug_Out : out STD_LOGIC
		);
	END COMPONENT;
	
	component GateShortener
		generic ( 
			NCh : integer
		);  
		Port ( sig_in : in  STD_LOGIC;
			  sig_out : out  STD_LOGIC;
			  clock : in  STD_LOGIC);
	end component;
	
	signal Inter_ReadoutCompleteReset : std_logic;
	attribute keep : string;
	attribute keep of Inter_ReadoutCompleteReset: signal is "TRUE";
	
	signal Inter_VMECPUsBusy : std_logic_vector(NVMEbusChs-1 downto 0);
	signal Pre_VMECPUsBusy, Pre_VMECPUsBusy_Inv : std_logic;
begin

	AllVMEbusChs: for i in 0 to NVMEbusChs-1 generate
   begin
		Inst_VMEbusCh: VMEbusCh PORT MAP(
			Interrupt => ExpTriggerIn,
			Interrupt_Delayed => Interrupt_Delayed(i),
			SingleCPUReadoutComplete => SingleVMECPUsReadoutComplete(i),
			Reset => Reset,
			clock => clock100,
			SelectIncludeCPU => SelectIncludeCPU(i),
			SelectInterruptDelayTime => SelectInterruptDelayTimes(16*i+15 downto 16*i),
			CPUbusyOut => Inter_VMECPUsBusy(i),
			Debug_Out => Debug_Out(i)
		);
	end generate;
	SingleVMECPUsBusy <= Inter_VMECPUsBusy;
	Pre_VMECPUsBusy <= '1' when Inter_VMECPUsBusy /= "0" else '0';
	Pre_VMECPUsBusy_Inv <= not Pre_VMECPUsBusy;
	
	GateShortener_1 : GateShortener GENERIC MAP (NCh => 4) PORT MAP (sig_in => Pre_VMECPUsBusy_Inv, sig_out => Inter_ReadoutCompleteReset, clock => clock100);

	ReadoutCompleteReset <= Inter_ReadoutCompleteReset;

	VMECPUsBusy <= Pre_VMECPUsBusy;

end Behavioral;

