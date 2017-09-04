function res = CCBPrice(dictionary)
    if ~isa(dictionary,'cDictionary')
        error('CCBPrice:dictionary required!');
    end
    
    mode = dictionary.Mode;
    model = dictionary.Model;
    modelName = upper(model.ModelName);
    
    book = dictionary.SecurityCollection;
        
    %MODE='PRICE'
    if strcmpi(mode,'PRICE')
        pv = zeros(size(book,1),1);
        switch modelName
            case 'CCBSMC'
                for i = 1:size(book,1)
                    security = book{i};
                    secName = security.SecurityName;
                    if strcmpi(secName,'EUROPEAN')
                        mktdata = dictionary.getmktdata(security.AssetName);
                        yc = dictionary.getyieldcurve(security.PayCurrency);
                        vol = dictionary.getmarketvol(security.AssetName);
                        pv(i) = modelAnalyticEuropean(yc,mktdata,vol,security,model);
                    else
                        error('CCBPrice:only european is supported');
                    end 
                end
            %
            case 'CCBX'
                for i = 1:size(book,1)
                    security = book{i};
                    secName = security.SecurityName;
                    if strcmpi(secName,'EUROPEAN')
                        mktdata = dictionary.getmktdata(security.AssetName);
                        yc = dictionary.getyieldcurve(security.PayCurrency);
                        vol = dictionary.getlocalvol(security.AssetName);
                        pv(i) = modelLocalVolEuropean(yc,mktdata,vol,security,model);
                    else
                        error('CCBPrice:only european is supported');
                    end
                end
            otherwise
                error('CCBPrice:only ccbsmc and ccbx model is supported!'); 
        end
        netvalue = sum(pv);
        if model.ExtraResults == 1
            secNames = cell(size(book,1),1);
            for i = 1:size(book,1)
                secNames{i} = book{i}.ObjHandle;
            end
            price = pv;
            extraResults = table(price,'RowNames',secNames);
            res = struct('netvalue',netvalue,'extraresults',extraResults);
        else
            res = struct('netvalue',netvalue);
        end
        
        return
    end
    
    %MODE=SPOTGAMMA or SPOTGAMMA-Cash
    if strcmpi(mode,'SPOTGAMMA') || strcmpi(mode,'SPOTGAMMA-Cash')
        pv = zeros(size(book,1),1);
        spotdelta = pv;
        spotgamma = pv;
        switch modelName
            case 'CCBSMC'        
                for i = 1:size(book,1)
                    security = book{i};
                    secName = security.SecurityName;
                    if strcmpi(secName,'EUROPEAN')
                        mktdata = dictionary.getmktdata(security.AssetName);
                        yc = dictionary.getyieldcurve(mktdata.Currency);
                        vol = dictionary.getmarketvol(security.AssetName);
                        pv(i) = modelAnalyticEuropean(yc,mktdata,vol,security,model);
                        mktdataUp = mktdata.ModifyMktData('PropertyName','Spot',...
                            'BumpSize',0.005,'BumpType','REL');
                        pvUp = modelAnalyticEuropean(yc,mktdataUp,vol,security,model);
                        
                        mktdataDown = mktdata.ModifyMktData('PropertyName','Spot',...
                            'BumpSize',-0.005,'BumpType','REL');
                        pvDown = modelAnalyticEuropean(yc,mktdataDown,vol,security,model);        
                    else
                        error('CCBPrice:only european is supported');
                    end
                    %calculate delta
                    spotdelta(i) = (pvUp-pvDown)/(mktdataUp.Spot-mktdataDown.Spot);
                    %calculate gamma
                    spotgamma(i) = (pvUp+pvDown-2*pv(i))/((mktdata.Spot*0.005)^2)*0.01;
                    if strcmpi(mode,'SPOTGAMMA-Cash')
                        spotdelta(i) = spotdelta(i)*mktdata.Spot;
                        spotgamma(i) = spotgamma(i)*mktdata.Spot^2;
                    end
                end
            %
            case 'CCBX'
                for i = 1:size(book,1)
                    security = book{i};
                    secName = security.SecurityName;
                    if strcmpi(secName,'EUROPEAN')
                        mktdata = dictionary.getmktdata(security.AssetName);
                        yc = dictionary.getyieldcurve(mktdata.Currency);
                        vol = dictionary.getlocalvol(security.AssetName);
                        pv(i) = modelLocalVolEuropean(yc,mktdata,vol,security,model);
                        mktdataUp = mktdata.ModifyMktData('PropertyName','Spot',...
                            'BumpSize',0.005,'BumpType','REL');
                        pvUp = modelLocalVolEuropean(yc,mktdataUp,vol,security,model);
                        
                        mktdataDown = mktdata.ModifyMktData('PropertyName','Spot',...
                            'BumpSize',-0.005,'BumpType','REL');
                        pvDown = modelLocalVolEuropean(yc,mktdataDown,vol,security,model);        
                    else
                        error('CCBPrice:only european is supported');
                    end
                    %calculate delta
                    spotdelta(i) = (pvUp-pvDown)/(mktdataUp.Spot-mktdataDown.Spot);
                    %calculate gamma
                    spotgamma(i) = (pvUp+pvDown-2*pv(i))/((mktdata.Spot*0.005)^2)*0.01;
                    if strcmpi(mode,'SPOTGAMMA-Cash')
                        spotdelta(i) = spotdelta(i)*mktdata.Spot;
                        spotgamma(i) = spotgamma(i)*mktdata.Spot^2;
                    end
                end
               
            otherwise
                error('CCBPrice:only ccbsmc and ccbx model is supported!')
        end
        
        netvalue = sum(pv);
        if model.ExtraResults == 1
            secNames = cell(size(book,1),1);
            for i = 1:size(book,1)
                secNames{i} = book{i}.ObjHandle;
            end
            price = pv;
            extraResults = table(price,spotdelta,spotgamma,'RowNames',secNames);
            res = struct('netvalue',netvalue,...
                'spotdelta',sum(spotdelta),...
                'spotgamma',sum(spotgamma),...
                'extraresults',extraResults);
        else
            res = struct('netvalue',netvalue,...
                'spotdelta',sum(spotdelta),...
                'spotgamma',sum(spotgamma));
        end
        
        return
    end
    
    %MODE=SPOTTHETA
    if strcmpi(mode,'SPOTTHETA')
        pv = zeros(size(book,1),1);
        pvDecayed = pv;
        spottheta = pv;
        switch modelName
            case 'CCBSMC'        
                for i = 1:size(book,1)
                    security = book{i};
                    secName = security.SecurityName;
                    if strcmpi(secName,'EUROPEAN')
                        mktdata = dictionary.getmktdata(security.AssetName);
                        yc = dictionary.getyieldcurve(mktdata.Currency);
                        vol = dictionary.getmarketvol(security.AssetName);
                        pv(i) = modelAnalyticEuropean(yc,mktdata,vol,security,model);
                        valDate = datenum(yc.ValuationDate);
                        decayDate = businessdate(valDate,1);
                        ycDecayed = yc.DecayYieldCurve('DecayDate',decayDate);
                        mktdataDecayed = mktdata.DecayMktData('DecayDate',decayDate);
                        pvDecayed(i) = modelAnalyticEuropean(ycDecayed,mktdataDecayed,vol,security,model);
                        spottheta(i) = pvDecayed(i)-pv(i);
                    else
                        error('CCBPrice:only european is supported');
                    end
                end
            %
            case 'CCBX'
                for i = 1:size(book,1)
                    security = book{i};
                    secName = security.SecurityName;
                    if strcmpi(secName,'EUROPEAN')
                        mktdata = dictionary.getmktdata(security.AssetName);
                        yc = dictionary.getyieldcurve(mktdata.Currency);
                        vol = dictionary.getlocalvol(security.AssetName);
                        pv(i) = modelLocalVolEuropean(yc,mktdata,vol,security,model);
                        valDate = datenum(yc.ValuationDate);
                        decayDate = businessdate(valDate,1);
                        ycDecayed = yc.DecayYieldCurve('DecayDate',decayDate);
                        mktdataDecayed = mktdata.DecayMktData('DecayDate',decayDate);
                        pvDecayed(i) = modelLocalVolEuropean(ycDecayed,mktdataDecayed,vol,security,model);
                        spottheta(i) = pvDecayed(i)-pv(i);
                    else
                        error('CCBPrice:only european is supported');
                    end
                end
                
            otherwise
                error('CCBPrice:only ccbsmc and ccbx model is supported!');
        end
        
        netvalue = sum(pv);
        if model.ExtraResults == 1
            secNames = cell(size(book,1),1);
            for i = 1:size(book,1)
                secNames{i} = book{i}.ObjHandle;
            end
            price = pv;
            decayedprice = pvDecayed;
            extraResults = table(price,decayedprice,spottheta,'RowNames',secNames);
            res = struct('netvalue',netvalue,...
                'decayedvalue',sum(pvDecayed),...
                'spottheta',sum(spottheta),...
                'extraresults',extraResults);
        else
            res = struct('netvalue',netvalue,...
                'decayedvalue',sum(pvDecayed),...
                'spottheta',sum(spottheta));
        end
        return
    end
    
end