function evalAlign()
%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = TODO;
testDir      = TODO;
fn_LME       = TODO;
fn_LMF       = TODO;
lm_type      = TODO;
% LMe = load('C:\Users\¬˜\Desktop\A2\e.mat');
% LME = LMe.LM;
% LMf = load('C:\Users\¬˜\Desktop\A2\f.mat');
% LMF = LMf.LM;
delta        = 0.001;
vocabSize = length(fields(LME.uni));
% numSentences = TODO;

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train( trainDir, 'e', fn_LME );
LMF = lm_train( trainDir, 'f', fn_LMF );


% Train your alignment model of French, given English 
AMFE = align_ibm1( trainDir, numSentences );
% ... TODO: more 
% AM = load('C:\Users\¬˜\Desktop\A2\AM1.mat');
% AMFE = AM.AM;

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  
lines = textread(['C:\Users\¬˜\Desktop\A2\Hansard\Testing', filesep, 'Task5.f'], '%s','delimiter','\n');
eng = [];
% Decode the test sentence 'fre'
for l=1:length(lines)
    disp(l);
    fre =  preprocess(lines{l}, 'f');
    eng{l} = decode2( fre, LME, AMFE, 'smooth', delta, vocabSize );
    disp(eng{l});
end

han_lines = textread(['C:\Users\¬˜\Desktop\A2\Hansard\Testing', filesep, 'Task5.e'], '%s','delimiter','\n');
han = [];
for l=1:length(han_lines)
    han{l} =  strsplit(' ', preprocess(han_lines{l}, 'e'));
end

goo_lines = textread(['C:\Users\¬˜\Desktop\A2\Hansard\Testing', filesep, 'Task5.google.e'], '%s','delimiter','\n');
goo = [];
for l=1:length(goo_lines)
    goo{l} =  strsplit(' ', preprocess(goo_lines{l}, 'e'));
end
result = '';
for l=1:length(lines)
    result = [result ', ' num2str(calculate_bleu(eng{l}, han{l}, goo{l}, 1))];
end
fid = fopen('C:\Users\¬˜\Desktop\A2\1.txt', 'wt');
fprintf(fid, result);
fclose(fid);
end
% TODO: perform some analysis
% add BlueMix code here 

% [status, result] = unix('')
%------------------------- BLEU ---------------------------
function score = calculate_bleu(can, han, goo, n)
    score = 1;
    han_len = length(han);
    goo_len = length(goo);
    can_len = length(can);
    if (abs(han_len-can_len)<abs(goo_len-can_len))
        brevity = han_len/can_len;
    else
        brevity = goo_len/can_len;
    end
    if brevity<1
        bp = 1;
    else
        bp = exp(1-brevity);
    end
    p=[];
    for i=1:n
        can_s = split_word_can(can, i);
        han_s = split_word(han, i);
        goo_s = split_word(goo, i);
        num = length(can)-(i-1);
        p{i} = cal_p(can_s, han_s, goo_s, i)/num;
    end
    for i=1:n
        score = score * p{i};
    end
    score = bp * power(score, 1/n);
    
end
function words = split_word_can(sen, n)
    sen_s = strsplit(' ', sen);
    for i= 1:(length(sen_s)-(n-1))
        words{i}=sen_s{i};
        for j = 1:(n-1)
            words{i}=[words{i} ' ' sen_s{i+j} ];
        end
    end
end

function words = split_word(sen, n)
    for i= 1:(length(sen)-(n-1))
        words{i}=sen{i};
        for j = 1:(n-1)
            words{i}=[words{i} ' ' sen{i+j} ];
        end
    end
end

function p = cal_p(can_s, han_s, goo_s, i)
    p = 0;
    can = unique(can_s);
    for i=1:length(can)
        count_c = count(can_s, can{i});
        count_h = count(han_s, can{i});
        count_g = count(goo_s, can{i});
        %----------------- Capping ----------------
        if or(count_c<=count_h, count_c<=count_g)
            p = p+count_c;
        else
            if count_h>count_g
                p=p+count_h;
            else
                p=p+count_g;
            end
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


    