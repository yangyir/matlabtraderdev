function [techvar,techvarstruct] = calctechnicalvariable(stratfractal,varargin)
%cStratOptMultiFractal
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('IncludeLastCandle',0,@isnumeric);
    p.addParameter('RemoveLimitPrice',0,@isnumeric);
    p.addParameter('volatilityperiod',0,@isnumeric);
    p.addParameter('tolerance',0,@isnumeric);
    p.parse(varargin{:});
    
   
    includeLastCandle = p.Results.IncludeLastCandle;
    removeLimitPrice = p.Results.RemoveLimitPrice;
    inpbandsperiod = p.Results.volatilityperiod;
    change = p.Results.tolerance;
    
    mdeopt = stratfractal.mde_opt_;
    
    candlesticks = mdeopt.getallcandles(mdeopt.underlier_);
    data = candlesticks{1};
    if ~includeLastCandle && ~isempty(data)
        data = data(1:end-1,:);
    end
    
    if removeLimitPrice
        idxremove = data(:,2)==data(:,3)&data(:,2)==data(:,4)&data(:,2)==data(:,5);
        idxkeep = ~idxremove;
        data = data(idxkeep,:);
    end
    
    jaw = smma(data,13,8);jaw = [nan(8,1);jaw];
    teeth = smma(data,8,5);teeth = [nan(5,1);teeth];
    lips = smma(data,5,3);lips = [nan(3,1);lips];
    
    nfractal = mdeopt.nfractals_(1);
    
    [idxHH,idxLL,~,~,HH,LL] = fractalenhanced(data,nfractal,'volatilityperiod',inpbandsperiod,'tolerance',change);
    
    [bs,ss,lvlup,lvldn,bc,sc] = tdsq(data(:,1:5));
    
    wad = williamsad(data);
    
    techvar = [data,idxHH,idxLL,HH,LL,jaw,teeth,lips,bs,ss,lvlup,lvldn,bc,sc,wad];
    
    techvarstruct = struct('px',data,...
                    'ss',ss,'sc',sc,...
                    'bs',bs,'bc',bc,...
                    'lvlup',lvlup,'lvldn',lvldn,...
                    'idxhh',idxHH,'hh',HH,...
                    'idxll',idxLL,'ll',LL,...
                    'lips',lips,'teeth',teeth,'jaw',jaw,...
                    'wad',wad);
    
end