function obj = init(obj,varargin)
%cAShareWindIndustires
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','asharewindindustries',@ischar);
    p.addParameter('InitiateWind',true,@islogical);
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
    %
    %other default values
    initiatewind = p.Results.InitiateWind;
    if initiatewind
        obj.conn_ = cWind;
    else
        fprintf('cETFWatcher:init:wind not initiated!!!\n');
    end
    obj.settimerinterval(1);
    %
    
    obj.codes_index_ = {'886001.WI';'886002.WI';'886003.WI';'886004.WI';'886005.WI';'886006.WI';'886007.WI';'886008.WI';'886009.WI';'886010.WI';...
    '886011.WI';'886012.WI';'886013.WI';'886014.WI';'886015.WI';'886016.WI';'886017.WI';'886018.WI';'886019.WI';'886020.WI';...
    '886021.WI';'886022.WI';'886023.WI';'886024.WI';'886025.WI';'886026.WI';'886027.WI';'886028.WI';'886029.WI';'886030.WI';...
    '886031.WI';'886032.WI';'886033.WI';'886034.WI';'886035.WI';'886036.WI';'886037.WI';'886038.WI';'886039.WI';'886040.WI';...
    '886041.WI';'886042.WI';'886043.WI';'886044.WI';'886045.WI';'886046.WI';'886048.WI';'886049.WI';'886050.WI';...
    '886051.WI';'886052.WI';'886053.WI';'886054.WI';'886055.WI';'886057.WI';'886058.WI';'886059.WI';'886060.WI';...
    '886061.WI';'886062.WI';'886063.WI';'886064.WI';'886065.WI';'886066.WI';'886067.WI';'886068.WI';'886069.WI'};
    %
    n_index = length(obj.codes_index_);
    names_index = cell(n_index,1);
    pos_index = cell(n_index,1);
    
    for i = 1:n_index
        instrument = code2instrument(obj.codes_index_{i});
        names_index{i} = instrument.asset_name;
        pos_index{i} = {};
    end
    %
    obj.names_index_ = names_index;
    %
    obj.pos_index_ = pos_index;
    %
    obj.dailystatus_index_ = nan(n_index,1);
    %
    obj.reload;
    %
    %generate daily-frequency trades
%     nfractal = 2;
    for i = 1:n_index
        d = obj.dailybarstruct_index_{i};
        trade = fractal_latestposition('code',obj.codes_index_{i},...
            'extrainfo',d,...
            'frequency','daily',...
            'usefractalupdate',0,...
            'usefibonacci',1);
        if ~isempty(trade)
            if strcmpi(trade.status_,'set')
                obj.pos_index_{i} = trade;
                obj.dailystatus_index_(i) = trade.opendirection_;
            else
                if ~(obj.dailystatus_index_(i) == 2  || obj.dailystatus_index_(i) == -2)
                    obj.dailystatus_index_(i) = 0;
                end
            end
        else
            if ~(obj.dailystatus_index_(i) == 2  || obj.dailystatus_index_(i) == -2)
                obj.dailystatus_index_(i) = 0;
            end
        end
        

    end
    
    fprintf('\n');
    
   
    
end 