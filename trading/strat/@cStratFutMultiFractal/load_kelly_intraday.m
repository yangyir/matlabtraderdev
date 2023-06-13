function [] = load_kelly_intraday(obj,varargin)
% a cStratFutMultiFractal private method
% to load empirical kelly tables based on intraday (30m) data
    data = load([getenv('onedrive'),'\fractal backtest\output_comdtyfut.mat']);
    kelly_b = data.output_comdtyfut.kellyb_unique;
    kelly_s = data.output_comdtyfut.kellys_unique;
    
    tbl_all_intraday = cell(2,1);
    tbl_all_intraday{1}.direction = 'b';
    tbl_all_intraday{1}.table = kelly_b;
    tbl_all_intraday{2}.direction = 's';
    tbl_all_intraday{2}.table = kelly_s;
    obj.tbl_all_intraday_ = tbl_all_intraday;
    %
    %
    rp_tc = load([getenv('onedrive'),'\fractal backtest\rp_tc.mat']);
    rp_tb = load([getenv('onedrive'),'\fractal backtest\rp_tb.mat']);
    rp_exotics = load([getenv('onedrive'),'\fractal backtest\rp_exotics.mat']);
    
    obj.tbl_tc_intraday_ = rp_tc.reportbyasset_tc;
    obj.tbl_tb_intraday_ = rp_tb.reportbyasset_tb;
    obj.tbl_exotics_intraday_ = rp_exotics.reportbyasset_exotics; 

    
end

