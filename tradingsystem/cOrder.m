classdef cOrder
    %class of trading order
    %note:orderID is poped-up locally
    %note:orderReference is poped-up remotely in server
    %instrumentID:the futures instrument to be trade
    %accountID:the investor ID
    
    properties
        pOrderID
        pInstrument
        pTraderID
        pOrderRef
        pDirection
        pOffsetFlag
        pPrice
        pVolumeOriginal
        pVolumeTraded
        pTime
    end
    
    properties (GetAccess = public, SetAccess = private, Dependent)
        pStatus
    end
    
    methods %SET/GET methods
        function status = get.pStatus(obj)
            if obj.pVolumeTraded == 0
                status = 'unknown';
            elseif obj.pVolumeTraded < obj.pVolumeOriginal
                status = 'parttraded';
            elseif obj.pVolumeTraded == obj.pVolumeOriginal
                status = 'alltraded';
            else
                status = 'error';
            end
        end        
    end
    
    methods (Access = public)
        function obj = cOrder(varargin)
            obj = init(obj,varargin{:});
        end
        
        function print(obj)
            try
                message = ['order:',obj.pOrderID,' on ',datestr(obj.pTime,'yyyymmdd HH:MM:SS'),...
                    ' to ',obj.pOffsetFlag,...
                    ' ',num2str(obj.pVolumeOriginal),' lots of',...
                    ' ',obj.pInstrument.WindCode(1:end-4),...
                    ' with ', obj.pDirection,' orders',...
                    ' at ',num2str(obj.pPrice),';',...
                    'status:',obj.pStatus,'.\n'];
            catch
                message = ['order:',obj.pOrderID,' on ',datestr(obj.pTime,'yyyymmdd HH:MM:SS'),...
                    ' to ',obj.pOffsetFlag,...
                    ' ',num2str(obj.pVolumeOriginal),' lots of',...
                    ' ',obj.pInstrument.BloombergCode,...
                    ' with ', obj.pDirection,' orders',...
                    ' at ',num2str(obj.pPrice),';',...
                    'status:',obj.pStatus,'.\n'];
            end
            fprintf(message);
        end
    end
    
    methods (Access = private)
        function obj = init(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Instrument',{},@(x)validateattributes(x,{'cContract','struct'},{},'','Instrument'));
            p.addParameter('OrderID',{},@(x)validateattributes(x,{'char','numeric'},{},'','OrderID'));
            p.addParameter('TraderID',{},@(x)validateattributes(x,{'char','numeric'},{},'','TraderID'));
            p.addParameter('OrderReference',{},@(x)validateattributes(x,{'char','numeric'},{},'','OrderReference'));
            p.addParameter('Direction',{},@(x)validateattributes(x,{'char'},{},'','Direction'));
            p.addParameter('OffsetFlag',{},@(x)validateattributes(x,{'char'},{},'','OffsetFlag'));
            p.addParameter('Price',{},@(x)validateattributes(x,{'numeric'},{},'','Price'));
            p.addParameter('Volume',{},@(x)validateattributes(x,{'numeric'},{},'','Volume'));
            p.addParameter('Time',{},@(x)validateattributes(x,{'char','numeric'},{},'','Time'));
            
            p.parse(varargin{:});
            obj.pInstrument = p.Results.Instrument;
            if isempty(obj.pInstrument)
                error('cOrder:invalid instrument input')
            end
            obj.pTime = p.Results.Time;
            if isempty(obj.pTime)
                obj.pTime = now;
            end
            obj.pOrderID = p.Results.OrderID;
            if isempty(obj.pOrderID)
                %default order id convention
                %instrument + datetime
                id = obj.pInstrument.WindCode;
                id = id(1:end-4);
                id = [id,'_',datestr(obj.pTime,'yyyymmdd_HHMMSS')];
                obj.pOrderID = id;
            end
            obj.pTraderID = p.Results.TraderID;
            obj.pOrderRef = p.Results.OrderReference;
            %note:maybe some rewrite up is required for order reference
            if isempty(obj.pOrderRef)
                obj.pOrderRef = obj.pOrderID;
            end
            obj.pDirection = p.Results.Direction;
            if isempty(obj.pDirection) || (~isempty(obj.pDirection) && ~(strcmpi(obj.pDirection,'buy')||strcmpi(obj.pDirection,'sell')))
                error('cOrder:invalid direction input')
            end
            obj.pOffsetFlag = p.Results.OffsetFlag;
            if isempty(obj.pOffsetFlag) || ....
                    (~isempty(obj.pOffsetFlag) && ...
                    ~(strcmpi(obj.pOffsetFlag,'open') ||...
                    strcmpi(obj.pOffsetFlag,'close') ||...
                    strcmpi(obj.pOffsetFlag,'closetoday') ||...
                    strcmpi(obj.pOffsetFlag,'closeyesterday')))
                error('cOrder:invalid offsetflag input')
            end
            obj.pPrice = p.Results.Price;
            if isempty(obj.pPrice)
                error('cOrder:invalid input of price')
            end
            obj.pVolumeOriginal = p.Results.Volume;
            if isempty(obj.pVolumeOriginal) || (~isempty(obj.pVolumeOriginal) && obj.pVolumeOriginal <=0 )
                error('cOrder:invalid input of volume')
            end
            obj.pVolumeTraded = 0;
        end
    end
end