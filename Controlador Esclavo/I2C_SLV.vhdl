library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_SLV is
    port(
        I2C_ADDRESS: in std_logic_vector(6 downto 0); --Dirección del Esclavo 
        I2C_DATA: in std_logic_vector(7 downto 0); --Data del Esclavo
        DATA_WRITE: out std_logic_vector(7 downto 0); --Data que recibe el Esclavo
        SCL: in std_logic;--SCL = Serial Clock 
        SDA : inout std_logic; --SDA = Serial Data/Address  
        SLV_BUSY: out std_logic  --1 Busy,0 Espera respuesta
        
    );
end entity;

architecture arch of I2C_SLV  is
    Type State is(IDLE,ADDR,WDATA,RDATA);
    SIGNAL present:state := IDLE;
    SIGNAL SHIFT_ADD: Std_logic_vector(6 downto 0);--Guarda infor de ADDRESS
    SIGNAL SIG_RW : std_logic; --Guarda infor de RW
    SIGNAL SHIFT_DAT: Std_logic_vector(7 downto 0);--Guarda infor de DATA
    signal incount : unsigned(3 downto 0) := "0000"; --Conteo Interno 
    SIGNAL SDA_INPUT:std_logic :='0';
    SIGNAL BUSY_SIGNAL  :std_logic :='0';
begin
 
process(SCL)
begin 
    if (SCL'event and SCL = '0') then 
    
    case present is 
        when IDLE => --Estado inicial      
                BUSY_SIGNAL <= '0';
                if SDA  = '0' then --BIT INICIO 
                    present <= ADDR;
                    SIG_RW <= 'U';
                else 
                    present <= IDLE;
                end if;

        when ADDR => --Direccion y RW

                if incount < x"7" then --Direccion 7 bits   
                    shift_add(6 downto 0) <= shift_add(5 downto 0) & SDA;
                    incount <= incount + 1;
                    present <= ADDR; 

                else if incount = x"7" then --RW 1 bit 
                        if (shift_add = I2C_ADDRESS) then  ---SI LA DIRECCION SENT NO COINCIDE CON LA DEL ESCLAVO REGRESA A IDDLE---           
                            SIG_RW <= SDA;
                            incount <= incount + 1;
                            present <= ADDR;

                            BUSY_SIGNAL <= '1'; 
                            SDA_INPUT<= '1'; --ACK 
                        else 
                            present <= IDLE;
                        end if;

                else 
                    incount <= x"0";
                    BUSY_SIGNAL <= '0';
                    if SIG_RW = '0' then --Write Data
                        SDA_INPUT<= '0';
                        BUSY_SIGNAL <= '0';
                        shift_add <= "UUUUUUU";
                        present<= WDATA; 
                    else                 --Read Data
                        BUSY_SIGNAL <= '1';
                        SDA_INPUT<= '1';
                        shift_dat <= I2C_DATA;
                        present<= RDATA;
                    end if;

               end if;       
            end if;

        when WDATA => 
            if incount < x"7" then --Escribir datos 8 bits 
                 BUSY_SIGNAL <= '0';
                SHIFT_DAT(7 downto 0) <= shift_dat(6 downto 0) & SDA;
                incount <= incount + 1;
                present <= WDATA;

            else if incount = x"7" then 
                SHIFT_DAT(7 downto 0) <= shift_dat(6 downto 0) & SDA;
                incount <= incount + 1;
                present <= WDATA;
                BUSY_SIGNAL <= '1'; 
                SDA_INPUT<= '1'; --ACK

            else if incount = x"8" then 
                BUSY_SIGNAL <= '0';
                SDA_INPUT<= '0';
                DATA_WRITE <=  SHIFT_DAT; --Carga la informacion en el out
                    if ( SDA = '1') then --Stop bit 
                        incount <= x"0";
                        present <= IDLE;
                    else 
                        present<=WDATA;
                    end if;
                end if;
            end if;  
        end if; 


         WHEN RDATA => --Read data
             if incount < x"8" then --Esclavo manda data 
                SDA_INPUT <= shift_dat(7);
                shift_dat(7 downto 0) <= shift_dat(6 downto 0) & 'U' ;
                incount <= incount + 1;
                present <= RDATA;
            
            else if incount = x"8" then  --Espera ACK de Master 
                SDA_INPUT <= shift_dat(7);
                shift_dat(7 downto 0) <= shift_dat(6 downto 0) & 'U' ;
                incount <= incount + 1;
                present <= RDATA;
                BUSY_SIGNAL <= '0';

             else  
                 if (SDA = '1') then --Stop Bit 
                        incount <= x"0";
                         present <= IDLE;
                     else
                         present <= RDATA;
                     end if;

                 end if;
             end if;
                
        when others => null; 
        end case;

         end if;

    end process;

    SLV_BUSY<=BUSY_SIGNAL;  --Carga señal de busy 

    SDA <= SDA_INPUT when (BUSY_SIGNAL = '1') else 'Z'; --Hace SDA input cuando se requiera
    
end arch ; --arch
