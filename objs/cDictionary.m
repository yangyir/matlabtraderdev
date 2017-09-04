classdef cDictionary < cObj
    properties (Access = public)
        Mode
        Model
        YieldCurveCollection
        MktDataCollection
        VolCollection
        SecurityCollection
    end
    
    methods %SET/GET methods
        
    end
    
    methods (Access = public)
        function obj = cDictionary(dictionaryHandle,varargin)
            obj = init(obj,dictionaryHandle,varargin{:});
        end
        
        function yc = getyieldcurve(obj,currency)
            flag = false;
            for i = size(obj.YieldCurveCollection,1)
                if strcmpi(obj.YieldCurveCollection{i}.Currency,currency)
                    yc = obj.YieldCurveCollection{i};
                    flag = true;
                    break
                end
            end
            if ~flag
                error(['yieldcurve with currency ',currency,' not found!']);
            end
                
        end
        
        function mktdata = getmktdata(obj,assetname)
            flag = false;
            for i = size(obj.MktDataCollection,1)
                if strcmpi(obj.MktDataCollection{i}.AssetName,assetname)
                    mktdata = obj.MktDataCollection{i};
                    flag = true;
                    break
                end
            end
            if ~flag
                error(['mktdata with assetname ',assetname,' not found!']);
            end
        end
        
        function vol = getmarketvol(obj,assetname)
            flag = false;
            for i = size(obj.VolCollection,1)
                if strcmpi(obj.VolCollection{i}.AssetName,assetname) &&...
                        strcmpi(obj.VolCollection{i}.VolName,'MARKETVOL')
                    vol = obj.VolCollection{i};
                    flag = true;
                    break
                end
            end
            if ~flag
                error(['marketvol with assetname ',assetname,' not found!']);
            end
        end
        
        function vol = getlocalvol(obj,assetname)
            flag = false;
            for i = size(obj.VolCollection,1)
                if strcmpi(obj.VolCollection{i}.AssetName,assetname) &&...
                        strcmpi(obj.VolCollection{i}.VolName,'LOCALVOL')
                    vol = obj.VolCollection{i};
                    flag = true;
                    break
                end
            end
            if ~flag
                error(['localvol with assetname ',assetname,' not found!']);
            end
        end
        
    end
    
    methods (Access = private)
        function obj = init(obj,dictionaryHandle,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addRequired('DictionaryHandle',@ischar);
            p.addParameter('Mode','PRICE',...
                @(x) validateattributes(x,{'char'},{},'','Mode'));
            p.addParameter('Model',{},...
                @(x) validateattributes(x,{'cModel'},{},'','Model'));

            p.parse(dictionaryHandle,varargin{:});
            obj.ObjHandle = p.Results.DictionaryHandle;
            obj.ObjType = 'DICTIONARY';
            
            obj.Mode = p.Results.Mode;
            if ~(strcmpi(obj.Mode,'PRICE') || strcmpi(obj.Mode,'SPOTGAMMA') ||...
                 strcmpi(obj.Mode,'SPOTGAMMA-Cash') || strcmpi(obj.Mode,'VEGA') ||...
                 strcmpi(obj.Mode,'VEGA-Cash') || strcmpi(obj.Mode,'SPOTTHETA'))
                error('cDictionary:invalid dictionary mode')
            end
            obj.Model = p.Results.Model;
            
            nYieldCurve = 0;
            nMktData = 0;
            nVol = 0;
            nSecurity = 0;
            nBook = 0;
            for i = 1:size(varargin,2)-1
                if strcmpi(varargin{i},'YieldCurve')
                    nYieldCurve = nYieldCurve+1;
                end
                if strcmpi(varargin{i},'MktData')
                    nMktData = nMktData+1;
                end
                if strcmpi(varargin{i},'Vol')
                    nVol = nVol+1;
                end
                if strcmpi(varargin{i},'Security')
                    nSecurity = nSecurity+1;
                end
                if strcmpi(varargin{i},'Book')
                    nBook = nBook+1;
                end
            end
            yc = cell(nYieldCurve,1);
            mktdata = cell(nMktData,1);
            vols = cell(nVol,1);
            secs = cell(nSecurity,1);
            book = cell(nBook,1);
            
            idx_yc = 0;
            idx_mktdata = 0;
            idx_vol = 0;
            idx_sec = 0;
            idx_book = 0;
            for i = 1:size(varargin,2)-1
                if strcmpi(varargin{i},'YieldCurve')
                    idx_yc = idx_yc+1;
                    if isa(varargin{i+1},'cYieldCurve')
                        yc{idx_yc,1} = varargin{i+1};
                    else
                        error('cDictionary:invalid yield curve input!');
                    end
                end
                if strcmpi(varargin{i},'MktData')
                    idx_mktdata = idx_mktdata+1;
                    if isa(varargin{i+1},'cMktData')
                        mktdata{idx_mktdata,1} = varargin{i+1};
                    else
                        error('cDictionary:invalid mktdata input!');
                    end
                end
                if strcmpi(varargin{i},'Vol')
                    idx_vol = idx_vol+1;
                    if isa(varargin{i+1},'cVol')
                        vols{idx_vol,1} = varargin{i+1};
                    else
                        error('cDictionary:invalid vol input!');
                    end
                end
                if strcmpi(varargin{i},'Security')
                    idx_sec = idx_sec+1;
                    if isa(varargin{i+1},'cSecurity')
                        secs{idx_sec,1} = varargin{i+1};
                    else
                        error('cDictionary:invalid security input!');
                    end
                end
                if strcmpi(varargin{i},'Book')
                    idx_book = idx_book+1;
                    if iscell(varargin{i+1})
                        book{idx_book,1} = varargin{i+1};
                    else
                        error('cDictionary:invalid book input!');
                    end
                end     
            end
            
            obj.YieldCurveCollection = yc;
            obj.MktDataCollection = mktdata;
            obj.VolCollection = vols;
            
            if nBook > 0
                nSecAddition = 0;
                for i = 1:nBook
                    nSecAddition = nSecAddition + size(book{i},1);
                end
                secAddition = cell(nSecAddition,1);
                idx_secaddition = 0;
                for i = 1:nBook
                    book_i = book{i};
                    for j = 1:size(book_i,1)
                        idx_secaddition = idx_secaddition + 1;
                        secAddition{idx_secaddition,1} = book_i{j};
                    end
                end
                if nSecurity > 0
                    obj.SecurityCollection = {secs;secAddition};
                else
                    obj.SecurityCollection = secAddition;
                end
            else
                obj.SecurityCollection = secs;
            end
            
            
        end
    end
    
    
end