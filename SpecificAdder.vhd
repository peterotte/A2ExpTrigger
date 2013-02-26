-- Peter-Bernd Otte
-- 14.9.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity SpecificAdder is
	Generic (
		NOfInputBits : integer --max 64
	);
    Port ( EnableClusterCouting : in STD_LOGIC;
			  HitPattern : in  STD_LOGIC_VECTOR (NOfInputBits-1 downto 0);
           HitCounts : out  STD_LOGIC_VECTOR (6 downto 0)
			);
end SpecificAdder;

architecture Behavioral of SpecificAdder is

	COMPONENT FlexibleAdder
		generic (SizeOfInput1, SizeOfInput2, SizeOfOutput : integer);
		Port ( BitPattern1 : in  STD_LOGIC_VECTOR (SizeOfInput1-1 downto 0);
           BitPattern2 : in  STD_LOGIC_VECTOR (SizeOfInput2-1 downto 0);
           BitCounts : out  STD_LOGIC_VECTOR (SizeOfOutput-1 downto 0)); --SizeOfOutput always needs to be 1 number greater than biggest
	end COMPONENT;
	
	signal HitPatternBuffer : STD_LOGIC_VECTOR (64-1 downto 0);
	
	type Type_IntermediateAddResult1 is array(0 to 31) of STD_LOGIC_VECTOR(1 downto 0); --64/2-1, max: 2 digits
	signal IntermediateAddResult1 : Type_IntermediateAddResult1;
	type Type_IntermediateAddResult2 is array(0 to 15) of STD_LOGIC_VECTOR(2 downto 0); --64/4-1, max: 3 digits
	signal IntermediateAddResult2 : Type_IntermediateAddResult2;
	type Type_IntermediateAddResult3 is array(0 to 7) of STD_LOGIC_VECTOR(3 downto 0);  --64/8-1
	signal IntermediateAddResult3 : Type_IntermediateAddResult3;
	type Type_IntermediateAddResult4 is array(0 to 3) of STD_LOGIC_VECTOR(4 downto 0);
	signal IntermediateAddResult4 : Type_IntermediateAddResult4;
	type Type_IntermediateAddResult5 is array(0 to 1) of STD_LOGIC_VECTOR(5 downto 0);
	signal IntermediateAddResult5 : Type_IntermediateAddResult5;
	type Type_IntermediateAddResult6 is array(0 to 0) of STD_LOGIC_VECTOR(6 downto 0);
	signal IntermediateAddResult6 : Type_IntermediateAddResult6;

begin
	
	HitPatternBuffer(NOfInputBits-1 downto 0) <= HitPattern when EnableClusterCouting = '1' else (others => '0');
	HitPatternBuffer(64-1 downto NOfInputBits) <= (others => '0');
	
	

	FlexibleAdderStep1: for i in 0 to 64/2-1 generate
   begin
		MyAdder1: FlexibleAdder 
			generic map (SizeOfInput1 => 1, SizeOfInput2 => 1, SizeOfOutput => 2)
			PORT map ( HitPatternBuffer(i*2 downto i*2), HitPatternBuffer(i*2+1 downto i*2+1), IntermediateAddResult1(i) ) ;
	end generate FlexibleAdderStep1;

	FlexibleAdderStep2: for i in 0 to 64/4-1 generate
   begin
		MyAdder2: FlexibleAdder 
			generic map (SizeOfInput1 => 2, SizeOfInput2 => 2, SizeOfOutput => 3)
			PORT map ( IntermediateAddResult1(i*2), IntermediateAddResult1(i*2+1), IntermediateAddResult2(i) ) ;
	end generate FlexibleAdderStep2;
	
	FlexibleAdderStep3: for i in 0 to 64/8-1 generate
   begin
		MyAdder3: FlexibleAdder 
			generic map (SizeOfInput1 => 3, SizeOfInput2 => 3, SizeOfOutput => 4)
			PORT map ( IntermediateAddResult2(i*2), IntermediateAddResult2(i*2+1), IntermediateAddResult3(i) ) ;
	end generate FlexibleAdderStep3;

	FlexibleAdderStep4: for i in 0 to 64/16-1 generate
   begin
		MyAdder4: FlexibleAdder 
			generic map (SizeOfInput1 => 4, SizeOfInput2 => 4, SizeOfOutput => 5)
			PORT map ( IntermediateAddResult3(i*2), IntermediateAddResult3(i*2+1), IntermediateAddResult4(i) ) ;
	end generate FlexibleAdderStep4;

	FlexibleAdderStep5: for i in 0 to 64/32-1 generate
   begin
		MyAdder5: FlexibleAdder 
			generic map (SizeOfInput1 => 5, SizeOfInput2 => 5, SizeOfOutput => 6)
			PORT map ( IntermediateAddResult4(i*2), IntermediateAddResult4(i*2+1), IntermediateAddResult5(i) ) ;
	end generate FlexibleAdderStep5;

	FlexibleAdderStep6: for i in 0 to 64/64-1 generate
   begin
		MyAdder6: FlexibleAdder 
			generic map (SizeOfInput1 => 6, SizeOfInput2 => 6, SizeOfOutput => 7)
			PORT map ( IntermediateAddResult5(i*2), IntermediateAddResult5(i*2+1), IntermediateAddResult6(i) ) ;
	end generate FlexibleAdderStep6;
	
	HitCounts <= IntermediateAddResult6(0);


end Behavioral;

