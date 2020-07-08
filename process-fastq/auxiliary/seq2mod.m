function [modification] = seq2mod(sequence, varargin)
% this function can convert a nucleotide or cell array of nucleotides to
% modification or cell array of modifications.
% usage:
% seq2mod('CTTCTATTTGCTATTCCTCTAGACTATAAAGATGATGATGACAAGGGTGGCGGT')
% or
% seq2mod(Nuc)
% or if you want to use specific modification XLS file
% seq2mod(Nuc, 'SDBdir', dir_name, 'SDBxls', file_name);
%
% or if you want to use 1st column in the SDB xls file to return SDB 
% numbers instead of specific modifiers
% seq2mod(Nuc, 'modificationCol', 1);
%
% Nuc can be loaded from any unfiltered file like this:
%     FILE = 'YC_unfiltered.txt';
%     DIR = '/Users/ratmir/Documents/My Illumina/20171128';
%     
%     [sequence, ~, ~] = readMulticolumn('Dir', DIR, 'File', FILE, ...
%                                 'column', 1, 'skip', 2, 'output', 'raw');


% all these variables can be passed from the outside 
    SDBxls = 'XX.xlsx';
    SDBxlsdir = '';
    Hdist = 2;           % by default, the program is looking for up to H=2
    UNKNOWN = '???';     % this symbol is used for all unidentified mod 
    modification = {};   % by default, modification array is blank to start
    sdbCol = 3;          % SDB sequences are in column 3 in the XLS file
    modificationCol = 4; % names of modifications are in column 7 
    locationCol = 2;     %locations of SDB are in column 2
    offset = 1;          % skip first row in the XLS file
    DISP = 0;

    if exist('varargin','var')
        L = length(varargin);
        if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); 
        end

        % read input variables
        for ni = 1:2:L
            switch lower(varargin{ni})         
                case 'offline',         offline = varargin{ni+1};
                case 'sdbxls',          SDBxls = varargin{ni+1};
                case 'sdbxlsdir',       SDBxlsdir = varargin{ni+1};
                case 'sdbcol',          sdbCol = varargin{ni+1};
                case 'locationcol',     locationCol = varargin{ni+1};
                case 'modificationcol', modificationCol = varargin{ni+1};
                case 'offset',          offset = varargin{ni+1}; 
                case 'hdist',           Hdist  = varargin{ni+1}; 
                case 'unknown',         UNKNOWN = varargin{ni+1}; 
                case 'modification',    modification = varargin{ni+1}; 
                case 'disp',            DISP = varargin{ni+1}; 
            end
        end
    end
  

    cNuc = char(sequence);

    % Unless the modification was passed as argument, the program creates
    % a modificaiton variable with '??-' as modifications. Those
    % modifications will be progressivelly replaced in the for loop below
    if isempty(modification)
        modification = cellstr ( makeCHARarray(UNKNOWN, size(cNuc,1)) );
    else
        disp('adding ladders to existing modified library');
    end
        

    [~,SS,B]=xlsread(fullfile(SDBxlsdir,SDBxls));
    
    allSDB = SS(offset+1:end, sdbCol);

    modifications = B(offset+1:end, modificationCol);    
    locations = B(offset+1:end, locationCol);


    for i=1:numel(allSDB);
    
        aSDB = makeCHARarray(deblank(allSDB{i}), size(cNuc,1));

        location = extractlocation(locations{i});
        
        if max(location)<=size(cNuc,2)
                  
            test = sum(aSDB ~= cNuc(:,location), 2);
            IX = find(test>= -Hdist & test <= Hdist);
            if ~isempty(IX)
                
                modification(IX) = modifications(i);
                if DISP
                    disp(['i=' num2str(i) ' mod='  modifications{i}]);
                end
                
            end
        else
            IX = [];
        end

        fprintf('.');   
    end
    disp('done');
    
    % flush out different data types into a cell array of strings
    for i=1:numel(modification)
        if isnumeric(modification{i})
            modification{i} = num2str(modification{i});
        end
    end
end

function [location] = extractlocation(array)

    expression = ('(\d+:\d+){1,10}');
    IX = regexp(array,expression,'match');
    location = [];
    for i = 1:numel(IX)
        N = regexp(IX{i}, '\d+', 'match');
        location = [location, str2num(N{1}) : str2num(N{2})];
    end

end
function [array] = makeCHARarray(SDB, dimension)

    ONE = ones(dimension,numel(SDB));
    
    for i=1:numel(SDB)
        ONE(:,i) = ONE(:,i)*SDB(i);
    end
    
    array = char(ONE);

end