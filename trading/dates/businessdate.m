function bd = businessdate(date,dirFlag,city)
%bd = businessdate(date,dirFlag,city) returns the scalar,vector or matrix
%of the next or previous business days(s) depending on the city.

if nargin < 1
    error('businessdate:invalid date input');
end

if nargin < 2 || isempty(dirFlag)
    dirFlag = 1;
end

if (nargin < 3 || isempty(city)) || strcmpi(city,'shanghai')
    holidays = [736330,...
                736368,...
                736369,...
                736370,...
                736371,...
                736372,...
                736424,...
                736452,...
                736490,...
                736491,...
                736588,...
                736589,...
                736606,...
                736607,...
                736608,...
                736609,...
                736610,...
                736697,...
                736722,...
                736725,...
                736726,...
                736727,...
                736728,...
                736788,...
                736789,...
                736816,...
                736844,...
                736845,...
                736970,...
                736971,...
                736972,...
                736973,...
                736974,...
                737061,...
                737106,...
                737107,...
                737110,...
                737111,...
                737112,...
                737155,...
                737156,...
                737180,...
                737181,...
                737229,...
                737327,...
                737334,...
                737335,...
                737336,...
                737337,...
                737338,...
                737425,...
                737426,...
                737460,...
                737461,...
                737462,...
                737463,...
                737464,...
                737520,...
                737546,...
                737547,...
                737548,...
                737583,...
                737681,...
                737699,...
                737700,...
                737701,...
                737702,...
                737705,...
                737791,...
                737814,...
                737817,...
                737818,...
                737819,...
                737820,...
                737821,...
                737887,...
                737912,...
                737915,...
                737916,...
                737967,...
                737968,...
                738065,...
                738066,...
                738069,...
                738070,...
                738071,...
                738072,...
                738157,...
                738198,...
                738199,...
                738202,...
                738203,...
                738204,...
                738251,...
                738279,...
                738280,...
                738281,...
                738321,...
                738419,...
                738420,...
                738430,...
                738433,...
                738434,...
                738435,...
                738436,...
                738524,...
                738552,...
                738553,...
                738554,...
                738555,...
                738556,...
                738615,...
                738616,...
                738643,...
                738644,...
                738645,...
                738675,...
                738776,...
                738797,...
                738798,...
                738799,...
                738800,...
                738801,...
                738888,...
                738909,...
                738910,...
                738911,...
                738912,...
                738913,...
                738981,...
                739007,...
                739008,...
                739009,...
                739059,...
                739060,...
                ];
end

if ischar(dirFlag)
    if ~(strcmpi(dirFlag,'modifiedfollow') || strcmpi(dirFlag,'follow') ||...
         strcmpi(dirFlag,'modifiedprevious') || strcmpi(dirFlag,'previous'))
            error('businessdate:invalid dirFlag string input');
    end
elseif isscalar(dirFlag)
    if ~(dirFlag == 1 || dirFlag == -1)
        error('businessdate:invalid dirFlag scalar input');
    end
else
    error('invalid dirFlag input datatype');
end

bd = busdate(date,dirFlag,holidays);


end