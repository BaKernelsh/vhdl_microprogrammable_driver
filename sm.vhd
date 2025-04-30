library IEEE;
use IEEE.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

entity sm is
	port(clk: in std_logic;
		  X: in std_logic_vector(7 downto 0);
		  Y: out std_logic_vector(10 downto 0);
		  adr: out std_logic_vector(9 downto 0);
		  instr: out std_logic_vector(15 downto 0)
	);
	
end sm;


architecture a of sm is

	 COMPONENT Single_port_RAM_VHDL
    PORT(
         RAM_ADDR : IN  std_logic_vector(9 downto 0);
         RAM_WR : IN  std_logic;
         RAM_DATA_OUT : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
	 
	 COMPONENT control
	 PORT(
			clk: in std_logic;
			instr: in std_logic_vector(15 downto 0); --aktualna mikroinstrukcja
			X: in std_logic_vector(7 downto 0); --wejścia
			push: out std_logic; --sygnal czy wpisac na stos adres powrotu
			nextAdrMuxSelect: out std_logic_vector(2 downto 0); --sygnal do multipleksera wybierającego następny adres
			Y0s: out std_logic; --sygnal czy dac na wyjscia najmniej znaczace bity: 1-tak, 0-nie
			Y1s: out std_logic --sygnal czy dac na wyjscia bardziej znaczace bity: 1-tak, 0-nie
	 );
	 END COMPONENT;
	 
	 COMPONENT AdrMux
	 PORT(
			nextAdrMuxSelect: in std_logic_vector(2 downto 0);
			incremented: in std_logic_vector(9 downto 0);
			stack: in std_logic_vector(9 downto 0);
			load: in std_logic_vector(9 downto 0);
			leastSignificantAdded: in std_logic_vector(9 downto 0);
			allBitsAdded: in std_logic_vector(9 downto 0);
			nextAdr: out std_logic_vector(9 downto 0)
	 );
	 END COMPONENT;
	 

	signal instrReg: std_logic_vector(15 downto 0) := (others => '0');
	signal readInstrSignal: std_logic := '0';
	
	signal InstructionAddr: std_logic_vector(9 downto 0) := (others => '0');
	signal nextAdrMuxSelect: std_logic_vector(2 downto 0) := (others => '0');
	signal adrIncremented: std_logic_vector(9 downto 0) := (others => '0');
	signal adrFromStack: std_logic_vector(9 downto 0) := (others => '0');
	signal adrFromQueue: std_logic_vector(9 downto 0) := (others => '0');
	signal adrWithLeastSignificantBitAdded: std_logic_vector(9 downto 0) := (others => '0');
	signal adrWithAllBitsAdded: std_logic_vector(9 downto 0) := (others => '0');
	
	signal stackPushSignal: std_logic := '0';
	signal writeLowerBitsToY: std_logic := '0';
	signal writeHigherBitsToY: std_logic := '0';

begin

	adrMultiplexer: AdrMux
		port map(nextAdrMuxSelect,adrIncremented,adrFromStack,adrFromQueue,
					adrWithLeastSignificantBitAdded,adrWithAllBitsAdded, InstructionAddr
		);
		
	pamiec: Single_port_RAM_VHDL
		port map(InstructionAddr,readInstrSignal,instrReg);
		
	cntrl: control
		port map(clk,instrReg,X,stackPushSignal,nextAdrMuxSelect,writeLowerBitsToY,writeHigherBitsToY);


process (clk)
begin
if(rising_edge(clk)) then
	
	readInstrSignal <= '1';
	adrIncremented <= InstructionAddr + "0000000001";
	
	if writeLowerBitsToY='1' then
		Y(4 downto 0) <= instrReg(4 downto 0);
	end if;
	
	if writeHigherBitsToY='1' then
		Y(10 downto 5) <= instrReg(10 downto 5);
	end if;
	
	adr <= InstructionAddr;
	instr <= instrReg;
	
	readInstrSignal <= '0';
	--writeLowerBitsToY <= '0';
	--writeHigherBitsToY <= '0';

end if;

end process;


end a;