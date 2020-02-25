function [ idxfractalb1,idxfractals1 ] = fractal_genindicators1( px,HH,LL,jaw,teeth,lips )
%FRACTAL_GENINDICATORS Summary of this function goes here
%   indicator of fractal's breachup-B and breachdn-S
    flagweakb1 = fractal_isbreachb(px,HH,LL,jaw,teeth,lips,'level','weak');
    flagmediumb1 = fractal_isbreachb(px,HH,LL,jaw,teeth,lips,'level','medium');
    flagstrongb1 = fractal_isbreachb(px,HH,LL,jaw,teeth,lips,'level','strong');
    flagb1 = flagweakb1 + flagmediumb1 + flagstrongb1;
    %1.weak;2.medium;3.strong
    idxfractalb1 = [find(flagb1==1),ones(length(find(flagb1==1)),1);...
        find(flagb1==2),2*ones(length(find(flagb1==2)),1);...
        find(flagb1==3),3*ones(length(find(flagb1==3)),1)];
    idxfractalb1 = sortrows(idxfractalb1);
    %
    %
    flagweaks1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','weak');
    flagmediums1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','medium');
    flagstrongs1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','strong');
    flags1 = flagweaks1 + flagmediums1 + flagstrongs1;
    %1.weak;2.medium;3.strong
    idxfractals1 = [find(flags1==1),ones(length(find(flags1==1)),1);...
        find(flags1==2),2*ones(length(find(flags1==2)),1);...
        find(flags1==3),3*ones(length(find(flags1==3)),1)];
    idxfractals1 = sortrows(idxfractals1);
    
end

