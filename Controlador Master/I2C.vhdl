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
        I2C_RW: in std_logic; --0 Write 1 Read 
        SDA : inout std_logic; --SDA = Serial Data/Address  
        SCL : out std_logic; --SCL = Serial Clock  
        I2C_BUSY : out std_logic; --1 Busy,0 Espera respuesta
        DATA_READ: out std_logic_vector(7 downto 0)
    );
end entity;


architecture arch of I2C is
    Type State is(IDLE,ADDR,WDATA,RDATA,TEMP1,TEMP2,TEMP3,SACK,WSACK,RACK);
    SIGNAL present:state := IDLE;
    SIGNAL SHIFT_ADD: Std_logic_vector(6 downto 0);--Guarda infor de ADDRESS
    SIGNAL SHIFT_DAT: Std_logic_vector(7 downto 0);--Guarda infor de DATA
    SIGNAL SIG_RW : std_logic; --Guarda infor de RW
    SIGNAL ACK_FlagADD : std_logic := '1'; --ACK address
    SIGNAL ACK_FlagDAT : std_logic := '1';  --ACK data 
    signal incount : unsigned(3 downto 0) := "0000"; --Conteo Interno 
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
                shift_add <= I2C_ADDRESS; --Carga de direccion
                SHIFT_DAT <= I2C_DATA;  --Carga de data 
                SIG_RW <= I2C_RW; --Carga de RW
                present <= ADDR;
            else 
               present <= IDLE;
            end if;

        when ADDR => --Direccion y RW

            if incount < x"7" then --Direccion 7 bits 
                I2C_BUSY <= '1';    
                SCL <= '0';
                SDA <= shift_add(6);
                shift_add(6 downto 0) <= shift_add(5 downto 0) & 'U' ;
                incount <= incount + 1;
                present <= TEMP1; 

            else if incount = x"7" then --RW 1 bit 
                I2C_BUSY <= '1';    
                SCL <= '0';
                SDA <= SIG_RW;
                incount <= incount + 1;
                present <= TEMP1;

            else if incount = x"8" then --ACK
                I2C_BUSY <= '0';
                SDA<= 'Z';
                SCL<='0';
                present <= SACK;
            
            else if incount < x"B" then --Count 
                I2C_BUSY <= '1';
                SDA<= '1';
                SCL<='0';
                incount <= incount + 1;
                present <= ADDR;

            else 
                SCL <= '0';
                incount <= x"0";

                if SIG_RW = '0' then --Write Data
                    present<= WDATA;   
                else  --Read Data
                    SHIFT_DAT <= "UUUUUUUU";
                    I2C_BUSY <= '0'; 
                    SDA <= 'Z';
                    present<= RDATA;
                end if;
         
              end if;       
            end if;
          end if;
        end if;

        when SACK => --ACK de esclavo para address 
                ack_flagADD <= SDA;
                SCL<='1';
                incount <= incount + 1;
                present<=ADDR;

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

             else  --Stop Regresa a IDLE 
                I2C_BUSY <= '1';   
                SCL<='1';
                SDA<= '1';
                incount <= x"0";
                present <= IDLE;
                end if;
            end if;

        when WSACK => --ACK de esclavo para write data 
            ack_flagDAT <= SDA;
            incount <= incount + 1;
            present<=WDATA;
            SCL<='1';
            

        WHEN RDATA => --Read data
                if incount < x"8" then --Lecutra de la data manda esclavo
                    SCL <= '1';
                    shift_dat(7 downto 0) <= shift_dat(6 downto 0) & SDA;
                    incount <= incount + 1;
                    present <= TEMP3;

                else if incount = x"8" then --ACK
                    I2C_BUSY <= '1';    
                    SCL <= '0';
                    DATA_READ <= shift_dat; --Carga de info mandada
                    SDA <= '1'; --ACK
                    incount <= incount + 1;
                    present <= RACK;
                else  --STOP regresa a iddle 
                    I2C_BUSY <= '1';
                    SCL<='1';
                    SDA<= '1';
                    incount <= x"0";
                    present <= IDLE;
                    end if;
                end if;

        when RACK => --ACK read 
            SCL<= '1';
            present <=RDATA;

        --Todos los estados temporales se usan para el control del SCL
        when TEMP1 => 
            SCL<= '1';
            present <= ADDR; 

        when TEMP2 => 
            SCL<= '1';
            present <= WDATA; 

        when TEMP3 =>
            SCL<= '0';
            present <= RDATA; 
                    
        when others => null; 
        end case;

         end if;

    end if;
   end process; 
   
end arch ; --arch
