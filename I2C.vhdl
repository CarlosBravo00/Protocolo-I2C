library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C is
    port(
        clk: in std_logic;
        I2C_ADDRESS in std_logic_vector(6 downto 0);
        I2C_DATA in std_logic_vector(7 downto 0);
        I2C_RW in std_logic;
        SDA, SCL : out std_logic
    );
end entity;


architecture arch of I2C is
    Type State is(IDLE,ADDR,DATA);
    SIGNAL present:state := IDLE;
    signal incount : unsigned(3 downto 0) := "0000";
begin

process (I2C_clk_filtered)
begin
if enable = '1' then
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