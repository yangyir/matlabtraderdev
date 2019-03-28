function [ output_args ] = portpnlriskbreakdown1( port_instruments, port_volume)
cobdate = getlastbusinessdate;
predate = businessdate(cobdate,-1);
%
port_pnltotal = 0;
port_pnldelta = 0;
port_pnlgamma = 0;
port_pnlvega = 0;
port_pnltheta = 0;
port_pnlother = 0;
port_riskdelta = 0;
port_riskgamma = 0;
port_riskvega = 0;
port_risktheta = 0;
for i = 1:size(port_instruments,1)
    pnlbreakdown = pnlriskbreakdown1(port_instruments{i},cobdate,port_volume(i));
    port_pnltotal = port_pnltotal+pnlbreakdown.pnltotal;
    port_pnldelta = port_pnldelta+pnlbreakdown.pnldelta;
    port_pnlgamma = port_pnlgamma+pnlbreakdown.pnlgamma;
    port_pnlvega = port_pnlvega+pnlbreakdown.pnlvega;
    port_pnltheta = port_pnltheta+pnlbreakdown.pnltheta;
    port_pnlother = port_pnlother+pnlbreakdown.pnlunexplained;
    %
    port_riskdelta = port_riskdelta + pnlbreakdown.deltacarry;
    port_riskgamma = port_riskgamma + pnlbreakdown.gammacarry;
    port_riskvega = port_riskvega + pnlbreakdown.vegacarry;
    port_risktheta = port_risktheta + pnlbreakdown.thetacarry;
end
fprintf('pnl break of portfolio:\n');
fprintf('\t%6s:%10.0f\n','total',port_pnltotal);
fprintf('\t%6s:%10.0f\n','delta',port_pnldelta);
fprintf('\t%6s:%10.0f\n','gamma',port_pnlgamma);
fprintf('\t%6s:%10.0f\n','vega',port_pnlvega);
fprintf('\t%6s:%10.0f\n','theta',port_pnltheta);
fprintf('\t%6s:%10.0f\n','other',port_pnlother);
%
fprintf('risk of portfolio:\n');
fprintf('\t%6s:%10.0f\n','delta',port_riskdelta);
fprintf('\t%6s:%10.0f\n','gamma',port_riskgamma);
fprintf('\t%6s:%10.0f\n','vega',port_riskvega);
fprintf('\t%6s:%10.0f\n','theta',port_risktheta);
%
output_args = struct('pnltotal',port_pnltotal,...
    'pnltheta',port_pnltheta,...
    'pnldelta',port_pnldelta,...
    'pnlgamma',port_pnlgamma,...
    'pnlvega',port_pnlvega,...
    'pnlunexplained',port_pnltheta,...
    'date1',datestr(predate,'yyyy-mm-dd'),...
    'date2',datestr(cobdate,'yyyy-mm-dd'),...
    'deltacarry',port_riskdelta,...
    'gammacarry',port_riskgamma,...
    'thetacarry',port_risktheta,...
    'vegacarry',port_riskvega);


    
    


end

