function [output] = bkf_tdsq_daily(assetname,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('fromdate','',@ischar);
    p.addParameter('todate','',@ischar);
    p.parse(varargin{:});
    
    dt1str = p.Results.fromdate;
    dt2str = p.Results.todate;
    
    [ri,oidata] = bkfunc_genfutrollinfo(assetname);
    [~,~,ci] = bkfunc_buildcontinuousfutures(ri,oidata);
    
    if ~isempty(dt1str)
        dt1num = datenum(dt1str);
        idx1 = find(ci(:,1)>=dt1num,1,'first');
    else
        idx1 = 1;
    end
    
    if ~isempty(dt2str)
        dt2num = datenum(dt2str);
        idx2 = find(ci(:,1)>=dt2num,1,'first');
    else
        idx2 = 1;
    end
    
    output = tdsq_plot2(ci,idx1,idx2,0.01);
    %
    %
%     p = ci(idx1:idx2,:);
%     bs = output.tdbuysetup;
%     ss = output.tdsellsetup;
%     lvlup = output.tdstresistence;
%     lvldn = output.tdstsupport;
%     bc = output.tdbuycountdown;
%     sc = output.tdsellcountdown;
%     macdvec = output.macd;
%     sigvec = output.sig;
%     
%     tradesimperfect = bkf_gentrades_tdsqimperfect('ni1910',p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,'riskmode','macd','openapproach','new');
    
end