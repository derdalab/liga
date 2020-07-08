function [] = unfiltered2filteredFUNCTION(varargin)

% this is currently true for 2017 designed primers and SDBs.
% this might need to be changed if libraries of SDB or primers change
SHOWaminoACIDS = 18:24;

PRECISION = '%10.3f';
DISPLAY = 1;

%%% here is a guide how to pick amino acids
%                  *     *
% 123456789012345678901234567
% KKLLFAIPLVVPFYSHSSFCNLRCGGG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sdbxlsdir = '';
sdbxls    = '';

USE_NUMBERS = 0;
MarkDirrefentSDB = 0;

SDBxlsdir = '/Volumes/Data/Illumina/SDB libraries'; 
ladder = '';
ladderdir = '';

SEPARATOR = '-';

skip = 0;
Hdist = 1;

if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); 
    end

    % read input variables
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'file',            File  = varargin{ni+1};
            case 'dir',             Dir = varargin{ni+1};
            case 'savename',        savename = varargin{ni+1};
            case 'savepath',        savepath = varargin{ni+1};
            case 'sdb_location',    SDB_location = varargin{ni+1};
            case 'use_numbers',     USE_NUMBERS = varargin{ni+1};
            case 'markdifferentsdb',MarkDirrefentSDB = varargin{ni+1};
            case 'sdbxlsdir',       SDBxlsdir = varargin{ni+1};
            case 'sdbxls',          SDBxls = varargin{ni+1}; 
            case 'ladder',          ladder = varargin{ni+1}; 
            case 'modification',    modification = varargin{ni+1};
            case 'ladderdir',       ladderdir = varargin{ni+1}; 
            case 'showaminoacids',  SHOWaminoACIDS = varargin{ni+1};
            case 'separator',       SEPARATOR = varargin{ni+1};
            case 'skip',            skip = varargin{ni+1};
            case 'hdist',           Hdist  = varargin{ni+1}; 
        end
    end
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read the top line to extract the tags
if DISPLAY
            fprintf(File);
end

    tic
    
        

    
    fh = fopen(fullfile(Dir, File),'r');
    
    if skip
        for i=1:skip
            fgetl(fh);
        end
        
    end
    
    test = fgetl(fh);
    columns = numel(regexp(test, '\d+'));
    
    FORM = '%s %s ';
    
    for i=1:columns
        FORM  = [FORM '%f '];
    end
    
    FORM  = [FORM '%*[^\n]'];
    
    toc1 = toc;
    AllVar = textscan(fh,FORM);
    toc2 = toc;
    Nuc =  AllVar{1};
    AA0  = AllVar{2};
    %Fr =   AllVar{3};
    
    Fr = zeros(size(AllVar{3},1),columns);
    for i=1:columns
        Fr(:,i) = AllVar{2+i};
    end
    toc3 = toc;

if DISPLAY
            disp(['...loaded ' num2str(numel(Nuc)) ' in ' ...
                  num2str(toc1, PRECISION) '+' ...
                  num2str(toc2, PRECISION) '+' ...
                  num2str(toc3, PRECISION) '+' ...
                  num2str(toc,  PRECISION) ...
                  ' s']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract the region from amino acid sequence that will be used for
% analysis. trim all the GGG and leader regions. The variable
% SHOWaminoACIDS defines which region to look at
cAA = char(AA0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract the region from amino acid sequence that will be used for
% analysis. If needed, trim all the GGG and leader regions.
% The variable SHOWaminoACIDS defines which region to look at:
    
    
if isempty(SHOWaminoACIDS) 
    
    cAA = char(32*ones(size(cAA(:, 1))));    % a column of blanks
    
elseif isnumeric(SHOWaminoACIDS{1}) & isnumeric(SHOWaminoACIDS{2}) 
    
    cAA = cAA(:, SHOWaminoACIDS{1}:SHOWaminoACIDS{2});
    
elseif strcmp(SHOWaminoACIDS{2},'last3')
    
    cAA = DeleteLast3G(cAA, SHOWaminoACIDS{1});
    
elseif  isnumeric(SHOWaminoACIDS{1}) & strcmp(SHOWaminoACIDS{2},'end')
    
    cAA = cAA(:, SHOWaminoACIDS{1}:end);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if SDBxls was passed in, then use modifications from it. If it wasn't
% passed, then used singular modification

if isempty(SDBxls)
    % construct a column that contains the modification
    MOD = ones(size(AA0,1), numel(modification));

    for i=1:numel(modification)
        MOD(:,i) = modification(i)*MOD(:,i);
    end
    MOD = char(MOD);
    
    % fix this part later, it is very slow
    MOD = cellstr(MOD);

else
    
    if USE_NUMBERS
        disp('converted sequences to SDB numbers');

        % append the identified SDB numbers to amino acids. Convert numbers
        % to character array. In this array the numbers are aligned right.
        MOD = seq2mod(Nuc, 'SDBxlsdir', SDBxlsdir, 'SDBxls', SDBxls,...
                'modificationCol', 1, 'hdist', Hdist);

    else
        disp('converted sequences to SDB modifications');

        if MarkDirrefentSDB
            MOD = seq2mod(Nuc, 'SDBxlsdir', SDBxlsdir, 'SDBxls', SDBxls,...
                'modificationCol', 4, 'hdist', Hdist);
        else
            MOD = seq2mod(Nuc, 'SDBxlsdir', SDBxlsdir, 'SDBxls', SDBxls,...
                'modificationCol', 5, 'hdist', Hdist);
        end
    end     
end

if ~isempty(ladder)

    'im in ladder section'
    % pass the exiting MOD as modification and add ladder modificaitons on
    % top of it. Overwrite the MOD.
    MOD = seq2mod(Nuc, 'SDBxlsdir', ladderdir, 'SDBxls', ladder,...
            'modification', MOD, 'modificationCol', 4, 'hdist', Hdist);
end

% combine the modification, dash and trimmed peptide sequence and 
% conver the characters back to strings to find unique sequences
DASH = char(SEPARATOR*ones(size(cAA,1),1));

AA1 = cellstr([char(MOD) DASH cAA]);

[UNI,UFR] = uniqueCOMB(AA1,Fr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% save the result

    SP  = char(32*ones(size(UNI,1),1));

%%%%%%% faster alternative to num2str

 
%         temp1= sprintf('%d\n', UFR );
%         temp2 = textscan( temp1, '%s' );
%         cFr = char(temp2{1});

cFr = num2str(UFR);

%%%%

    cUN = char(UNI);
    
    % to make files readable on Windows, I use \r\n  instead of just \n
    % in ASCII this is char(13) followed by char(10). Th last lines has to
    % have space because othersie you end up with extra carriages and extra
    % blank line at the bottom of your text file
    RET  = char( [ 13*ones(size(UNI,1),1) 10*ones(size(UNI,1),1)] );
    RET(end,:) = char([32 32]);

    % 
    toSave=[cUN SP cFr RET];

    fh = fopen(fullfile(savepath,savename),'w');
    
    fprintf(fh, '%s', toSave');
    fclose(fh);
    
    fclose all;

    disp(['great success!  saved to ' savename]);

end

function [A,B,C] = fastread(fid)

temp = fileread(fullfile(DIR,file));
A = regexp(temp, '\s|\n');


end