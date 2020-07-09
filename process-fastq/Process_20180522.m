

%% paired_end_processing.m Script
% This is the top-level script for processing deep-sequencing data from
% Illumina. It's function is to perform preliminary parsing of paired-end
% reads.

% Authors: Ratmir Derda, Bifang He, J Maxwell Douglas
% Last Modifed: June 13th, 2017

% define the name of the directory, excel file and one FASTQ file
clc;
clear;
addpath (genpath(pwd));
AllLibraries  = './All classes of libraries';
AllExcelFiles = './AllExcelFiles';
%%% Initialisation of POI Libs
% Add Java POI Libs to matlab javapath
javaaddpath('poi_library/poi-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
javaaddpath('poi_library/xmlbeans-2.3.0.jar');
javaaddpath('poi_library/dom4j-1.6.1.jar');
javaaddpath('poi_library/stax-api-1.0.1.jar');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% USER SECTION

% Place ONE excel file into the ./AllExcelFiles folder and use the
% name of that ONE file in xlsname variable.
xlsname = dir(fullfile(AllExcelFiles, '20180522.xlsx'));
%------------------------------------------^here

% This is the name of the excel sheet within the excel file.
sheetname = '20180522';

indir = './FastQfiles';  % directory where FASTQ.GZ files are


% This is a list of all SDBs that have been defined by ID#.
% This must be kept up-to-date. I.E. should knew ones be defined, they must
% be added to this list. (Found on Derda Lab website google doc called "How
% to name Illumina Samples")
SDB_numbers = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';...
               '11';'12';'13';'14';'15';'16';'17';'18';'19';'20';...
               '21';'22';'23';'24';'25';'26';'27';'28';'29';'30';...
               '31';'32';'33';'34';'35';'36';'37';'38';'39';'40';...
               '41';'42';'43';'44';'45';'46';'47';'48';'49';'50';...
               '51';'52';'53';'54';'55';'56';'57';'58';'59';'60';...
               '61';'62';'63';'64';'65';'66';'67';'68';'69';'70';...
               '71';'72';'73';'74';'75';'76';'77';'78';'79';'80';...
               '81';'82';'83';'84';'85';'86';'87';'88';'89';'90';...
               '91';'92';'93';'94';'95';'96';'97';'98';'99';'100';...
               '101';'102';'103';'104';'105';'106';'107';'108';'109';'110';...
               '111';'112';'113';'114';'115';'116';'118';'117';'119';'120';...
               '121';'122';'123';'124';'125';'126';'127';'128';'129';'130';...
               '131';'132';'133';'134';'135';'136';'137';'138';'139';'140';...
               '141';'142';'143';'144';'145';'146';'147';'148';'149';'150';}; 

% This is a list of all genetec libraries that have been defined by ID#.
% This must be kept up-to-date. I.E. should knew ones be defined, they must
% be added to this list.
Genetec_numbers = ['66']; 

% all aligned files from this data set will have this prefix; change it
% please or else it will be very confusing. Date of sequencing is the best
% prefix as of this moment (please do not remove the '-*', just modify 
% the date). 
files = '20180522-*.txt';
%--------^------^

% List your fastq.gz files below for the rname and fname variables.
% 1. Make sure to match ...R1_001.fastq.gz files to rname and
%                       ...R2_001.fastq.gz files to fname.
% 2. Make sure the L00X numbers are in order from 1 to 4 for both variables.
% 3. Make sure your .gz files are in the 'AllFastqFiles' folder.

rname = {'LiGA-example_R1.fastq.gz'...
         };

    
fname = {'LiGA-example_R2.fastq.gz'...
    };

outdirTAB = './AllTableFiles/20180522'; % change to sequencing date

uniqueSummaryDir = './UniqueSummary';
    
% End of User defined section %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Do not change anything below unless you know what you are doing  %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%

AllBarFiles = './AllBarFiles';
AllRAWFiles = './AllRAWFiles';
unidir = './AllUniqueFiles';
pardir = './AllParsedFiles';
Statis = './Statis';

fprintf("Removing all the files from previous processing on this date...\n");
outname = ['*' sheetname '*'];
folderList = {AllBarFiles; AllRAWFiles; unidir; pardir; Statis};
for id=1:length(folderList)
    checkdir = folderList{id};
    tmp = dir(fullfile(checkdir,outname));
    for i = 1:length(tmp)
        if exist(fullfile(checkdir,tmp(i).name),'file')==2
            delete(fullfile(checkdir,tmp(i).name));
        end
    end
end
 
% % clear table files
tmp = dir(outdirTAB);
for i = 1:length(tmp)
    if (exist(fullfile(outdirTAB,tmp(i).name),'file')==2)
        delete(fullfile(outdirTAB,tmp(i).name));
    end
end
% 
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %%%%%%%%%% Definition of sequencing barcodes; do not change %%%%%%%%%%%%%%%
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B.FB={'AAGC';'ACTG';'AGAA';'TAAT';'TTCA';'TGGG';'CACG';'CTGT';'CCAC';'GTAG';
   'GCGA';'GGTT';'AATA';'ATTT';'ATGG';'ACCA';'ACGT';'AGTC';'AGCT';'TACC'};
% 
% 
% % for this processing only!! R9 = GTGG
B.RB={'GCTT';'CAGT';'TTCT';'ATTA';'TGAA';'CCCA';'CGTG';'ACAG';'GTGG';'GTAC';
    'TCGC';'AACC';'TATT';'AAAT';'CCAT';'TGGT';'ACGT';'GACT';'AGCT';'GGTA'};
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
newline = [char(13) char (10)]; % enforse the Windows type newline!
% 
% 
% % This part parses the FASTQ file, extracts raw sequences with mapped
% % % forward and reverse barcodes and saves 
fastq2bar('indir', indir, 'allexcelfiles',AllExcelFiles,'fname', ...
        fname,'rname', rname,'outdir',AllBarFiles,'chunk',500000, ...
       'saveNOmatch', 0,'saveNObar', 0,'saveRAW', 0, 'files', files,...
       'barcodes', B, 'xlsname', xlsname, 'sheetname',sheetname,...
       'statistis',Statis, 'delimiter', '@', 'newline', newline, 'rn', 17, 'fn', 20);
% 
% %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % This part parses sequences with mapped barcodes, does alignment and saves
% % generated files to the 'AllRAWFiles' folder
fastq2aligned('indir', AllBarFiles,'outdir',AllRAWFiles,'chunk',500000, ...
       'delimiter', '@','NMismatches',4,'minimumMatch',15,...
       'newline', newline, 'files', files, 'statistis',Statis);
% 
% %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
 if strcmp(files,'all')
      Nucname = dir(fullfile(AllRAWFiles,'*-R*F*.txt'));
 else
      Nucname = dir(fullfile(AllRAWFiles,files));
 end
%  
% % This function converts an excel table of sample names to the type of
% % library and separates the samples based on this distinction.
[X, Samples] = name2librarytype('allexcelfiles',AllExcelFiles, ... 
                                'xlsname', xlsname,... 
                                'sheetname', sheetname,...
                                'sdb_numbers', SDB_numbers,...
                                'gen_numbers', Genetec_numbers,...
                                'rn', 17, 'fn', 20);
% % Samples 
% % 1.SDB_sam 
% % 2.Synthetic_sam 
% % 3.PrimerID_sam 
% % 4.Genentech_sam 
% % 5.M13KE_sam 
valueSet =   {'SDB', 'Synthetic', 'PrimerID', 'genentech', 'M13KE'};
keySet = [1, 2, 3, 4, 5];
mapObj = containers.Map(keySet,valueSet);
% 
numclass = size(mapObj,1);
Num_M0 = cell(1,numclass);
Num_mapped = cell(1,numclass);
Num_unique = cell(1,numclass);
% 
% % For each library type identified, generate UNIQUE and PARSED files.
for i=1:size(X,1)
%     
    Num_M0{1,i} = zeros(20,17);
    Num_mapped{1,i} = zeros(20,17);
    Num_unique{1,i} = zeros(20,17);
    
    if X(i,1)
        % extract the name of the library from the XLS name
        NameofLibraryString = mapObj(i);

%         % load the structure
        load(fullfile(AllLibraries,  NameofLibraryString ));
% 
%         % since the structures that you load have different names, you want to
%         % convert them to one structure that has the same name. this
%         % "MyStructure" variable can be passed as structure to the next
%         % function. You cannot pass a name of the structure, you have to pass
%         % the structure itself. The operation below, makes a pseudo matlab code
%         % from strings and executes it. Very convenient. 
% 
        eval(['MyStructure = ' NameofLibraryString ]);
% 
% 
        disp(['Processing ' files ' using '  NameofLibraryString ]);
% 
%         % Create parsed files with untrimmed adapters and save them to the
%         % 'AllParsedFiles' folder. Then trim the adapters and agglomerate
%         % counts for each unique sequence in the file and save these new
%         % files to the 'AllUniqueFiles' folder.
%         
       [Num_M0{1,i},Num_mapped{1,i},Num_unique{1,i}]= aligned2unique('indir', AllRAWFiles,...
            'files',files, 'samplenames', Samples{i},...
            'unidir', unidir, 'parsedir', pardir,...        
            'library', MyStructure,...
            'Barcodes', B, 'adaptermatch', 'mutant',...       
            'chunk',500000, 'newline', newline,...
            'M0', Num_M0{1,i}, 'mapped', Num_mapped{1,i},...
            'unique', Num_unique{1,i});
    end
end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Combine samples of each class together
Nomis = zeros(20,17);
N_mapped = zeros(20,17);
N_unique = zeros(20,17);
for i =1:numclass
    
    Nomis = Nomis+Num_M0{1,i};
    N_mapped = N_mapped + Num_mapped{1,i};
    N_unique = N_unique + Num_unique{1,i};
end
% 
% %save the number of reads with no mismatches
% %save the number of reads with mapped adapters
% %save the number of unique reads
Fstatis = fullfile(Statis,[files(1:9) 'statistic.xlsx']);
startRange1 = 'B23';
startRange2 = 'B44';
startRange3 = 'B65';
xlwrite(Fstatis,num2cell(Nomis),'Sheet1',startRange1);
xlwrite(Fstatis,num2cell(N_mapped),'Sheet1',startRange2);
xlwrite(Fstatis,num2cell(N_unique),'Sheet1',startRange3);
%    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % Create a table file based on two character identifier for each individual
% % with samples on this sequencing run. Tables are built from the UNIQUE
% % files. Each table file contains all of an individual's samples. Table
% % files are saved to the 'AllTableFiles' folder.
tags2table('indir', unidir, 'outdir', outdirTAB, 'files', files )

% filter unique files by Jessica
SummariseUniqueFiles(unidir, uniqueSummaryDir, sheetname);
%filterNewNames('sheetname', sheetname,'unidir',unidir,'sdbdir', 'ProcessingUniqueFiles', 'outdir','FilteredFiles');
%unique2table('sheetname', sheetname,'indir', './FilteredFiles', 'outdir','DatabaseFiles');


% File End
