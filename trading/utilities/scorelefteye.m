function [leftEyeScore, leftEyeDetails] = scorelefteye(varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('px',[],@isnumeric);
    p.addParameter('fractalIdx',[],@isnumeric);
    p.addParameter('fractalType','top',@ischar);
    p.addParameter('leftEyeBars',12,@isnumeric);
    p.addParameter('minTrendBars',4,@isnumeric);
    p.addParameter('atr',[],@isnumeric);
    p.parse(varargin{:});
    
    px = p.Results.px;
    fractalIdx = p.Results.fractalIdx;
    fractalType = p.Results.fractalType;
    leftEyeBars = p.Results.leftEyeBars;
    minTrendBars = p.Results.minTrendBars;
    atr = p.Results.atr;
    
    if length(atr) ~= size(px,1)
        error('scorelefteye:size mismatch between price and atr');
    end
    
    O = px(:,2);H = px(:,3);L = px(:,4);C = px(:,5);
    
    startIdx = max(1,fractalIdx - leftEyeBars);
    endIdx = fractalIdx - 1;
    
    if endIdx - startIdx < minTrendBars
        leftEyeScore = 0;
        leftEyeDetails = struct('continuityscore',0,'bodyscore',0,...
            'shadowscore',0,'retracescore',0,'totalscore',0,...
            'numbars',0);
        return;
    end
    
    leftpx = px(startIdx:endIdx,:);
    
    currentATR = atr(fractalIdx);
    
    continuityScore = scorecontinuity(leftpx,fractalType);
    bodyScore = scorebodyquality(leftpx,fractalType);
    shadowScore = scoreshadowhealth(leftpx,fractalType,currentATR);
    retraceScore = scoreretracedepth(leftpx,fractalType,currentATR);
    
    leftEyeScore = continuityScore + bodyScore + shadowScore + retraceScore;
    
    leftEyeDetails = struct('continuityscore',continuityScore,...
        'bodyscore',bodyScore,...
        'shadowscore',shadowScore,...
        'retracescore',retraceScore,...
        'totalscore',leftEyeScore,...
        'numbars',length(leftpx));
end