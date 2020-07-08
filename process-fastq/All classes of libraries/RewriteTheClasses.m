%%%%%%%%%%%%%%%% change this part only is your vector is different %%%%%%%%
genentech.FA = 'AGCTGAGGACACTGCCGTCTA';    % Nick's forward adapter
genentech.RA = 'TGGTCACCGTCTCCTCGGCC';     % Nick's reverse adapter
genentech.SEQ = '[ATCG]*';   %'TCTGCGTGTTAGTAGGTGTGTGGTGGAGGT';
genentech.LOCATION = 5:46;

DIR = './';
save(fullfile(DIR,'genentech.mat'),'genentech');

M13KE.FA = 'CCTTTCTATTCTCACTCT';        % default forward adapter sequence
M13KE.RA = 'TCGGCCGAAACTGT';            % default forward adapter sequence
% M13KE.FA = 'TTGGAGATTTTCAACGTG';         % this time
% M13KE.RA = 'TCGGCCGGGCGCGT';             % this time
M13KE.SEQ = '[ATCG]*';

save(fullfile(DIR,'M13KE.mat'), 'M13KE');


SDB.FA = 'TTGGAGATTTTCAACGTG';    % SDB forward adapter sequence
SDB.RA = 'TCGGCCGAAACTGT';    % SDB reverse adapter sequence

SDB.SEQ = '[ATCG]*';

save(fullfile(DIR,'SDB.mat'), 'SDB');

Synthetic.FA = 'CCTTTCTATTCTCACTCT';
Synthetic.RA = 'TCGGCCGGGCGCGT';
Synthetic.SEQ = '[ATCG]*';

save(fullfile(DIR,'Synthetic.mat'),'Synthetic');

PrimerID.FA = 'CCTTTCTATTCTCACTCT';
PrimerID.RA= 'TCGGCCGGGCGC';
PrimerID.SEQ = '[ATCG]*';

save(fullfile(DIR,'PrimerID.mat'),'PrimerID');

Intra_domain.FA = 'GTGGTGGCGAGCTCGCTCACCTGTATTTTCAGTCG';
Intra_domain.RA = 'ACTAGTTCTGAGGGTGGCGGTTCTGAGGGTGGCGGTACTAAACCTCCTGAG';
Intra_domain.SEQ = '[ATCG]*';

save(fullfile(DIR,'Intra_domain.mat'),'Intra_domain');


%%%%%%%%%%%%%%%%%%%%%%%%14-bp ID primers%%%%%%%%%%%%%%%%%%%%%%%%%

Intra_domain2.FA = 'GTGGTGGCGAGCTC';
Intra_domain2.RA = 'GGTACTAAACCTCCTGAG';
Intra_domain2.SEQ = '[ATCG]*';

save(fullfile(DIR,'Intra_domain2.mat'),'Intra_domain2');

%%%%%%%%%%%%%%%%%%%%%%%16-bp ID primers%%%%%%%%%%%%%%%%%%%%%%%%%%%

Intra_domain3.FA = 'GGGTGGTGGCGAGCTC';
Intra_domain3.RA = 'GGTACTAAACCTCCTGAGTA';
Intra_domain3.SEQ = '[ATCG]*';

save(fullfile(DIR,'Intra_domain3.mat'),'Intra_domain3');

%%%%%%%%%%%%%%%%%%%%%%%%%%%18-bp ID primer%%%%%%%%%%%%%%%%%%%%%%%%

Intra_domain4.FA = 'GAGGGTGGTGGCGAGCTC';
Intra_domain4.RA = 'GGTACTAAACCTCCTGAGTACG';
Intra_domain4.SEQ = '[ATCG]*';

save(fullfile(DIR,'Intra_domain4.mat'),'Intra_domain4');


barLocation=5:7;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

