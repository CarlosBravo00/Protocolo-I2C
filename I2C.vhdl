library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C is
    port(
        I2C_clk,clk_25Mhz : in std_logic
    );
end entity;


architecture arch of I2C is
    signal I2C_clk_filtered : std_logic;
    signal filter : std_logic_vector(7 downto 0);

begin

    -- Filtrar señal de reloj
    clock_filter : process
    begin
        wait until clk_25Mhz'event and clk_25Mhz = '1'; -- rising_edge(clk)
        filter(6 downto 0) <= filter(7 downto 1);
        filter(7) <= I2C_clk;
        if filter = x"FF" then -- "1111111"
            I2C_clk_filtered <= '1';
        elsif filter = x"00" then  -- "0000000"
            I2C_clk_filtered <= '0';
        end if;
    end process;


--Corrimiento a derecha, esta solo es la lectura de los 8 data
    if read_char = '1' then --Validacion para leer 
        if incount  < x"9" then 
            incount <= incount + 1;
            shift_in(7 downto 0) <= shift_in(8 downto 1);
            shift_in(8) <= keyboard_data;
            ready_set <= '0';
        else
            scan_code <= shift_in(7 downto 0);
            read_char <= '0';
            ready_set <= '1';
            incount <= x"0";
        end if;
    end if;


end arch ; -- arch