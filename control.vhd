library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;


entity control is
	port(
		clk: in std_logic;
		instr: in std_logic_vector(15 downto 0); --aktualna mikroinstrukcja
		X: in std_logic_vector(7 downto 0); --wejścia
		push: out std_logic; --sygnal czy wpisac na stos adres powrotu
		nextAdrMuxSelect: out std_logic_vector(2 downto 0); --sygnal do multipleksera wybierającego następny adres
		Y0s: inout std_logic; --sygnal czy dac na wyjscia najmniej znaczace bity: 1-tak, 0-nie
		Y1s: inout std_logic --sygnal czy dac na wyjscia bardziej znaczace bity: 1-tak, 0-nie
	);


end control;


architecture ca of control is

	constant opcodeLenMinus1: integer := 3;
	constant nop: std_logic_vector(opcodeLenMinus1 downto 0) := "0000";
	constant set: std_logic_vector(opcodeLenMinus1 downto 0) := "0001";
	constant load: std_logic_vector(opcodeLenMinus1 downto 0) := "0010";
	constant jump: std_logic_vector(opcodeLenMinus1 downto 0) := "0011";
	constant call: std_logic_vector(opcodeLenMinus1 downto 0) := "0100";
	constant ret: std_logic_vector(opcodeLenMinus1 downto 0) := "0101";
	
	
	--signal opcode: std_logic_vector(opcodeLenMinus1 downto 0);
	
begin

process(instr)
	variable opcode: std_logic_vector(opcodeLenMinus1 downto 0) := instr(15 downto 12); 
	variable cond: std_logic := instr(11);
	variable notBit: std_logic := instr(10);
	variable condNr: std_logic_vector(4 downto 0) := instr(9 downto 5);

begin	



	if opcode=nop then nextAdrMuxSelect <= "000";
		--Y0s <= '0';
		--Y1s <= '0';
	end if;
	

	if opcode=set then nextAdrMuxSelect <= "000";
			Y0s <= '0';
	Y1s <= '0';
		if cond='1' then
			if notBit='0' then
				if X(to_integer(unsigned(condNr)))='1' then
					Y0s <= '1';
				end if;
			else 
			 if X(to_integer(unsigned(condNr)))='0' then
					Y0s <= '1';
			 end if;
			end if;
		else
			Y0s <= '1';
			Y1s <= '1';
		end if;
	end if;
	
	
	if opcode=load then
		Y0s <= '0';
	Y1s <= '0';
		if cond='0' then
			if notBit='0' then
				if X(to_integer(unsigned(condNr)))='1' then
					nextAdrMuxSelect <= "011"; --Adres z kolejki
				else
					nextAdrMuxSelect <= "000";
					end if;
			else
				if X(to_integer(unsigned(condNr)))='0' then
					nextAdrMuxSelect <= "011";
				else
					nextAdrMuxSelect <= "000";
				end if;	
			end if;
		else
			nextAdrMuxSelect <= "011"; --Adres z kolejki
		end if;
	end if;
	
	
	if opcode=jump then 
		Y0s <= '0';
	Y1s <= '0';
		if cond='0' then
			if notBit='0' then
				if X(to_integer(unsigned(condNr)))='1' then
					nextAdrMuxSelect <= "001"; --część Y0 bitów mikroinstrukcji dodane do bieżącego adresu
				else
					nextAdrMuxSelect <= "000";
				end if;
			else
				if X(to_integer(unsigned(condNr)))='0' then
					nextAdrMuxSelect <= "001";
				else
					nextAdrMuxSelect <= "000";
				end if;	
			end if;
			
		else
			nextAdrMuxSelect <= "010"; --część Y0+Y1 bitów mikroinstrukcji będzie adresem
		end if;
	end if;
	
	
	if opcode=call then 
		Y0s <= '0';
	Y1s <= '0';
		if cond='0' then
			if notBit='0' then
				if X(to_integer(unsigned(condNr)))='1' then
					push <= '1';
					nextAdrMuxSelect <= "001"; --część Y0 bitów mikroinstrukcji dodane do bieżącego adresu
				else
					nextAdrMuxSelect <= "000";
				end if;
			else
				if X(to_integer(unsigned(condNr)))='0' then
					push <= '1';
					nextAdrMuxSelect <= "001";
				else
					nextAdrMuxSelect <= "000";
				end if;	
			end if;
		else
			push <= '1';
			nextAdrMuxSelect <= "010";  --część Y0+Y1 bitów mikroinstrukcji będzie adresem
		end if;
	end if;
	
	
	if opcode=ret then 
		Y0s <= '0';
	Y1s <= '0';
		nextAdrMuxSelect <= "100"; --adres ze stosu
	end if;


end process;


end ca;