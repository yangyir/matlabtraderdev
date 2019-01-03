function [ output_args ] = bkfunc_plotdailydata( data2plot, varargin )
    [nrows,ncols] = size(data2plot);
    if ncols < 5
        error('bkfunc_plotdailydata:invalid data input:missing columns')
    end
    if ncols == 5
        hasVolume = false;
    else
        hasVolume = true;
        colVolume = 6;
    end
    
    p = inputParser;
    p.CaseSensitive = false; p.KeepUnmatched = true;
    p.addParameter('nperiods',144,@isnumeric);
    p.parse(varargin{:});
    nperiods = p.Results.nperiods;
    
    wr = willpctr(data2plot(:,3),data2plot(:,4),data2plot(:,4),nperiods);
    
    if hasVolume
        volume = data2plot(:,colVolume);
    else
        subplot(211);
        h = plot(data2plot(:,5));grid on;
        gca = get(h,'parent');
        xTicks = get(gca,'XTick');
        xTickLabels = get(
        
        
    end
    
    
        


end

