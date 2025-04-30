library IEEE;
use IEEE.std_logic_1164.ALL;



entity AdrMux is
	port(
		nextAdrMuxSelect: in std_logic_vector(2 downto 0);
		incremented: in std_logic_vector(9 downto 0);
		stack: in std_logic_vector(9 downto 0);
		load: in std_logic_vector(9 downto 0);
		leastSignificantAdded: in std_logic_vector(9 downto 0);
		allBitsAdded: in std_logic_vector(9 downto 0);
		nextAdr: out std_logic_vector(9 downto 0)
	);
end AdrMux;


architecture am of AdrMux is
begin

WITH nextAdrMuxSelect SELECT
	nextAdr <= incremented WHEN "000",
				  leastSignificantAdded WHEN "001",
				  allBitsAdded WHEN "010",	
				  load WHEN "011",
				  stack WHEN "100",
				  incremented WHEN OTHERS;

end am;