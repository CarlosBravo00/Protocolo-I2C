library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C is
    port(
        I2C_DATA, I2C_RW, clk , reset, RW : in std_logic;
        SDA : out std_logic_vector( 7 downto 0);
        SCL : out std_logic
    );
end entity;


architecture arch of I2C is
    signal I2C_clk_filtered : std_logic;
    signal incount : unsigned(3 downto 0) := "0000";
    signal filter : std_logic_vector(z downto 0);

begin

    -- Filtrar señal de reloj
    clock_filter : process
    begin
        wait until clk'event and clk = '1'; -- rising_edge(clk)
        filter(6 downto 0) <= filter(7 downto 1);
        filter(7) <= I2C_clk;
        if filter = x"FF" then -- "1111111"
            I2C_clk_filtered <= '1';
        elsif filter = x"00" then  -- "0000000"
            I2C_clk_filtered <= '0';
        end if;
    end process;


--Corrimiento a derecha, esta solo es la lectura de los 8 data

process (I2C_clk_filtered)
begin
if reset = '1' then
    incount <= x"0";

 else 
    if (I2C_clk_filtered'event and I2C_clk_filtered = '0') then --rising_edge(filtered)
    case present is 

        when IDLE =>
            present <= RUN;

      when RUN => -- Shift enl siguientes 8 bits para construir el scan code
         if incount < x"9" then
          shift_in(7 downto 0) <= shift_in(8 downto 1);
          shift_in(8) <= I2C_data;
          incount <= incount + 1;
     else 
        scan_code <= shift_in(7 downto 0);
        incount <= x"0";
        present <= IDLE;

    end if;
        when others => null; 
        end case;
         end if;

    end if;
   end process; 
   

end arch ; -- arch