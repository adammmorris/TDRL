% sequential choice expt
% ND, October 2006

clear all

ptbpath = 'C:\toolbox\Psychtoolbox';
addpath([ptbpath '/PsychBasic']);
addpath([ptbpath '/PsychBasic/MatlabWindowsFilesR2007a']);
addpath([ptbpath '/PsychOneliners']);
addpath([ptbpath '/PsychPriority']);
addpath([ptbpath '/PsychJava']);
addpath([ptbpath '/PsychAlphaBlending'])
addpath([ptbpath '/PsychRects'])

thispath = 'C:\Personal\School\Brown\Psychology\TDRL Project\Dawes 2-Step Task\sequentialPTB';
addpath(thispath);


Screen('Preference', 'SkipSyncTests', 1);


cd(thispath);

HideCursor

% specify the task parameters
global leftpos rightpos boxypos moneyypos moneyxpos animxpos animypos moneytime ...
    isitime ititime choicetime moneypic losepic inmri keyleft keyright...
    starttime ;

totaltrials=201;    %total number of trials in the task
transprob =.7;    % probability of 'correct' transition

[xres,yres] = Screen('windowsize',0);
xcenter = xres/2;
ycenter = yres/2;

leftpos = xcenter-125-100;
rightpos = xcenter+125-100;
boxypos = ycenter-50;

moneyypos = ycenter-round(75/2);
moneyxpos = xcenter-round(75/2);

animxpos = 0:25:125;
animypos = 0:25:125;

moneytime = round(1000 / 90);
isitime = round(1000 / 90);
ititime = round(1000 / 90);
choicetime = round(2000 / 90);

numbreaks = 2;

% set break times

% b = 1:blocklength:totaltrials;
% b(1)=[];

b = 0:round(totaltrials/(numbreaks+1)):totaltrials;
b(1) = [];
if totaltrials - b(length(b)) < round(totaltrials/(numbreaks+1))*0.5
    b(length(b)) = [];
end

inmri = 0;  % set to 1 to time everything to slices

% if inmri
%     % right handed button box
%     keyleft = 80; %[5]
%     keyright = 81;%[6]
% else
    keyleft = KbName('u');%[u]
    keyright = KbName('i');%[i]
% end

numrewardedtrials = round(totaltrials/3);

% enter subject details
name=input('Subjects initials? ','s');
number=input('Subjects number? ');
%session = input('Session? ');

load behav/masterprob
% if session == 1
%     payoff = payoff(:,:,1:67);
% elseif session == 2
%     payoff = payoff(:,:,68:134);
% elseif session == 3
%     payoff = payoff(:,:,135:201);
% end
    
% create iti jitter matrix, mean 18 slices

jitter = zeros(1,totaltrials);

%jitter = repmas([0:2:18],1,ceil(totaltrials/10));
%jitter = [repmat([0:2:18],1,6),[3:2:15]];
%ind    = randperm(length(jitter));
%jitter = jitter(ind);
%jitter = jitter * 2;


% configure cogent a=settings
%config_display(1,1,[0.4 0.4 0.4],[1 1 1], 'Arial', 20, 3)
%config_log
%config_keyboard(100,5,'exclusive' )
%if (inmri)
%    config_serial(1);
%end
%cgloadlib

%set random number generator
rand('state',sum(100*clock));
%start_cogent

starttime = GetSecs*1000;

% Load the figures

t(1,1).norm=imread('behav/stim1.png');
t(1,1).deact=imread('behav/stim1-d.png');
t(1,1).act1=imread('behav/stim1-a1.png');
t(1,1).act2=imread('behav/stim1-a2.png');
t(1,1).spoiled=imread('behav/stim1-s.png');

t(1,2).norm=imread('behav/stim2.png');
t(1,2).deact=imread('behav/stim2-d.png');
t(1,2).act1=imread('behav/stim2-a1.png');
t(1,2).act2=imread('behav/stim2-a2.png');
t(1,2).spoiled=imread('behav/stim2-s.png');

t(2,1).norm=imread('behav/stim3.png');
t(2,1).deact=imread('behav/stim3-d.png');
t(2,1).act1=imread('behav/stim3-a1.png');
t(2,1).act2=imread('behav/stim3-a2.png');
t(2,1).spoiled=imread('behav/stim3-s.png');

t(2,2).norm=imread('behav/stim4.png');
t(2,2).deact=imread('behav/stim4-d.png');
t(2,2).act1=imread('behav/stim4-a1.png');
t(2,2).act2=imread('behav/stim4-a2.png');
t(2,2).spoiled=imread('behav/stim4-s.png');

t(3,1).norm=imread('behav/stim5.png');
t(3,1).deact=imread('behav/stim5-d.png');
t(3,1).act1=imread('behav/stim5-a1.png');
t(3,1).act2=imread('behav/stim5-a2.png');
t(3,1).spoiled=imread('behav/stim5-s.png');

t(3,2).norm=imread('behav/stim6.png');
t(3,2).deact=imread('behav/stim6-d.png');
t(3,2).act1=imread('behav/stim6-a1.png');
t(3,2).act2=imread('behav/stim6-a2.png');
t(3,2).spoiled=imread('behav/stim6-s.png');

moneypic = imread('behav/dollar.png');
losepic = imread('behav/nothing.png');

% initialise data vectors

choice1 = zeros(1,totaltrials);         % first level choice
choice2 = zeros(1,totaltrials);         % second level choice
state = zeros(1,totaltrials);           % second level state
pos1 = rand(1,totaltrials) > .5;        % positioning of first level boxes
pos2 = rand(1,totaltrials) > .5;        % positioning of second level boxes
rts1 = zeros(1,totaltrials);            % first level RT
rts2 = zeros(1,totaltrials);            % second level RT
money = zeros(1,totaltrials);           % win

stim1_ons_sl = zeros(1,totaltrials);    % onset of first-level stim, slices
stim1_ons_ms = zeros(1,totaltrials);    % onset of first-level stim, ms
stim2_ons_sl = zeros(1,totaltrials);    % onset of second-level stim, slices
stim2_ons_ms = zeros(1,totaltrials);    % onset of second-level stim, ms
choice1_ons_sl = zeros(1,totaltrials);  % onset of first-level choice, slices
choice1_ons_ms = zeros(1,totaltrials);  % onset of first-level choice, ms
choice2_ons_sl = zeros(1,totaltrials);  % onset of second-level choice, slices
choice2_ons_ms = zeros(1,totaltrials);  % onset of second-level choice, ms
rew_ons_sl = zeros(1,totaltrials);      % onset of outcome, slices
rew_ons_ms = zeros(1,totaltrials);      % onset of outcome, ms

% initial wait

if (inmri)
	nslices=36;                  %number of slices
	slicewait=5*nslices+1;       %sets initial slicewait to accomodate 5 dummy volumes
else
	slicewait = ceil(0 / 90); %set initial slicewait to now - but time is
    %since cogent was called, which was a few lines ago...?
end

w=Screen('OpenWindow',0,[0 0 0]);
Screen('TextFont', w,'times');
Screen('TextStyle',w,1);

% convert image arrays to textures
for i = 1:3
    for j = 1:2
        s(i,j).norm = Screen(w,'MakeTexture',t(i,j).norm);
        s(i,j).deact = Screen(w,'MakeTexture',t(i,j).deact);
        s(i,j).act1 = Screen(w,'MakeTexture',t(i,j).act1);
        s(i,j).act2 = Screen(w,'MakeTexture',t(i,j).act2);
        s(i,j).spoiled = Screen(w,'MakeTexture',t(i,j).spoiled);
    end
end

moneypic = Screen(w,'MakeTexture',moneypic);
losepic = Screen(w,'MakeTexture',losepic);

% make logfile to be filled in in real time

logfile = fopen([name '_' date], 'a');
fprintf(logfile,'\ntrial choice1   rts1   stim1ons_sl   stim1ons_ms   choice1ons_sl   choice1ons_ms   state   choice2   rts2   stim2ons_sl   stim2ons_ms   choice2ons_sl   choice2ons_ms   won\n');

% main experimental loop
for trial = 1:totaltrials

Screen('Flip',w);
   
    if find(trial == b) > 0
        WaitSecs(1)
        Screen('TextSize', w, 20); %% font size
        DrawFormattedText(w, ['Take a break!' '\n\n' 'Press any key to continue when you are ready.'],'center','center');
        Screen('Flip',w);
        KbWait([],2);
        Screen('Flip',w);
        WaitSecs((ititime*90)/1000)
    end
    
  % first level

    [choice1(trial),rts1(trial),stim1_ons_sl(trial),stim1_ons_ms(trial),choice1_ons_sl(trial),choice1_ons_ms(trial)] = ...
  	halftrial(s(1,:), pos1(trial),w,slicewait);
   
  % record first choice in log
  
   fprintf(logfile,'\n%d %d %f %f %f %f %f',trial,choice1(trial),rts1(trial),...
      stim1_ons_sl(trial),stim1_ons_ms(trial),choice1_ons_sl(trial),choice1_ons_ms(trial))
  
  if ~choice1(trial) % spoiled
  	 %we pick up a half-trial of extra time here; not sure what to do about this
    slicewait = slicewait + choicetime + isitime + moneytime + ititime + jitter(trial);
    
    continue;
  end

  
   %determine where we transition
  
  state(trial) = 2 + xor((rand > transprob),(choice1(trial)-1));

  % second level

  [choice2(trial), rts2(trial),stim2_ons_sl(trial),stim2_ons_ms(trial),choice2_ons_sl(trial),choice2_ons_ms(trial),chpos,stimleft,stimright] = ...
  	halftrial(s(state(trial),:), pos2(trial),w);
   
  % record second choice in log
  fprintf(logfile,'\t%d %d %f %f %f %f %f',state(trial),choice2(trial),rts2(trial),...
      stim2_ons_sl(trial),stim2_ons_ms(trial),choice2_ons_sl(trial),choice2_ons_ms(trial))
  
  if ~choice2(trial) % spoiled
      slicewait = slicewait + 2*choicetime + 2*isitime + moneytime + ititime + jitter(trial);
    continue;
  end
  
  % outcome
  money(trial) = rand < payoff(state(trial)-1,choice2(trial),trial);

  [rew_ons_sl(trial),rew_ons_ms(trial)] = drawoutcome(money(trial),w,chpos,stimleft,stimright);
  
  slicewait = slicewait + 2*choicetime + 2*isitime + moneytime + ititime + jitter(trial);
  
  fprintf(logfile,'\t%d',money(trial))
end

% figure out what they won

rewardedtrials = randperm(totaltrials);
rewardedtrials = rewardedtrials(1:numrewardedtrials);
totalwon = sum(money(rewardedtrials));

% save data

eval(['save ' ['_',num2str(number), name '_' num2str(now*1000,9)] '_onsets choice1 choice2 state pos1 pos2 money totalwon rts1 rts2 stim1_ons_sl stim1_ons_ms choice1_ons_sl choice1_ons_ms stim2_ons_sl stim2_ons_ms choice2_ons_sl choice2_ons_ms rew_ons_sl rew_ons_ms name payoff'])

Screen('Close',w)