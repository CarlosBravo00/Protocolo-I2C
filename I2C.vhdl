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
        SDA : inout std_logic; --SDA = Serial Data/Address  
        SCL : out std_logic; --SCL = Serial Clock  
        I2C_BUSY : out std_logic; 
        DATA_READ: out std_logic_vector(7 downto 0)
    );
end entity;


architecture arch of I2C is
    Type State is(IDLE,ADDR,WDATA,RDATA,TEMP1,TEMP2,SACK,WSACK);
    SIGNAL present:state := IDLE;
    SIGNAL SHIFT_ADD: Std_logic_vector(6 downto 0);
    SIGNAL SHIFT_DAT: Std_logic_vector(7 downto 0);
    SIGNAL SIG_RW : std_logic;
    SIGNAL ACK_FlagADD : std_logic := '1';
    SIGNAL ACK_FlagDAT : std_logic := '1';
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
            I2C_BUSY <= '1';
    else 
    
    if (clk'event and clk = '0') then 
    case present is 
        when IDLE => --Estado inicial SDA=1 & SCL=1
            
             I2C_BUSY <= '1';
             SDA <= '1';
             SCL <= '1';

            if enable = '1' then
                I2C_BUSY <= '1';
                SDA <='0'; 
                present <= ADDR;
                shift_add <= I2C_ADDRESS; --Carga de direccion
                SHIFT_DAT <= I2C_DATA;  --carga de data 
                SIG_RW <= I2C_RW; -- Carga de RW
            else 
               present <= IDLE;
            end if;

        when ADDR => --Direccion y RW

            if incount < x"7" then --Direccion 7 bits 
                SCL <= '0';
                SDA <= shift_add(6);
                shift_add(6 downto 0) <= shift_add(5 downto 0) & 'U' ;
                incount <= incount + 1;
                present <= TEMP1;
                I2C_BUSY <= '1';

            else if incount = x"7" then --RW 1 bit 
                SCL <= '0';
                SDA <= SIG_RW;
                present <= TEMP1;
                incount <= incount + 1;
                I2C_BUSY <= '1';

            else if incount = x"8" then --ACK
                I2C_BUSY <= '0';
                SDA<= 'Z';
                SCL<='0';
                present <= SACK;
            
            else if incount < x"B" then --Count 
                I2C_BUSY <= '1';
                SDA<= '1';
                incount <= incount + 1;
                SCL<='0';
                present <= ADDR;

            else 
                SCL <= '0';
                incount <= x"0";
                if SIG_RW = '0' then 
                present<= WDATA;   
                else 
                present<= RDATA;
                end if;
                
                end if;       
            end if;
          end if;
        end if;

        when SACK =>
                ack_flagADD <= SDA;
                incount <= incount + 1;
                present<=ADDR;
                SCL<='1';

        when WSACK =>
                ack_flagADD <= SDA;
                incount <= incount + 1;
                present<=WDATA;
                SCL<='1';
                

        when WDATA => 
            if incount < x"8" then --Escribir datos 8 bits 
                SCL <= '0';
                SDA <= shift_dat(7);
                shift_dat(7 downto 0) <= shift_dat(6 downto 0) & 'U' ;
                incount <= incount + 1;
                present <= TEMP2;

            else if incount = x"8" then --ACK
                I2C_BUSY <= '0';
                SDA<= 'Z';
                SCL<='0';
                present <= WSACK;
             else 
                SCL<='1';
                SDA<= '1';
                I2C_BUSY <= '1';
                incount <= x"0";
                present <= IDLE;
                end if;
            end if;

        WHEN RDATA =>
               I2C_BUSY <= '0';
                if incount < x"8" then
                    shift_dat(7 downto 0) <= shift_dat(6 downto 0) & SDA;
                    incount <= incount + 1;

                else if incount = x"8" then --ACK
                    I2C_BUSY <= '1';
                    DATA_READ <= shift_dat;
                    SDA <= '1';
                    incount <= incount + 1;
                else 
                   I2C_BUSY <= '1';
                    incount <= x"0";
                    present <= IDLE;
                    end if;
                end if;

        
        when TEMP1 => 
            SCL<= '1';
            present <= ADDR; 

        when TEMP2 => 
            SCL<= '1';
            present <= WDATA; 


        when others => null; 
        end case;

         end if;

    end if;
   end process; 
   
end arch ; -- arch