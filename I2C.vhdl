library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C is
    port(
        clk: in std_logic;
        enable: in std_logic;
        I2C_ADDRESS: in std_logic_vector(6 downto 0);
        I2C_DATA: in std_logic_vector(7 downto 0);
        I2C_RW: in std_logic;
        SDA, SCL : out std_logic
    );
end entity;


architecture arch of I2C is
    Type State is(IDLE,ADDR,DATA,tempa,tempb);
    SIGNAL present:state := IDLE;
    SIGNAL SHIFT_ADD: Std_logic_vector(6 downto 0);
    SIGNAL SHIFT_DAT: Std_logic_vector(7 downto 0);
    signal incount : unsigned(3 downto 0) := "0000";
begin

process (clk)
begin
    if (clk'event and clk = '0') then 
    case present is 
        when IDLE =>

             SDA <= '1';
             SCL <= '1';
             shift_add <= "0000000";
             SHIFT_DAT <= "00000000";

            if enable = '1' then
            present <= ADDR;
            shift_add <= I2C_ADDRESS;
            else 
            present <= IDLE;
            end if;

        when ADDR =>
            SCL <= '0';
            if incount < x"7" then
                SDA <= shift_add(6);
                shift_add(6 downto 0) <= shift_add(5 downto 0) & 'U' ;
                incount <= incount + 1;
                present <= tempa;

            else if incount = x"7" then
                SDA <= I2C_RW;
                present <= tempa;
                incount <= incount + 1;

            else if  incount < x"A" then
                incount <= incount + 1;
                SDA<= '1';
                present <= ADDR;

            else 
                incount <= x"0";
                SHIFT_DAT <= I2C_DATA; 
                present<= DATA;   
                
                end if;       
            end if;
         end if;

        when data => 
            SCL <= '0';
            if incount < x"8" then
                SDA <= shift_dat(7);
                shift_dat(7 downto 0) <= shift_dat(6 downto 0) & 'U' ;
                incount <= incount + 1;
                present <= tempb;

            else 
                incount <= x"0";
                present <= IDLE;
                
            end if;
        

        when tempa => 
            SCL<= '1';
            present <= ADDR; 

        when tempb => 
            SCL<= '1';
            present <= data; 

        when others => null; 
        end case;

         end if;
   end process; 
   
end arch ; -- arch