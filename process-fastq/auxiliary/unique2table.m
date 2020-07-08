%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by Jessica CAO, modified from some scripts of Ratmir            %
% date: 2017-11-20                                                        %
% modified: 2018-01-10                                                    %
% UPDATE: add variable Date, user change the Date of the most current     %
% sequencing                                                              %
% UPDATE: the current filtered unique files changed to 3 cols             %
% UPDATE_V1: keep the original frequencies                                %
%         keep the total frequency in the first row                       %
% this script groups all the filtered unique files small table files      %
% grouped by their date, library, modification, target, and postprocessing%
% NOTE:                                                                   %
%   1. since this script uses all the filtered unique files, the name     %
%       the name of the unique file is assumed correct (could passing the %
%       name checking rule)                                               %
%   2. the number in the resulting small table file will be normalized PPM% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function unique2table(varargin)
    if exist('varargin','var')
        L = length(varargin);
        if rem(L,2) ~= 0 
            error('Parameters/Values must come in pairs.'); 
        end

        % read input variables
        for ni = 1:2:L
            switch lower(varargin{ni})
                case 'sheetname',       DATE = varargin{ni+1};
                case 'indir',           inDir = varargin{ni+1};
                case 'outdir',          outDir = varargin{ni+1};
            end
        end
    end

% directory in which the matlab scripts are
baseDir = '';
DirFiltered  = fullfile(baseDir,inDir);
Dir1 = fullfile(baseDir,outDir);
logDir = fullfile(baseDir,'Log');

if ~exist(Dir1,'dir')
    mkdir(Dir1);
end

if ~exist(logDir,'dir')
    mkdir(logDir);
end
% directory in which all the files are and filtered files will be
% DirFiltered = fullfile(DirAll, 'Filtered');
% uConvertedList = "/media/Data/SequenceSearchingProject/remainingUniqueFiles/unconvertedNames.txt";

% skipNames = readtable(uConvertedList,"Delimiter"," ","ReadVariableNames",false);
% skipNames = skipNames.Var1;
log_Filtered = 'skipFiltered_log.csv';
log_Table = 'skipTable_log.csv';
fid_logFiltered = fopen(fullfile(logDir,log_Filtered),'w');
fid_logTable = fopen(fullfile(logDir,log_Table),'w');


% list all the file names from the directory
Files = strcat(DATE,"-*.txt");
Files = char(Files);
FileNames = dir(fullfile(DirFiltered,Files));
FileNames = struct2table(FileNames);
FileNames = FileNames.name;

% index = ones(length(FileNames),1);
% for i=1:length(FileNames)
%     tmp = find(contains(skipNames,FileNames{i}));
%     if ~isempty(tmp)
%         index(i) = 0;
%     end
% end
% 
% FileNames = FileNames(index~=0);
% defined if the result should be normalized and multiplied by 10^6, then
% rounded

NORMALIZED = 0;

% explanations
% _?      there could be zero or one occurences of underscore characters
% \d{8}   exactly eight occudences of numeric characters
% \S{2}   exactly two occurences of any character BUT space
% d+-\d+  one or more number, then dash then one or more number 1-2, 1-11
thestart = '(?<date>\d{8})-(?<primer>R\d+F\d+)-_?(?<lib>\d+)_?(?<mod>[A-Z]+)';
theend = '(?<tar>[a-z]+)(?<post>[A-Z]+)(?<round>\d+-\d+)(?<tag>([A-Z]{2}|\S*))(?\d{1,2}|\S*)_filtered.txt';
expression = [thestart theend];
% get the forward and backward primer info as column name for later
% colNameExpression = '-(?<primer>R\d+F\d+)-';

% parse the file names, and group them according to date, lib, mod, tar,
% and tag
UniqueFile = cellfun(@(x) regexp(x,expression,'names'), FileNames, 'UniformOutput',0); 
UniqueFile = cell2mat(UniqueFile);
UniqueFileTbl = struct2table(UniqueFile);
UniqueFile = strcat(UniqueFileTbl.date,'-', UniqueFileTbl.lib, UniqueFileTbl.mod, UniqueFileTbl.tar,UniqueFileTbl.post,'-', UniqueFileTbl.tag);
UniqueGroups = findgroups(UniqueFile);
totalGroups = length(unique(UniqueGroups));

% process through all the groups
for i= 1:totalGroups
    % find the first name in each group, set it to the table file name
    SaveFile = strcat(UniqueFile(find(UniqueGroups==i, 1)),'.txt');
    % get the list of the unique files in the current group
    uFileList = FileNames(UniqueGroups==i);
    fprintf("Generating %d/%d for %s from %d Unique Files...\n", i, totalGroups, SaveFile{1}, length(uFileList));
    for j = 1:length(uFileList)
        fprintf("%d: %s\n",j, uFileList{j});
    end
    fprintf("......\n");
    
    clear tmp;
    % go through file list to union all the unique files in the current
    % group
    for j=1:length(uFileList)
        filePath = fullfile(DirFiltered, uFileList(j));
        % get the forward and backward primer info as the column name
        colName = regexp(uFileList(j), expression,'names');
        if length(colName{1}.round) >0 
            colName{1}.round = strrep(colName{1}.round,'-','_');
            colName = strcat(colName{1}.primer,'_',colName{1}.round);
        else 
            colName = colName{1}.primer;
        end
        % read the data in the file
        FID = fopen(filePath{1},'r');
        uData = textscan(FID,'%s %s %f %*[^\n]');
        fclose(FID);
        
        Mod = uData{1};
        Seq = uData{2};
        Freq = uData{3}; % store the frequency column in Freq
        if ~isequal(length(Mod),length(Seq), length(Freq))
            fprintf("Error: %s is not in the correct format!\n",uFileList{j});
            fprintf(fid_logFiltered,'%s\n',uFileList{j});
            continue;
        end
        
        %check is seq is all letters
        valSeq = cellfun(@(x) sum(isletter(x))==length(x), Seq);
        Seq = Seq(valSeq);
        Mod = Mod(valSeq);
        Freq = Freq(valSeq);
        
        uData = table(Mod,Seq,Freq);
        uData.Properties.VariableNames={'Mod','Seq', colName};
        
        % if this is the first unique file in the current group, then set
        % the uData table to tmp, otherwise use outerjoin to merge uData
        % with tmp by keys 'Seq' and 'Mod', NaN will be used to fill empty
        % cell
        if ~exist('tmp','var')
            tmp = uData;
        else
            tmp = outerjoin(tmp, uData, 'MergeKeys',1);
        end
        clear uData;
    end
    
    if ~exist('tmp')
        fprintf(fid_logTable,'%s\n',SaveFile{1});
        continue;
    end
    % get rid of rows with empty seqence
    empty = cellfun(@isempty, tmp.Seq);
    tmp = tmp(~empty,:);
    
    % convert NaN into 0
    tmp2 = tmp{:,3:end};
    tmp2(isnan(tmp2)) = 0;
    
    % compute the total frequency of each column
    coltotal = sum(tmp2,1);
    tmp{:,3:end} = tmp2;
    firstRow = {"XX","TOTAL"};
    for x=1:length(coltotal)
        firstRow{end+1}=coltotal(x);
    end
    
    tmp0=[firstRow;tmp];
    
    % write the table into file, with the first row as the column names,
    % and columns are separated by space
    savePath = fullfile(Dir1, SaveFile);
    writetable(tmp0, savePath{1}, 'WriteVariableNames', true, 'Delimiter',' ');
end 

fclose(fid_logFiltered);
fclose(fid_logTable);