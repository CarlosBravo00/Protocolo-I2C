library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C is
    port(
        clk: in std_logic;
        enable: in std_logic;
        reset: in std_logic; 
        I2C_ADDRESS: in std_logic_vector(6 downto 0);
        I2C_DATA: in std_logic_vector(7 downto 0);
        I2C_RW: in std_logic; --0 Write  1 Read 
        SDA, SCL : out std_logic --SDA = Serial Data  SCL = Serial Clock
    );
end entity;


architecture arch of I2C is
    Type State is(IDLE,ADDR,DATA,TEMP1,TEMP2);
    SIGNAL present:state := IDLE;
    SIGNAL SHIFT_ADD: Std_logic_vector(6 downto 0);
    SIGNAL SHIFT_DAT: Std_logic_vector(7 downto 0);
    signal incount : unsigned(3 downto 0) := "0000";
begin

process (clk)
begin
    if reset = '1' then 
            SDA <= '1';
            SCL <= '1';
            shift_add <= "0000000";
            SHIFT_DAT <= "00000000";
            incount <= x"0";
            present <= IDLE;
    else 

    if (clk'event and clk = '0') then 
    case present is 
        when IDLE => --Estado inicial SDA=1 & SCL=1

             SDA <= '1';
             SCL <= '1';
             shift_add <= "0000000";
             SHIFT_DAT <= "00000000";

            if enable = '1' then
                present <= ADDR;
                shift_add <= I2C_ADDRESS; --Carga de direccion
                SHIFT_DAT <= I2C_DATA;  --carga de data 
            else 
               present <= IDLE;
            end if;

        when ADDR => --Direccion y RW
            SCL <= '0';
            if incount < x"7" then --Direccion 7 bits 
                SDA <= shift_add(6);
                shift_add(6 downto 0) <= shift_add(5 downto 0) & 'U' ;
                incount <= incount + 1;
                present <= TEMP1;

            else if incount = x"7" then --RW 1 bit 
                SDA <= I2C_RW;
                present <= TEMP1;
                incount <= incount + 1;

            else if incount = x"8" then --ACK
                present <= TEMP1;
                incount <= incount + 1;
                if (shift_add = "UUUUUUU") then 
                SDA <= '0';
                else 
                SDA <= '1';
                end if;

            else if  incount < x"A" then --Dos peridodos entre Direccion y data 
                incount <= incount + 1;
                SDA<= '1';
                present <= ADDR;

            else 
                incount <= x"0";
                present<= DATA;   
                
                end if;       
            end if;
          end if;
         end if;

        when DATA => 
            SCL <= '0';
            if incount < x"8" then --Escribir datos 8 bits 
                SDA <= shift_dat(7);
                shift_dat(7 downto 0) <= shift_dat(6 downto 0) & 'U' ;
                incount <= incount + 1;
                present <= TEMP2;

            else if incount = x"8" then --ACK
                    if (shift_dat = "UUUUUUUU") then 
                     SDA <= '0';
                    else 
                     SDA <= '1';
                    end if;
                present <= TEMP2;
                incount <= incount + 1;

                else 
                incount <= x"0";
                present <= IDLE;
                end if;
            end if;
        
        when TEMP1 => 
            SCL<= '1';
            present <= ADDR; 

        when TEMP2 => 
            SCL<= '1';
            present <= data; 

        when others => null; 
        end case;

         end if;

    end if;
   end process; 
   
end arch ; -- arch