function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);
  
  logProb = 0;
  
  switch delta
      case 0
          for i=1:length(words)-1
              if isfield(LM.uni, words{i})
                  if isfield(LM.bi.(words{i}), words{i+1})
                      logProb = logProb + log2(LM.bi.(words{i}).(words{i+1})/LM.uni.(words{i}));
                  else
                      logProb = -Inf;
                      return
                  end
              else
                  logProb = -Inf;
                  return
              end
          end
      otherwise
          for i=1:length(words)-1
              if isfield(LM.uni, words{i})
                  if isfield(LM.bi.(words{i}), words{i+1})
                      logProb = logProb + log2(add_delta_smooth(LM.uni.(words{i}), LM.bi.(words{i}).(words{i+1}), delta, vocabSize));
                  else
                      logProb = logProb + log2(add_delta_smooth(LM.uni.(words{i}), 0, delta, vocabSize));
                  end
              else
                  logProb = logProb + log2(add_delta_smooth(0, 0, delta, vocabSize));
              end
          end
  end
          
      
  % TODO: the student implements the following
  % TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.
return

function prob = add_delta_smooth(unicount, bicount, del, size)
    prob = (bicount+del)/(unicount+del*size);
return 