function filterNewNames(varargin)
    if exist('varargin','var')
        L = length(varargin);
        if rem(L,2) ~= 0 
            error('Parameters/Values must come in pairs.'); 
        end

        % read input variables
        for ni = 1:2:L
            switch lower(varargin{ni})
                case 'sheetname',       DATE = varargin{ni+1};
                case 'unidir',          inDir = varargin{ni+1};
                case 'sdbdir',       SDBxlsDir=varargin{ni+1};
                case 'outdir',          outDir = varargin{ni+1};
            end
        end
    end
% this script will convert files from a specific date (recent)

fclose all;
fprintf("\nStart filtering unique files...\n");
% directory in which the matlab scripts are and where files that contains
% problematic names will be saved
savedir = '';

% directory that contains XX.xls and ladders
ladderDIR =  SDBxlsDir;
% directory in which all the files are and filtered files will be
baseDir = '';
DirUnique  = fullfile(baseDir,inDir);
DirFilter = fullfile(baseDir, outDir);


% get all the files from the directory
D = dir(fullfile(DirUnique,[DATE '*.txt']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% End of user-defined section %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DISPLAY =0;

% skip genentech Ab library #66. Its heavy and doesn't fit into any search
% skip ID PhD library #75
% don't worry about the liquid glycan array for now
%skipLibraries = {'66', '75', '87'};
skipLibraries = {''};

% Flag 20 and 21 because these libraries require special tratment
% they should not be present in samples today! 
SpecialTreatment =  {'20', '21'};

FID = fopen(fullfile(savedir,'notconverted.txt'),'w+'); 
fclose(FID); % open and close to clear the content
h = waitbar(0,['processing ' num2str(numel(D)) ' files ...']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % parse the sequence names
    names = char(D.name);
    
    one = '(?<date>\d{8})-R\d+F\d+-_?(?<lib>\d{2,3})_?(?<mod>[A-Z]{1,2})';
    two = '_?(?<tar>\S+)(?<round>\d+-\d+)([A-Z]{2}\d{1,2}|\S*).txt';

    expression = [one two];
    
    for ii=1:numel(D)
        found = regexp(names(ii,:), expression, 'names');
        LIB{ii} = found(1).lib;
        MOD{ii} = found(1).mod;
        TAR{ii} = found(1).tar;
    end
    cLIB = char(LIB);
    cMOD = char(MOD);
    cTAR = char(TAR);
    
    [~,I] = sort(TAR);
    clear LIB MOD TAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

CLOCK0 = clock;


for i=1:numel(D)
    waitbar(i / numel(D));
    CLOCK1 = clock;
    TIME = CLOCK1-CLOCK0;
    disp(num2str(TIME(5:6)));
    fclose all;  % close all files if some were accidentally left open
    
    ReadFile = D(i).name;

    SaveFile = [ReadFile(1:end-4) '_filtered.txt'];

    % if the name cannot be parsed, skip the file
    if isempty(found)
        FID = fopen(fullfile(savedir,'notconverted.txt'),'a+');
        fprintf(FID, '%s\n', ['Did not find in Excel this name  '  ReadFile]);
        fclose(FID);
        disp([ReadFile ' NOT FOUND!!!!!!!!!!!!!!!!!!!!!!']);
        continue
    end

    modification = [cMOD(i,:) '0'];
    library = cLIB(i,:);

    % determine whether file has SDB or not
    FID = fopen(fullfile(DirUnique, ReadFile),'r');
    hasSDB = issdb(FID, ReadFile);
    fclose(FID);
    disp('here')    
    % if SDB/not-SDB cannot be defined, do not open the file
    if isnan(hasSDB)
        FID = fopen(fullfile(savedir,'notconverted.txt'),'a+');
        fprintf(FID, '%s\n', ['WTFormart in   '  ReadFile]);
        fclose(FID);
        continue
    end
    
    % if file has libraries from the "skip" list, skip them
    if sum(strcmp(library, skipLibraries))
        FID = fopen(fullfile(savedir,'notconverted.txt'),'a+');
        fprintf(FID, '%s\n', ['Skipping      '  ReadFile]);
        fclose(FID);
        continue
    end
    
    % by default the excel file with diverse modifications is empty, but
    % it can be overwritten in the next section
    SDBxls = '';
    
    % if file has libraries from the "special" list, skip them for now
    if sum(strcmp(library, SpecialTreatment))
        
        if strcmp(library,'20') & strcmp(modification,'XX0')
            modification = 'OO0';
        elseif strcmp(library,'21') & strcmp(modification,'XX0')
            modification = 'XX2016';
            SDBxls = 'XX2016.xlsx'; 
        end
    else
        switch modification(1:2)
            case 'XA',    SDBxls = 'XA.xlsx'; 
            case 'XB',    SDBxls = 'XB.xlsx'; 
            case 'XC',    SDBxls = 'XC.xlsx'; 
            case 'XX',    SDBxls = 'XX.xlsx';
            case 'XY',    SDBxls = 'XY.xlsx';
            case 'YX',    SDBxls = 'YX.xlsx';
            case 'YY',    SDBxls = 'YY.xlsx';
            case 'YZ',    SDBxls = 'YZ.xlsx';
            case 'YA',    SDBxls = 'YA.xlsx'; 
            case 'YB',    SDBxls = 'YB.xlsx';
            case 'CX',    SDBxls = 'CX.xlsx';
        end   
    end
    

    % by default, there are no ladders in the mixture, but the next section
    % can over-write the variable
    % ladderDIR = '';
    if ~hasSDB
        SHOWaminoACIDS = {0, 'last3'}; % trim only last 3 characters
        ladderXLS = 'ladders.xlsx';    
    else
        SHOWaminoACIDS = {17, 'last3'};  % trim first 17 and last 3 characters
        ladderXLS = 'ladders.xlsx'; 
    end
    
% at this point, all variables should be defined. You can employ one
% conversion function.


     unfiltered2filteredFUNCTION2('File', ReadFile, 'Dir', DirUnique,...
                 'SaveName', SaveFile, 'SavePath', DirFilter,...
                 'SDBxls', SDBxls, 'SDBxlsDir', SDBxlsDir,...
                 'modification', modification,...
                 'Use_Numbers', 0, 'MarkDifferentSDB', 1,...
                 'SHOWaminoACIDS', SHOWaminoACIDS,...
                 'ladder', ladderXLS,'ladderdir',ladderDIR,...
                 'DISP', DISPLAY,...
                 'separator', ' ');

    
             
end % of for-cyclig through all files
close(h);       
