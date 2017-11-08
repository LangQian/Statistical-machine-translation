function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end
  
  AM.SENTSTART.SENTSTART = 1;
  AM.SENTEND.SENTEND = 1;

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  %eng = {};
  %fre = {};

  % TODO: your code goes here.
eng = {numSentences};
fre = {numSentences};
DDE = dir( [ mydir, filesep, '*', 'e'] );
DDF = dir( [ mydir, filesep, '*', 'f'] );
count = 0;
for iFile=1:length(DDE)
  lines_e = textread([mydir, filesep, DDE(iFile).name], '%s','delimiter','\n');
  lines_f = textread([mydir, filesep, DDF(iFile).name], '%s','delimiter','\n');

  for l=1:length(lines_e)
    count = count + 1;
    eng{count} = strsplit(' ',preprocess(lines_e{l}, 'e'));
    fre{count} = strsplit(' ',preprocess(lines_f{l}, 'f'));
    if count == numSentences
        return
    end
  end
end
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)

    % TODO: your code goes here
    for i=1:length(eng)
        for j=1:length(eng{i})
            for k=1:length(fre{i})
                if not(isfield(AM, eng{i}{j}))
                    AM.(eng{i}{j}).(fre{i}{k}) = 1;
                else
                    if not(isfield(AM.(eng{i}{j}), fre{i}{k}))
                        AM.(eng{i}{j}).(fre{i}{k}) = 1;
                    end
                end
            end
        end
    end
    eng_fields = fieldnames(AM);
    eng_num = numel(eng_fields);
    for i=1:eng_num
        fre_fields = fieldnames(AM.(eng_fields{i}));
        fre_num = numel(fre_fields);
        for j=1:fre_num
            AM.(eng_fields{i}).(fre_fields{j})=1/fre_num;
        end
    end
    AM.SENTSTART.SENTSTART = 1;
    AM.SENTEND.SENTEND = 1;
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  
  % TODO: your code goes here
  counter = {};
   for i=1:length(eng)
        for j=1:length(eng{i})
            for k=1:length(fre{i})
                if not(isfield(counter, eng{i}{j}))
                    counter.(eng{i}{j}).(fre{i}{k}) = 0;
                    counter.(eng{i}{j}).total = 0;
                else
                    if not(isfield(counter.(eng{i}{j}), fre{i}{k}))
                        counter.(eng{i}{j}).(fre{i}{k}) = 0;
                    end
                end
            end
        end
   end
   for i=1:length(eng)
       uni_f = unique(fre{i});
        for j=1:length(uni_f)
            denom_c = 0;
            uni_e = unique(eng{i});
            for k=1:length(uni_e)
                denom_c = denom_c + t.(uni_e{k}).(uni_f{j}) * count(fre{i}, uni_f{j});
            end
            for k=1:length(uni_e)
                add = t.(uni_e{k}).(uni_f{j}) * count(fre{i}, uni_f{j}) * count(eng{i}, uni_e{k}) / denom_c;
                counter.(uni_e{k}).(uni_f{j}) = counter.(uni_e{k}).(uni_f{j}) + add;
                counter.(uni_e{k}).total = counter.(uni_e{k}).total + add;
            end
        end
   end
   eng_fields = fieldnames(counter);
   eng_num = numel(eng_fields);
   for i=1:eng_num
       fre_fields = fieldnames(counter.(eng_fields{i}));
       fre_num = numel(fre_fields);
       for j = 1:fre_num
           t.(eng_fields{i}).(fre_fields{j}) = counter.(eng_fields{i}).(fre_fields{j})/counter.(eng_fields{i}).total;
       end
   end
end

function num = count(cell, element)
    num = 0;
    for i=1:length(cell)
        if strcmp(cell{i}, element)
            num = num + 1;
        end
    end
end
