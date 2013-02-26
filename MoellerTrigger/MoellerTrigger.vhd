library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

ENTITY MoellerTrigger is
	PORT (
		TChL  : in STD_LOGIC_VECTOR(159 downto 96);
		TChR  : in STD_LOGIC_VECTOR(255 downto 224);
		TriggerOut : OUT STD_LOGIC;
		InhibitOutput : in STD_LOGIC; -- used e.g. when MAMI Source state is undetermined
		CLOCK : IN STD_LOGIC
     );
END MoellerTrigger;

ARCHITECTURE behavior OF MoellerTrigger IS
	-- All tagger channels starting with 0!
	constant AnzahlAnLogikEintraegen : integer := 16;
	signal ZwischenL : STD_LOGIC_vector(159 downto 96); -- G and H
	signal ZwischenR : STD_LOGIC_vector(255 downto 224); -- O and P
	signal EnergiePaar : STD_LOGIC_vector(AnzahlAnLogikEintraegen downto 1);
	
	component ChannelCombination is
		Generic (
			Width : integer			);
		PORT (
			EingangLinks : in STD_LOGIC;
			EingaengeRechts : in STD_LOGIC_VECTOR(Width-1 downto 0);
			Ausgang : out STD_LOGIC
		);
	end component;
	
	component InputStretcher is
	Generic (
		Duration : integer := 1		);
		PORT (
			Clock : in STD_LOGIC;
			Input : in STD_LOGIC;
			Output : out STD_LOGIC
		);
	end component;
	
	type TKoinzidenzenLogik is array(1 to AnzahlAnLogikEintraegen, 1 to 4) of integer;
	constant KoinzidenzenLogik : TKoinzidenzenLogik := 
		( 
			(130, 252, 255, 4), 
			(131, 251, 254, 4), 
			(132, 250, 253, 4), 
			(133, 249, 252, 4), 
			(134, 248, 251, 4), 
			(135, 247, 250, 4), 
			(136, 246, 249, 4), 
			(137, 245, 248, 4), 
			(138, 245, 248, 4), 
			(139, 244, 247, 4), 
			(140, 243, 246, 4), 
			(141, 242, 245, 4), 
			(142, 241, 244, 4), 
			(143, 240, 243, 4), 
			(144, 239, 242, 4), 
			(145, 238, 241, 4)
		);
--( 
--			(126, 246, 255, 10),
--			(126, 246, 255, 10)
--		);
	
	signal MoellerTrigger_Short : std_logic;
BEGIN
	--Vorbereiten der Eingänge
	TChLD128to159: for i in 96 to 127 generate
	begin
		TChLDi : InputStretcher generic map (Duration => 2) port map (Clock, TChL(i), ZwischenL(i));
	end generate;
	TChRD224to255: for i in 224 to 255 generate
	begin
		TChRDi : InputStretcher generic map (Duration => 2) port map (Clock, TChR(i), ZwischenR(i));
	end generate;

	--Koinzidenzen herstellen
	--Ccomb: for i in 1 to AnzahlAnLogikEintraegen generate
	Ccomb: for i in 1 to 1 generate
	begin
		Ccombi: ChannelCombination 
			generic map (Width => KoinzidenzenLogik(i,4)) 
			port map (ZwischenL(KoinzidenzenLogik(i,1)), 
				ZwischenR(KoinzidenzenLogik(i,3) downto KoinzidenzenLogik(i,2)),
				EnergiePaar(i));
	end generate;
	
	-- Triggersignal ausgeben
	MoellerTrigger_Short <= '1' when ((EnergiePaar /= "0") and (InhibitOutput = '0')) else '0';

	TriggerOutStretcher: InputStretcher generic map (Duration => 2) port map (Clock, MoellerTrigger_Short, TriggerOut);

END behavior;


-- Old: 13.7.2009
--	constant KoinzidenzenLogik : TKoinzidenzenLogik := 
--		( 
--			(130, 252, 255, 4), 
--			(131, 251, 254, 4), 
--			(132, 250, 253, 4), 
--			(133, 249, 252, 4), 
--			(134, 248, 251, 4), 
--			(135, 247, 250, 4), 
--			(136, 246, 249, 4), 
--			(137, 245, 248, 4), 
--			(138, 245, 248, 4), 
--			(139, 244, 247, 4), 
--			(140, 243, 246, 4), 
--			(141, 242, 245, 4), 
--			(142, 241, 244, 4), 
--			(143, 240, 243, 4), 
--			(144, 239, 242, 4), 
--			(145, 238, 241, 4)
--		);
