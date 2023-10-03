global_comdty = {
    'xau';...
    'xag';...
    'xpd';...
    'xpt';...
    'brent';...
    'wti';...
    'naturalgas';...
    'cbotsoybean';...
    'cbotcorn';...
    'cbotwheat';...
    'cbotsoymeal';...
    'icesugar';...
    'icecotton';...
    'icecoco';...
    'icecoffee';...   
    'lmecopper';...
    'lmealuminum';...
    'lmezinic';...
    'lmelead';...
    'lmenickel';...
    'lmetin';...
    };

output_daily_globalcomdty = fractal_kelly_summary('codes',global_comdty,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[reportbyasset_tc_globalcomdty,reportbyasset_tb_globalcomdty] = kellydistrubitionsummary(output_daily_globalcomdty);
%%