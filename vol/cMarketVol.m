classdef cMarketVol < cVol
    properties
        Strikes
        Expiries
        Vols
        InterpolationMethod
        ExtrapolationMethod
        RestrikeType
        ReferenceSpot
    end
    
    methods
        
    end
    
    methods (Access = public)
        function obj = cMarketVol(objhandle,varargin)
            obj = init(obj,objhandle,varargin{:});
        end
        
        function vol = getVol(obj,strike,expiry,forward)
            if isscalar(obj.Vols)
                vol = obj.Vols;
            else
                if size(obj.Vols,1)*size(obj.Vols,2) == 1
                    vol = obj.Vols(1);
                else
                    nSlice = size(obj.Expiries,1);
                    if nSlice == 1
                        %only a skew or smile
                        if strcmpi(obj.RestrikeType,'STICKYSTRIKE')
                           k = log(strike/obj.ReferenceSpot);
                           x = log(obj.Strikes./obj.ReferenceSpot);
                           y = obj.Vols;
                           if k < min(x)
                               vol = y(1);
                           elseif k > max(x)
                               vol = y(end);
                           else
                               vol = interp1(x,y,k,obj.InterpolationMethod);
                           end
                        else
                            error('cMarketVol:getvol:case not implemented!');
                        end
                    else
                        %case with term struture
                        error('cMarketVol:getvol:case not implemented!');
                    end
                end
            end
            
        end
    end
    
    methods (Access = private)
        function obj = init(obj,objhandle,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addRequired('ObjHandle',@ischar);
            p.addParameter('VolType',{},...
                @(x) validateattributes(x,{'char'},{},'','VolType'));
            p.addParameter('Strikes',{},...
                @(x) validateattributes(x,{'numeric'},{},'','Strikes'));
            p.addParameter('Expiries',{},...
                @(x) validateattributes(x,{'numeric','char'},{},'','Expiries'));
            p.addParameter('Vols',{},...
                @(x) validateattributes(x,{'numeric'},{},'','Vols'));
            p.addParameter('InterpolationMethod','linear',...
                @(x) validateattributes(x,{'char'},{},'','InterpolationMethod'));
            p.addParameter('ExtrapolationMethod','none',...
                @(x) validateattributes(x,{'char'},{},'','ExtrapolationMethod'));
            p.addParameter('RestrikeType','STICKYSTRIKE',...
                @(x) validateattributes(x,{'char'},{},'','RestrikeType'));
            p.addParameter('ReferenceSpot',{},...
                @(x) validateattributes(x,{'numeric'},{},'','ReferenceSpot'));
            p.addParameter('AssetName',{},...
                @(x) validateattributes(x,{'char'},{},'','AssetName'));
            
            p.parse(objhandle,varargin{:});
            obj.ObjHandle = p.Results.ObjHandle;
            obj.ObjType = 'VOL';
            obj.VolName = 'MARKETVOL';
            obj.VolType = p.Results.VolType;
            obj.InterpolationMethod = p.Results.InterpolationMethod;
            obj.ExtrapolationMethod = p.Results.ExtrapolationMethod;
            obj.RestrikeType = p.Results.RestrikeType;
            obj.ReferenceSpot = p.Results.ReferenceSpot;
            obj.AssetName = p.Results.AssetName;
            
            if strcmpi(obj.VolType,'STRIKEVOL')
                k = p.Results.Strikes;
                t = datenum(p.Results.Expiries);
                vol = p.Results.Vols;
                [nSlice,nStrikesPerSlice] = size(k);
                [~,nExpiry] = size(t);
                if nExpiry == 1
                    t = t';
                    nExpiry = length(t);
                end
                [nVolsSlice,nVolsPerSlice] = size(vol);
                %sanity check and process
                if nSlice > 1 
                    if nSlice ~= nExpiry
                        error('cMarketVol:maturity size mismatch between Strikes and Expiries');
                    end
                    if nSlice ~= nVolsSlice
                        error('cMarketVol:maturiry size mismatch between Strikes and Vols')
                    end
                elseif nStrikesPerSlice ~= nVolsPerSlice
                    error('cMarketVol:strike size mismatch between Strikes and Vols');
                elseif nExpiry ~= nVolsSlice
                    error('cMarketVol:maturity size mismatch between Expiries and Vols');
                end
                
                if nSlice == 1
                    strikes = vol;
                    for i = 1:nVolsSlice
                        strikes(i,:) = k;
                    end
                    obj.Strikes = strikes;
                else
                    obj.Strikes = k;
                end
                
                expiries = vol;
                for i = 1:nVolsPerSlice
                    expiries(:,i) = t;
                end
                obj.Expiries = expiries;
                obj.Vols = vol;
            else
                error('cMarketVol:unknown or unmplemented VolType');
            end
            
        end
    end
end