library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


ENTITY LCD IS
  PORT(
    S1, S2, S3, S4 :IN STD_LOGIC;
    clk        : IN    STD_LOGIC;  --CLK
    reset_n    : IN    STD_LOGIC;  --PIN DE RESET 
    rw, rs, e  : OUT   STD_LOGIC;  --SALIDAS PARA EL CONTROL RS, RW y E
    lcd_data   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0)); --SALIDA DE SEÑALES DB0 a DB7 
END LCD;

ARCHITECTURE controller OF LCD IS
  TYPE CONTROL IS(power_up, initialize, WRT, SEND1, SEND2, SEND3, SEND4, CLR);-- ESTADOS A UTILIZAR
  SIGNAL    state      : CONTROL;
  CONSTANT  freq       : INTEGER := 50; --Frecuencia de reloj del sistema
BEGIN

  PROCESS(clk)
    VARIABLE clk_count : INTEGER := 0; --CONTADOR PARA RETARDOS 
  BEGIN

  IF(clk'EVENT and clk = '1') THEN
    
      CASE state IS
        
        --ESPERA 50ms Y PONE RS,RW a 0 PARA PODER INICIAR LA CONFIGURACION
        WHEN power_up =>
          IF(clk_count < (50000 * freq)) THEN    --ESPERA 50 ms
            clk_count := clk_count + 1;
            state <= power_up;
          ELSE                                   --ESTADO COMPLETO 
            clk_count := 0;
            rs <= '0';
            rw <= '0';
            state <= initialize;   --SALTO AL ESTADO DE INICIALIZACION 
          END IF;
          
        --ESTADO PARA LA CONFIGURACION DE INICIALIZACION DE LA LCD
        WHEN initialize =>
          clk_count := clk_count + 1;
          IF(clk_count < (10 * freq)) THEN       --function set
            lcd_data <= "00111100";      --USO DE 2 LINEAL Y ENCENDIDO DEL DISPLAY 
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (60 * freq)) THEN    --ESPERA 50us 
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSIF(clk_count < (70 * freq)) THEN    --display on/off control
            lcd_data <= "00001110";    --display on, cursor on, blink off           
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (120 * freq)) THEN   --ESPERA 50 us
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSIF(clk_count < (130 * freq)) THEN   --display clear
            lcd_data <= "00000001";
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (2130 * freq)) THEN  --wait 2 ms
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSIF(clk_count < (2140 * freq)) THEN  --entry mode set
            lcd_data <= "00000110";      --increment mode, entire shift off
            e <= '1';
            state <= initialize;
          ELSIF(clk_count < (2200 * freq)) THEN  --ESPERA 60 us
            lcd_data <= "00000000";
            e <= '0';
            state <= initialize;
          ELSE                                   --INICIALIZACION COMPLETA
            clk_count := 0;
            state <= WRT;
          END IF;  
		
--ESCRIBIMOS EN LA LCD		
				
        WHEN WRT=>          ----MONITOREO DE LOS SWITCHES PARA DESPLEGAR LOS MENSAJES 
        IF (S1='1') THEN   
            state <= SEND1;
        ELSIF(S2='1') THEN
            state <= SEND2; 
        ELSIF (S3='1') THEN 
            state <= SEND3;
        ELSIF (S4='1') THEN
            state <= SEND4;
        ELSE 
            --clk_count :=0;
            state <= WRT;
        END IF;
	
--------------------------- MENSALE 1 (@TEC) SI EL SWITCH 1 ES ACTIVADO----------------------	
          WHEN SEND1=>
			 	
			 rs <= '1';
          rw <= '0';
			 clk_count := clk_count + 1;
			 IF(clk_count < (70 * freq)) THEN    
            lcd_data <= "01000000";      
            e <= '1';
          ELSIF(clk_count < (120 * freq)) THEN    --wait 
            e <= '0';
          ELSIF(clk_count < (130 * freq)) THEN   
            lcd_data <= "01010100"; 
            e <= '1';				
          ELSIF(clk_count < (2130 * freq)) THEN   --wait
            e <= '0';
          ELSIF(clk_count < (2140 * freq)) THEN 
            lcd_data <= "01000101";
            e <= '1';
          ELSIF(clk_count < (2200 * freq)) THEN  --wait 
            e <= '0';
          ELSIF(clk_count < (2400 * freq)) THEN  
            lcd_data <= "01000011";     
            e <= '1';
          ELSIF(clk_count < (2600 * freq)) THEN  --wait 
            e <= '0';
			   state <= WRT;	

			 ELSIF (S1='0') THEN
			 state<=CLR;        --NOS LIMPIA LA LDC YA QUE SE DESACTIVA EL SWITCH 1 
			 clk_count := 0;
			 END IF;


			 --------------------------- MENSALE 2 (VHDL) SI EL SWITCH 2 ES ACTIVADO----------------------
			 
WHEN SEND2=>
			  
			 rs <= '1';
          rw <= '0';
          clk_count := clk_count + 1;
			 IF(clk_count < (70 * freq)) THEN    
            lcd_data <= "01010110";  ----V
            e <= '1';
          ELSIF(clk_count < (120 * freq)) THEN    --wait 
            e <= '0';
          ELSIF(clk_count < (130 * freq)) THEN   
            lcd_data <= "01001000"; -----H
            e <= '1';				
          ELSIF(clk_count < (2130 * freq)) THEN   --wait 
            e <= '0';
          ELSIF(clk_count < (2140 * freq)) THEN 
            lcd_data <= "01000100";----D
            e <= '1';
          ELSIF(clk_count < (2200 * freq)) THEN  --wait 
            e <= '0';
          ELSIF(clk_count < (2400 * freq)) THEN  
            lcd_data <= "01001100";  ---L   
            e <= '1';
          ELSIF(clk_count < (2600 * freq)) THEN  --wait
            e <= '0';
			   state <= WRT;	
			 ELSIF (S2='0') THEN
			 state<=CLR;
			 clk_count := 0;
			 END IF;
			
		
	--------------------------- MENSALE 3 (2021) SI EL SWITCH 3 ES ACTIVADO----------------------	
WHEN SEND3=>

			 rs <= '1';
          rw <= '0';
			 clk_count := clk_count + 1;
			 IF(clk_count < (70 * freq)) THEN    
            lcd_data <= "00110010";      --2
            e <= '1';
          ELSIF(clk_count < (120 * freq)) THEN    --wait
            e <= '0';
          ELSIF(clk_count < (130 * freq)) THEN   
            lcd_data <= "00110000"; ---0
            e <= '1';				
          ELSIF(clk_count < (2130 * freq)) THEN   --wait
            e <= '0';
          ELSIF(clk_count < (2140 * freq)) THEN 
            lcd_data <= "00110010"; ---2
            e <= '1';
          ELSIF(clk_count < (2200 * freq)) THEN  --wait
            e <= '0';
          ELSIF(clk_count < (2400 * freq)) THEN  
            lcd_data <= "00110001";     --1
            e <= '1';
          ELSIF(clk_count < (2600 * freq)) THEN  --wait
            e <= '0';
			   state <= WRT;	
			 ELSIF (S3='0') THEN
			 state<=CLR;
			 clk_count := 0;
			 END IF;
			 
			 
			 --------------------------- MENSALE 4 (DATA) SI EL SWITCH 4 ES ACTIVADO----------------------
WHEN SEND4=>
			   
			 rs <= '1';
          rw <= '0';
			  clk_count := clk_count + 1;
			 IF(clk_count < (70 * freq)) THEN    
            lcd_data <= "01000100";  --D    
            e <= '1';
          ELSIF(clk_count < (120 * freq)) THEN    --wait 
            e <= '0';
          ELSIF(clk_count < (130 * freq)) THEN   
            lcd_data <= "01000001"; ---A
            e <= '1';				
          ELSIF(clk_count < (2130 * freq)) THEN   --wait 
            e <= '0';
          ELSIF(clk_count < (2140 * freq)) THEN 
            lcd_data <= "01010100";  ---T
            e <= '1';
          ELSIF(clk_count < (2200 * freq)) THEN  --wait 
            e <= '0';
          ELSIF(clk_count < (2400 * freq)) THEN  
            lcd_data <= "01000001";     --A
            e <= '1';
          ELSIF(clk_count < (2600 * freq)) THEN  --wait 
            e <= '0';
			   state <= WRT;	
			 ELSIF (S4='0') THEN
			 state<=CLR;
			 clk_count := 0;
			 END IF;   
			 
	WHEN CLR=>
	       rs <= '0';
          rw <= '0';
			 clk_count := clk_count + 1;
			 IF(clk_count < (10 * freq)) THEN    
            lcd_data <= "00000001";      
            e <= '1';
          ELSIF(clk_count < (60 * freq)) THEN    --wait 50 us
            e <= '0';
            state <= WRT;
				clk_count := 0;
				END IF;
  END CASE;    
    
      --reset
      IF(reset_n = '0') THEN
          state <= power_up;
      END IF;
    
    END IF;
	 END PROCESS;
	 
END controller;