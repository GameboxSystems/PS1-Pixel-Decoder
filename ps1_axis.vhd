--------------------------------------------------------------------------------
-- Engineer: Postman
--------------------------------------------------------------------------------
library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
Library UNISIM;
use UNISIM.vcomponents.all;
--------------------------------------------------------------------------------
entity ps1_axis is
generic (
	TEST_MODE					: boolean	:= FALSE;
	X_RES						: integer	:= 640;
	Y_RES						: integer	:= 480;
	X_OFFSET					: integer	:= 1;
	Y_OFFSET					: integer	:= 5
);		
port (		
	aclk						: in  STD_LOGIC;
	---------------------------------------------------------------------
	ps_clk						: in  STD_LOGIC;
	ps_hs						: in  STD_LOGIC;
	ps_vs						: in  STD_LOGIC;
	ps_r						: in  STD_LOGIC_VECTOR(7 downto 0)	:= (others => '0');
	ps_g						: in  STD_LOGIC_VECTOR(7 downto 0)	:= (others => '0');
	ps_b						: in  STD_LOGIC_VECTOR(7 downto 0)	:= (others => '0');
	---------------------------------------------------------------------
	m_axis_tvalid				: out STD_LOGIC;
	m_axis_tuser				: out STD_LOGIC_VECTOR( 1 downto 0)	:= (others => '0');
	m_axis_tdata				: out STD_LOGIC_VECTOR(31 downto 0)	:= (others => '0');
	m_axis_tlast				: out STD_LOGIC
);
end ps1_axis;
--------------------------------------------------------------------------------
architecture arch_imp of ps1_axis is
--------------------------------------------------------------------------------
signal clk_sr			: STD_LOGIC_VECTOR( 2 downto 0);
signal hs_sr			: STD_LOGIC_VECTOR( 2 downto 0);
signal vs_sr			: STD_LOGIC_VECTOR( 2 downto 0);
signal vdata			: STD_LOGIC_VECTOR(31 downto 0);
signal x_cnt			: UNSIGNED( 9 downto 0);
signal y_cnt			: UNSIGNED( 9 downto 0);
signal valid_drv		: STD_LOGIC;
signal user_drv			: STD_LOGIC;
signal user_drv_pipe 	: STD_LOGIC;
signal last_drv			: STD_LOGIC;
signal nl				: STD_LOGIC	:= '0';
--------------------------------------------------------------------------------
begin
--------------------------------------------------------------------------------

process(aclk)
begin
	if rising_edge(aclk) then
		clk_sr		<= clk_sr(1 downto 0) & ps_clk;
		hs_sr		<= hs_sr(1 downto 0) & ps_hs;
		vs_sr		<= vs_sr(1 downto 0) & ps_vs;
		vdata		<= x"00" & ps_r & ps_g & ps_b;
	end if;
end process;

process(aclk)
begin
	if rising_edge(aclk) then
		if(vs_sr(2 downto 1) = "01")then
			user_drv				<= '1';
			last_drv				<= '0';
			--m_axis_tdata			<= x"00" & "0" & vdata(23 downto 17) & x"FF" & "0" & vdata(7 downto 1);
			--m_axis_tdata			<= vdata;
			valid_drv				<= '1';
			x_cnt					<= (others => '0');
			y_cnt					<= (others => '0');
		elsif(hs_sr(2 downto 1) = "10")then
			user_drv				<= '0';
			last_drv				<= '1';
			--m_axis_tdata			<= x"00" & "0" & vdata(23 downto 17) & x"FF" & "0" & vdata(7 downto 1);
			--m_axis_tdata			<= vdata;
			valid_drv				<= '1';
			x_cnt					<= (others => '0');
			y_cnt					<= y_cnt + 1;
			nl						<= not nl;
		elsif(clk_sr(2 downto 1) = "01")then
			user_drv				<= '0';
			last_drv				<= '0';
			valid_drv				<= '1';
			-- --if(x_cnt = TO_UNSIGNED((X_RES-1),8))then 
			--if(x_cnt = TO_UNSIGNED((X_RES),8))then 
				--x_cnt				<= (others => '0');
				-- last_drv			<= '1';
				-- y_cnt				<= y_cnt + 1;
				-- nl					<= not nl;
				-- dbg_fl				<= '0';
			--else
				x_cnt				<= x_cnt + 1;
				-- last_drv			<= '0';
			--end if;
			-- if(x_cnt = TO_UNSIGNED(1,8))then
				-- user_drv			<= '0';
			-- end if;
			-- --last_drv				<= '0';
			-- if(x_cnt < TO_UNSIGNED((X_RES),8))then
				-- valid_drv			<= '1';
			-- end if;
			if(TEST_MODE = FALSE)then
				m_axis_tdata		<= vdata;
			else
				if((x_cnt = TO_UNSIGNED(X_OFFSET,10)) or (x_cnt = TO_UNSIGNED((X_RES+X_OFFSET-1),10)))then
					m_axis_tdata	<= x"00FF" & "0" & vdata(15 downto 9) & "0" & vdata(7 downto 1);
				elsif((y_cnt = TO_UNSIGNED(Y_OFFSET,10)) or (y_cnt = TO_UNSIGNED((Y_RES+Y_OFFSET-1),10)))then
					m_axis_tdata	<= x"00" & "0" & vdata(23 downto 17) & "0" & vdata(15 downto 9) & x"FF";
				else
					m_axis_tdata	<= vdata;
				end if;
			end if;
		else
			valid_drv				<= '0';
		end if;
	end if;
end process;

m_axis_tvalid		<= valid_drv;
m_axis_tuser(0)		<= user_drv;
m_axis_tlast		<= last_drv;

dbg_nl				<= nl;
dbg_cnt				<= STD_LOGIC_VECTOR(x_cnt);
--------------------------------------------------------------------------------
end arch_imp;
