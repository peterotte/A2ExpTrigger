-- Peter-Bernd Otte
-- 2.4.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity VMEbusCh is
    Port ( Interrupt : in  STD_LOGIC;
				Interrupt_Delayed : out std_logic;
				SingleCPUReadoutComplete : in  STD_LOGIC;
				Reset : in STD_LOGIC;
				clock : in std_logic;
				SelectIncludeCPU : in  STD_LOGIC;
				SelectInterruptDelayTime : in std_logic_vector(15 downto 0);
				CPUbusyOut : out  STD_LOGIC;
				Debug_Out : out STD_LOGIC);
end VMEbusCh;

architecture Behavioral of VMEbusCh is

   COMPONENT SingleBitStorage
   PORT( Data	:	IN	STD_LOGIC; 
          Clock	:	IN	STD_LOGIC; 
          Clear	:	IN	STD_LOGIC; 
          Output	:	OUT	STD_LOGIC;
          CE	:	IN	STD_LOGIC);
   END COMPONENT;
	
	COMPONENT gate_by_shiftreg
	Generic (
		WIDTH : integer
	);
	PORT(
		CLK : IN std_logic;
		SIG_IN : IN std_logic;          
		GATE_OUT : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT DelayByCounterFixedWidth
		Generic (
			OutputTime : integer := 4
		);
		 Port ( Clock : in  STD_LOGIC;
				  Input : in  STD_LOGIC;
					DelayTime : in STD_LOGIC_VECTOR(15 downto 0);
				  ExternalReset : in std_logic;
				  DelayedOutput : out  STD_LOGIC);
	end COMPONENT;

	signal SingleCPUReadoutComplete_Inverted, SingleCPUReadoutComplete_Inverted_Gated : std_logic;
	signal Inter_CPUBusy : std_logic;
	signal Inter_Reset : std_logic;
	signal Inter_Interrupt_Delayed, Inter_Interrupt_Delayed_2 : std_logic;
begin
	-- Convert ACK signal into Reset signal (gated)
	SingleCPUReadoutComplete_Inverted <= not SingleCPUReadoutComplete;
	Inst_gate_by_shiftreg: gate_by_shiftreg GENERIC MAP (
		WIDTH => 3
	) PORT MAP(
		CLK => clock,
		SIG_IN => SingleCPUReadoutComplete_Inverted,
		GATE_OUT => SingleCPUReadoutComplete_Inverted_Gated
	);
	Debug_Out <= SingleCPUReadoutComplete_Inverted_Gated;

	
	--Reset can come from CPU or MasterReset
	Inter_Reset <= Reset or SingleCPUReadoutComplete_Inverted_Gated;

	--Single Bit Storage
	Inst_SingleBitStorage: SingleBitStorage PORT MAP(
		Data => '1', 
		Clock => Interrupt, 
		Clear => Inter_Reset, 
		Output => Inter_CPUBusy,
		CE => '1'
   );
	process (clock)
	begin
		if rising_edge(clock) then
			
		end if;
	end process;
	
	--Delay of Interrupt signal send to CPU
	Inst_DelayByCounterFixedWidth: DelayByCounterFixedWidth
		Generic MAP (
			OutputTime => 3
		)
		 Port MAP ( Clock => clock,
				  Input => Interrupt,
					DelayTime => SelectInterruptDelayTime,
				  ExternalReset => Reset,
				  DelayedOutput => Inter_Interrupt_Delayed
		);
	--Single Bit Storage for Delayed Interrupt signal
	Inst_SingleBitStorage_2: SingleBitStorage PORT MAP(
		Data => '1', 
		Clock => Inter_Interrupt_Delayed, 
		Clear => Inter_Reset, 
		Output => Inter_Interrupt_Delayed_2,
		CE => '1'
   );
	Interrupt_Delayed <= Inter_Interrupt_Delayed_2 when SelectIncludeCPU = '1' else '0';
	
	--
	CPUbusyOut <= Inter_CPUBusy when SelectIncludeCPU = '1' else '0';

end Behavioral;

