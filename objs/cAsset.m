classdef cAsset
    % class of asset object
    properties (Access = public)
        AssetName
        ContractListUpdateFlag
    end
    %
    
    properties (GetAccess = public, SetAccess = private)
        ContractList
    end
    %
    
    properties (GetAccess = public, SetAccess = private, Dependent)
        AssetType
        ExtraInfo
    end
    %
    
    methods 
        % GET methods
        function name = get.AssetName(obj)
            name = obj.AssetName;
        end
        %
        function cl = get.ContractList(obj)
            cl = writeContractList2File(obj);
        end
        %
        function flag = get.ContractListUpdateFlag(obj)
            flag = obj.ContractListUpdateFlag;
        end
        %
        function type = get.AssetType(obj)
            name = obj.AssetName;
            info = getassetinfo(name);
            type = info.AssetType;
        end
        %
        function ei = get.ExtraInfo(obj)
            name = obj.AssetName;
            path = getenv('home');
            if isempty(path)
                path = 'C:\temp';
            end
            if ~strcmpi(path(end),'\')
                ei.directory = [path,'\data\',name,'\'];
            else
                ei.directory = [path,'data\',name,'\'];
            end
            ei.filename = [name,'_contract_list'];
        end
        %
        % SET methods
        function obj = set.AssetName(obj,name)
            obj.AssetName = name;
        end
        %
        function obj = set.ContractListUpdateFlag(obj,flag)
            obj.ContractListUpdateFlag = flag;
        end
        %
        function obj = set.ContractList(obj,cl)
            obj.ContractList = cl;
        end
    end
    %end of methods
    
    methods (Access = public)
        function obj = cAsset(varargin)
           if nargin == 0
               obj.AssetName = 'dummyasset';
               obj.ContractListUpdateFlag = false;
           else
               obj = init(obj,varargin{:});
           end
        end
        %
    end
    %end of methods
    %
    methods (Access = private)
        function obj = init(obj,varargin)
            if isempty(varargin)
                obj.AssetName = 'dummyasset';
                obj.ContractListUpdateFlag = false;
            else
                p = inputParser;
                p.CaseSensitive = false;
                p.addParameter('AssetName',{},...
                    @(x) validateattributes(x,{'char'},{},'','AssetName'));
                p.addParameter('ContractListUpdateFlag',false,...
                    @(x) validateattributes(x,{'logical'},{},'','ContractListUpdateFlag'));
                p.parse(varargin{:});
                obj.AssetName = p.Results.AssetName;
                obj.ContractListUpdateFlag = p.Results.ContractListUpdateFlag;
                %
                if ~isempty(obj.AssetName)
                    obj.ContractList = writeContractList2File(obj);
                end
                    
            end
        end
        %
        function cl = listContract(obj)
            name = obj.AssetName;
            clb = listcontracts(name,'connection','bloomberg');
            clw = listcontracts(name,'connection','wind');
            % add with contract last tradeable date
            n = size(clb,1);
            expiries = NaN(n,1);
            %note: we disable WIND for the time being
%             try
%                 c = windconnect;
%                 for i = 1:n
%                     expiries(i) = datenum(c.wss(clw{i},'lasttrade_date'));
%                 end
%             catch
                %wind not installed on the pc
                try
                    c = bbgconnect;
                    for i = 1:n
                        temp = getdata(c,clb{i},'last_tradeable_dt');
                        if ~isempty(temp) && isnumeric(temp.last_tradeable_dt)
                            expiries(i) = temp.last_tradeable_dt;
                        end
                    end
                catch me
                    error(me.message);
                end
%             end
            
            cl = cell(n,3);
            for i = 1:n
                cl{i,1} = clb{i,1};
                cl{i,2} = clw{i,1};
                cl{i,3} = expiries(i);
            end
        end
        %
        function cl = writeContractList2File(obj)
            update = obj.ContractListUpdateFlag;
            path = obj.ExtraInfo.directory;
            if ~isdir(path)
                mkdir(path);
            end
            file = obj.ExtraInfo.filename;
            [flag,cl] = isfile([path,file]);
            
            if (flag && update) || ~flag
                cl = listContract(obj);
                save([path,file],'cl');    
            end
                
        end
    end
    %end of methods
    
    
end

