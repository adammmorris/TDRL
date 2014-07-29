% tutorial for sequential choice task
% ND
clear all

ptbpath = '/dawlab/cache/ptb/Psychtoolbox';

addpath([ptbpath '/PsychBasic']);
addpath([ptbpath '/PsychOneliners']);
addpath([ptbpath '/PsychPriority']);
addpath([ptbpath '/PsychJava']);
addpath([ptbpath '/PsychAlphaBlending'])
addpath([ptbpath '/PsychRects'])

%name=input('Subjects name ? ','s');

% % configure cogent a=settings
% %config_display(1,1,[0.1 0.1 0.1],[1 1 1], 'Arial', 20, 3)
% config_display(1,1,[0.2 0.2 0.2],[1 1 1], 'Arial', 20, 3)
% config_log
% %config_keyboard(100,5,'exclusive' )
% config_keyboard(100,5,'exclusive' )
% cgloadlib

%set random number generator
rand('state',sum(100*clock));
% start_cogent;

%textxpos = 0;
%textypos = [-30, -50, -70, -90, -110, -130, -150, -170];

% specify the task parameters
global leftpos rightpos boxypos moneyypos animxpos animypos moneytime ...
    isitime ititime choicetime moneypic losepic inmri keyleft keyright;

w = Screen('OpenWindow',0,[128 128 128],[0 0 640 480]);

totaltrials=50;    %total number of trials in the task
transprob = .7;    % probability of 'correct' transition

[xres,yres] = Screen('windowsize',w);
xcenter = xres/2;
ycenter = yres/2;

leftpos = xcenter-125-100;
rightpos = xcenter+125-100;
boxypos = ycenter-50-50;

leftposvect = [leftpos boxypos leftpos+200 boxypos+100];
rightposvect = [rightpos boxypos rightpos+200 boxypos+100];

moneyypos = ycenter-round(75/2);
moneyxpos = xcenter-round(75/2);

animxpos = 0:25:125;
animypos = 0:25:125;

moneytime = round(1500 / 90);
isitime = round(1500 / 90);
ititime = round(2000 / 90);
choicetime = round(2000 / 90);

inmri = 0;

keyleft = KbName('u');
keyright = KbName('i');

ytext = round(3*yres/5);

% load payoffs

load tut/masterprob

% Load the figures

t(1,1).norm=imread('tut/stim1.png');
t(1,1).deact=imread('tut/stim1-d.png');
t(1,1).act1=imread('tut/stim1-a1.png');
t(1,1).act2=imread('tut/stim1-a2.png');
t(1,1).spoiled=imread('tut/stim1-s.png');

t(1,2).norm=imread('tut/stim2.png');
t(1,2).deact=imread('tut/stim2-d.png');
t(1,2).act1=imread('tut/stim2-a1.png');
t(1,2).act2=imread('tut/stim2-a2.png');
t(1,2).spoiled=imread('tut/stim2-s.png');

t(2,1).norm=imread('tut/stim3.png');
t(2,1).deact=imread('tut/stim3-d.png');
t(2,1).act1=imread('tut/stim3-a1.png');
t(2,1).act2=imread('tut/stim3-a2.png');
t(2,1).spoiled=imread('tut/stim3-s.png');

t(2,2).norm=imread('tut/stim4.png');
t(2,2).deact=imread('tut/stim4-d.png');
t(2,2).act1=imread('tut/stim4-a1.png');
t(2,2).act2=imread('tut/stim4-a2.png');
t(2,2).spoiled=imread('tut/stim4-s.png');

t(3,1).norm=imread('tut/stim5.png');
t(3,1).deact=imread('tut/stim5-d.png');
t(3,1).act1=imread('tut/stim5-a1.png');
t(3,1).act2=imread('tut/stim5-a2.png');
t(3,1).spoiled=imread('tut/stim5-s.png');

t(3,2).norm=imread('tut/stim6.png');
t(3,2).deact=imread('tut/stim6-d.png');
t(3,2).act1=imread('tut/stim6-a1.png');
t(3,2).act2=imread('tut/stim6-a2.png');
t(3,2).spoiled=imread('tut/stim6-s.png');

t(4,1).norm=imread('tut/stim7.png');
t(4,1).deact=imread('tut/stim7-d.png');
t(4,1).act1=imread('tut/stim7-a1.png');
t(4,1).act2=imread('tut/stim7-a2.png');
t(4,1).spoiled=imread('tut/stim7-s.png');

t(4,2).norm=imread('tut/stim8.png');
t(4,2).deact=imread('tut/stim8-d.png');
t(4,2).act1=imread('tut/stim8-a1.png');
t(4,2).act2=imread('tut/stim8-a2.png');
t(4,2).spoiled=imread('tut/stim8-s.png');

t(5,1).norm=imread('tut/stim9.png');
t(5,1).deact=imread('tut/stim9-d.png');
t(5,1).act1=imread('tut/stim9-a1.png');
t(5,1).act2=imread('tut/stim9-a2.png');
t(5,1).spoiled=imread('tut/stim9-s.png');

moneypic = imread('behav/money.png');
losepic = imread('behav/nothing.png');

change1 = imread('tut/change1.png');
change2 = imread('tut/change2.png');
change3 = imread('tut/change3.png');
change4 = imread('tut/change4.png');
change35 = imread('tut/change35.png');
change50 = imread('tut/change50.png');
change50b = imread('tut/change50b.png');
change50c = imread('tut/change50c.png');


for i = 1:5
     for j = 1:2 - (i==5)
         s(i,j).norm = Screen(w,'MakeTexture',t(i,j).norm);
         s(i,j).deact = Screen(w,'MakeTexture',t(i,j).deact);
         s(i,j).act1 = Screen(w,'MakeTexture',t(i,j).act1);
         s(i,j).act2 = Screen(w,'MakeTexture',t(i,j).act2);
         s(i,j).spoiled = Screen(w,'MakeTexture',t(i,j).spoiled);
     end
end
 
moneypic = Screen(w,'MakeTexture',moneypic);
losepic = Screen(w,'MakeTexture',losepic);

change1 = Screen(w,'MakeTexture',change1);
change2 = Screen(w,'MakeTexture',change2);
change3 = Screen(w,'MakeTexture',change3);
change4 = Screen(w,'MakeTexture',change4);
change35 = Screen(w,'MakeTexture',change35);
change50 = Screen(w,'MakeTexture',change50);
change50b = Screen(w,'MakeTexture',change50b);
change50c = Screen(w,'MakeTexture',change50c);

% initialise data vectors
choice1 = zeros(1,totaltrials);         % first level choice
choice2 = zeros(1,totaltrials);         % second level choice
state = zeros(1,totaltrials);           % second level state
pos1 = rand(1,totaltrials) > .5;        % positioning of first level boxes
pos2 = rand(1,totaltrials) > .5;        % positioning of second level boxes
rts1 = zeros(1,totaltrials);            % first level RT
rts2 = zeros(1,totaltrials);            % second level RT
money = zeros(1,totaltrials);           % win

Screen('TextFont',w,'Helvetica');
Screen('TextSize',w,20);
Screen('TextStyle',w,1);

% screen 1
DrawFormattedText(w,'Press any key to start the tutorial, and to continue from page to page.',...
    'center','center',[255 255 255]);
Screen('Flip',w);
KbWait([],2);

% screen 2
DrawFormattedText(w,'Your goal in this experiment is to win as much money as possible.','center','center');
Screen('Flip',w);
KbWait([],2);

% screen 3
Screen('DrawTexture',w,s(4,1).norm,[],leftposvect);
Screen('DrawTexture',w,s(4,2).norm,[],rightposvect);
DrawFormattedText(w,'In the game, you will see pairs of boxes.  They are identified by a symbol and a color.  Your job is to choose one of them.','center',...
    round(ytext),[],70);
Screen('Flip',w);
KbWait([],2);

% screen 4
Screen('DrawTexture',w,s(4,1).norm,[],leftposvect);
Screen('DrawTexture',w,s(4,2).norm,[],rightposvect);
DrawFormattedText(w,'Each of the first type of box we will consider has a certain chance of containing one pound.  The aim is to find a box with a high chance of money, and choose it.'...
    ,'center',ytext,[],70);
Screen('Flip',w,[]);
KbWait([],2);
Screen('DrawTexture',w,s(4,1).norm,[],leftposvect);
Screen('DrawTexture',w,s(4,2).norm,[],rightposvect);
DrawFormattedText(w,'In this demonstration you wont be playing for real money. In the actual experiment, you will be.',...
    'center',ytext,[],70);
Screen('Flip',w);
KbWait([],2);

% % screen 5
% preparepict(s(4,1).norm,1,leftpos,boxypos);
% preparepict(s(4,2).norm,1,rightpos,boxypos);
% DrawFormattedText(w,'','center',ytext,[],70)'For this demonstration, you will select the box you want using the keyboard.',1,textxpos,textypos(1));
% DrawFormattedText(w,'','center',ytext,[],70)'You select the left box by pressing U, and the right box by pressing I.',1,textxpos,textypos(2));
% DrawFormattedText(w,'','center',ytext,[],70)'When you are in the scanner, you will have a keypad instead.',1,textxpos,textypos(3));
% Screen('Flip',w);
% KbWait([],2);
% Screen('Flip',w);
% 
% % screen 6
% preparepict(s(4,1).norm,1,leftpos,boxypos);
% preparepict(s(4,2).norm,1,rightpos,boxypos);
% DrawFormattedText(w,'','center',ytext,[],70)'Practice selecting them now, using the U and I keys.',1,textxpos,textypos(1));
% DrawFormattedText(w,'','center',ytext,[],70)'When you select a box, it will highlight.',1,textxpos,textypos(2));       
% DrawFormattedText(w,'','center',ytext,[],70)'(the tutorial will continue after 4 presses.)',1,textxpos,textypos(3));
% Screen('Flip',w);
% 
% 
% for t =1:4
%    pos = selectbox(inf);
%   if pos==1 
%     preparepict(s(4,1).act1,2,leftpos,boxypos);
%     preparepict(s(4,2).deact,2,rightpos,boxypos);
%     preparepict(s(4,1).act2,3,leftpos,boxypos);
%     preparepict(s(4,2).deact,3,rightpos,boxypos);
%   elseif pos==2  %right box selected [key=i]
%     preparepict(s(4,1).deact,2,leftpos,boxypos);
%     preparepict(s(4,2).act1,2,rightpos,boxypos);
%     preparepict(s(4,1).deact,3,leftpos,boxypos);
%     preparepict(s(4,2).act2,3,rightpos,boxypos);
%   end
%   for i = 1:5
%       drawpict(2);
%        wait(100);
%        drawpict(3);
%       wait(100);
%   end
%  
%   Screen('Flip',w);
%   preparepict(s(4,1).norm,1,leftpos,boxypos);
%   preparepict(s(4,2).norm,1,rightpos,boxypos);
%   DrawFormattedText(w,'','center',ytext,[],70)'When you select a box, it will highlight.',1,textxpos,textypos(2));       
%   DrawFormattedText(w,'','center',ytext,[],70)'Try another box.',1,textxpos,textypos(3));       
%   Screen('Flip',w);
% end  
% 
% Screen('Flip',w);
% DrawFormattedText(w,'','center',ytext,[],70)'Press any key to continue.',1,textxpos,textypos(4));       
% Screen('Flip',w);
% KbWait([],2);
% Screen('Flip',w);
% 
% % screen 8
% DrawFormattedText(w,'','center',ytext,[],70)'After a box is selected, you will find out the result',1,textxpos,textypos(1));
% Screen('Flip',w);
% KbWait([],2);
% Screen('Flip',w);
% 
% % screen 9
% preparepict(s(5,1).norm,1,0,boxypos2);
% preparestring('It is important to understand how the computer decides whether you win money',1,textxpos,textypos(1));
% preparestring('To illustrate this, consider just one of the boxes.',1,textxpos,textypos(2));
% Screen('Flip',w);
% KbWait([],2);
% Screen('Flip',w);
% 
% % screen 10
% preparepict(s(5,1).norm,1,0,boxypos2);
% preparestring('Each time you select a box the computer flips a weighted coin to decide if you win.',1,textxpos,textypos(1));
% Screen('Flip',w);
% KbWait([],2);
% preparestring('For this box, you have a 60% chance of winning.',1,textxpos,textypos(3));
% preparestring('Other boxes may be more or less',1,textxpos,textypos(4));
% preparestring('and you normally have to figure it out for yourself.',1,textxpos,textypos(5));
% Screen('Flip',w);
% KbWait([],2);
% Screen('Flip',w);
% 
% % screen 11
% preparepict(s(5,1).norm,1,0,boxypos2);
% preparestring('To get a feel for this, have a practice:',1,textxpos,textypos(1));
% preparestring('Every time you select the box is like playing a game of chance,',1,textxpos,textypos(2));
% preparestring('with the odds 60% of winning money',1,textxpos,textypos(3));
% preparestring('Press the U key to select the box and try this out:',1,textxpos,textypos(4));
% preparestring('(You will get 10 tries)',1,textxpos,textypos(5));
% 
% Screen('Flip',w);
% 
% clearpict(2);
% preparepict(s(5,1).act1,2,0,boxypos2);
% clearpict(3);
% preparepict(s(5,1).act2,3,0,boxypos2);
% 
% a=[1 0 1 1 1 0 1 0 1 1]
%   
%   j=1
%   while (j <= length(a))
%     preparepict(s(5,1).norm,1,0,boxypos2);
%     Screen('Flip',w);
%     pos = selectbox(inf);
% 
%     for i = 1:5
%       drawpict(2);
%       wait(100);
%       drawpict(3);
%       wait(100);
%     end
% 
%     Screen('Flip',w);
%     preparepict(s(5,1).deact,1,0,boxypos2);
%     
%     drawoutcome(a(j));
%     
%     Screen('Flip',w);
%     Screen('Flip',w);
%     wait(1000)
%     j = j + 1;
%   end
% 
%  preparestring('total number of wins = 7',1,textxpos,textypos(1));
%  preparestring('press any key to continue',1,textxpos,textypos(2));
%  Screen('Flip',w)
%  KbWait([],2);
%  Screen('Flip',w);
%  Screen('Flip',w);
% 
% 
% % screen 12
% preparepict(s(5,1).norm,1,0,boxypos2);
% preparestring('As you see, on roughly 6/10 of trials you win money.',1,textxpos,textypos(1));
% preparestring('Beyond this there are no patterns.',1,textxpos,textypos(2));
% preparestring('For instance, wins and losses do not alternate',1,textxpos,textypos(3));
% Screen('Flip',w);
% KbWait([],2);
% Screen('Flip',w);
% 
% % screen 13
% preparestring('Of course, not all boxes will be equally good.',1,textxpos,textypos(1));
% preparestring('Other boxes may give you money less (or more) often.',1,textxpos,textypos(2));
% preparestring('In the next example, one box will be better than the other.',1,textxpos,textypos(3));
% Screen('Flip',w);
% KbWait([],2);
% Screen('Flip',w);
% 
% % screen 14
% preparepict(s(4,1).norm,1,leftpos,boxypos);
% preparepict(s(4,2).norm,1,rightpos,boxypos);
% preparestring('Try selecting both boxes, and see if you can work out',1,textxpos,textypos(1));
% preparestring('which one is better',1,textxpos,textypos(2));
% Screen('Flip',w);
% KbWait([],2);
% Screen('Flip',w);
% 
% % screen 15
% preparepict(s(4,1).norm,1,leftpos,boxypos);
% preparepict(s(4,2).norm,1,rightpos,boxypos);
% preparestring('A box is identified by its symbol and its color.',1,textxpos,textypos(1));
% preparestring('Sometimes it will come up on the right',1,textxpos,textypos(2));
% Screen('Flip',w);
% KbWait([],2);
% preparepict(s(4,2).norm,1,leftpos,boxypos);
% preparepict(s(4,1).norm,1,rightpos,boxypos);
% preparestring('and sometimes it will come up on the left.',1,textxpos,textypos(3));
% Screen('Flip',w);
% KbWait([],2);
% preparepict(s(4,1).norm,1,leftpos,boxypos);
% preparepict(s(4,2).norm,1,rightpos,boxypos);
% preparestring('Which side a box appears on does not influence your chance of winning.',1,textxpos,textypos(5));
% preparestring('For instance, left is not luckier than right.',1,textxpos,textypos(6));
% Screen('Flip',w);
% KbWait([],2);
% Screen('Flip',w);
% 
% % screen 15
% preparepict(s(4,1).norm,1,leftpos,boxypos);
% preparepict(s(4,2).norm,1,rightpos,boxypos);
% preparestring('Now try to find the better box.',1,textxpos,textypos(1));
% preparestring('You have 20 trials in this game.',1,textxpos,textypos(2));
% preparestring('Remember, key U is for the left box, and key I is for the right one.',1,textxpos,textypos(3));
% Screen('Flip',w);
% KbWait([],2);
% 
% Screen('Flip',w);
% t=1;
% 
% choicetime = inf;
% 
% for t = 1:20
%   % set up pictures, swapping sides randomly
%   
%   choice = halftrial(s(4,:),rand > .5);
%   
%   if choice == 1
%     win = rand < .75
%   else
%     win = rand < .25
%   end
%   
%   drawoutcome(win);
% 
%   Screen('Flip',w);
%   Screen('Flip',w);
%   wait(1000)
% end
% Screen('Flip',w);
% Screen('Flip',w);
% 
% % screen 14
% preparestring('Press any key to continue.',1,textxpos,textypos(1));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 14
% preparepict(s(4,1).norm,1,0,boxypos);
% preparestring('This was the better box.',1,textxpos,textypos(1));
% preparestring('If you were playing for real, then you would want to choose it.',1,textxpos,textypos(2));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 15
% preparestring('The actual game is harder for two reasons.',1,textxpos,textypos(1));
% preparestring('First, there are more boxes to keep track of.',1,textxpos,textypos(2));
% preparestring('More about this in a moment.',1,textxpos,textypos(3));
% Screen('Flip',w);
% KbWait([],2)
% preparestring('But also, the chance a box contains money can change slowly over time.',1,textxpos,textypos(5));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 16
% preparestring('Because the boxes can slowly change, a box that starts out better',1,textxpos,textypos(1));
% preparestring('can turn worse later, or a worse one can turn better.',1,textxpos,textypos(2));
% preparestring('So finding the box that is best right now requires continual concentration.',1,textxpos,textypos(3));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 17
% preparestring('Boxes can also stay more or less the same',1,textxpos,textypos(1));
% preparestring('or change back and forth, or many other patterns.',1,textxpos,textypos(2));
% Screen('Flip',w);
% KbWait([],2)
% preparestring('In fact, the change is completely unpredictable. But it is also slow.',1,textxpos,textypos(4));
% preparestring('So a box that is good now will probably be pretty good for a while.',1,textxpos,textypos(5));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 17
% preparepict(s(5,1).norm,1,-200,150);
% preparepict(change1,1,100,50);
% preparestring('To illustrate this, again consider just one box',1,textxpos,-150);
% preparestring('Here is an example of how the chance of',1,textxpos,-170);
% preparestring('wins might start off. Initially, there is a 60% chance of a win.',1,textxpos,-190);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 17
% preparepict(s(5,1).norm,1,-200,150);
% preparepict(change2,1,100,50);
% preparestring('On the next few trials it is similar...',1,textxpos,-150);
% Screen('Flip',w);
% KbWait([],2)
% preparepict(change3,1,100,50);
% Screen('Flip',w);
% KbWait([],2)
% preparepict(change4,1,100,50);
% preparestring('But see how it looks 30 trials later...',1,textxpos,-170);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 18
% preparepict(s(5,1).norm,1,-200,150);
% preparepict(change35,1,100,50);
% preparestring('Now there is little chance of winning money',1,textxpos,-190);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 18
% preparepict(s(5,1).norm,1,-200,150);
% preparepict(change50,1,100,50);
% preparestring('Later still it might get a bit better again',1,textxpos,-190);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 18
% preparepict(s(5,1).norm,1,-200,150);
% preparepict(change50b,1,100,50);
% preparestring('Now imagine what would happen if you selected this box repeatedly. ',1,textxpos,-150);
% preparestring('The stars above the line show when you might win money.',1,textxpos,-170);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 21
% preparepict(s(5,1).norm,1,-200,150);
% preparepict(change50b,1,100,50);
% preparestring('Early on, you often get wins, but later you get fewer',1,textxpos,-150);
% preparestring('and, still later, somewhat more.',1,textxpos,-170);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 20
% preparepict(s(5,1).norm,1,-200,150);
% preparepict(s(4,1).norm,1,-200,25);
% preparepict(change50c,1,100,50);
% preparestring('The red line shows another hypothetical box.',1,textxpos,-150);
% preparestring('It starts off worse, at 45%, but doesnt change much.',1,textxpos,-170);
% preparestring('So in the game you would do well if you started choosing the first box',1,textxpos,-190);
% preparestring('but switched to the other one later on. Of course you have to figure out which is best',1,textxpos,-210);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 20
% preparepict(s(5,1).norm,1,-200,150);
% preparepict(s(4,1).norm,1,-200,25);
% preparepict(change50c,1,100,50);
% preparestring('Remember, these are just examples.',1,textxpos,-150);
% preparestring('In the game, boxes will also get better',1,textxpos,-170);
% preparestring('and show other forms of unpredictable change',1,textxpos,-190);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 15
% preparepict(s(2,1).norm,1,leftpos,boxypos);
% preparepict(s(2,2).norm,1,rightpos,boxypos);
% preparepict(s(3,1).norm,1,leftpos,boxypos2);
% preparepict(s(3,2).norm,1,rightpos,boxypos2);
% preparestring('You are almost ready to try out the full game',1,textxpos,textypos(1));
% preparestring('But there is one more complication: more boxes.',1,textxpos,textypos(2));
% Screen('Flip',w);
% KbWait([],2)
% preparepict(s(2,1).norm,1,leftpos,boxypos);
% preparepict(s(2,2).norm,1,rightpos,boxypos);
% preparepict(s(3,1).norm,1,leftpos,boxypos2);
% preparepict(s(3,2).norm,1,rightpos,boxypos2);
% preparestring('In particular, there are two pairs of boxes containing money.',1,textxpos,textypos(4));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 16
% preparepict(s(1,1).norm,1,leftpos,boxypos);
% preparepict(s(1,2).norm,1,rightpos,boxypos);
% preparestring('There is also a third pair of boxes.',1,textxpos,textypos(1));
% preparestring('In the game, you start each trial by choosing between these two.',1,textxpos,textypos(2));
% preparestring('Rather than having some chance of giving you money',1,textxpos,textypos(3));
% preparestring('these have a chance of giving you either of the two pairs of money boxes',1,textxpos,textypos(4));
% Screen('Flip',w);
% KbWait([],2)
% preparestring('... which you then choose between to win money as before.',1,textxpos,textypos(6));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 16
% preparestring('Try it now: Select a box with U or I',1,textxpos,textypos(3));
% halftrial(s(1,:), 0);
% preparestring('These are boxes with a chance of containing money. Try selecting one.',1,textxpos,textypos(3));
% halftrial(s(2,:), 0);
% drawoutcome(1);
% preparestring('You found a pound.',1,textxpos,textypos(3));
% preparestring('Press any key to continue.',1,textxpos,textypos(4));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 16
% preparepict(s(1,1).act1,1,leftpos,boxypos);
% preparepict(s(1,2).deact,1,rightpos,boxypos);
% preparestring('Just like the money boxes, these boxes are a bit unpredictable.',1,textxpos,textypos(1));
% preparestring('For instance, this one might give you the purple boxes about 7 times out of 10',1,textxpos,textypos(2)); % changed from probs 10/8 sub 5
% preparestring('and give you the turquoise boxes about 3 times out of 10.',1,textxpos,textypos(3));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 16
% preparepict(s(1,1).deact,1,leftpos,boxypos);
% preparepict(s(1,2).act1,1,rightpos,boxypos);
% preparestring('Whereas this one might give you the purple boxes about 3 times out of 10',1,textxpos,textypos(1));
% preparestring('and give you the turquoise boxes about 7 times out of 10.',1,textxpos,textypos(2));
% Screen('Flip',w);
% KbWait([],2)
% preparestring('If these were the chances and if the box with the most money were a turquoise one',1,textxpos,textypos(4));
% preparestring('then this box would be a better choice.',1,textxpos,textypos(5));
% Screen('Flip',w);
% KbWait([],2)
% preparestring('Again, what matters is the box color and symbol, not what side it appears on.',1,textxpos,textypos(7));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 16
% preparepict(s(1,1).norm,1,leftpos,boxypos);
% preparepict(s(1,2).norm,1,rightpos,boxypos);
% preparestring('Unlike the chances of finding money in the other boxes',1,textxpos,textypos(1));
% preparestring('the chances of these boxes leading to different colored',1,textxpos,textypos(2));
% preparestring('money boxes do not change over time.',1,textxpos,textypos(3));
% preparestring('Of course, you will still have to figure out what they are.',1,textxpos,textypos(5));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 17
% preparepict(s(1,1).norm,1,leftpos,boxypos);
% preparepict(s(1,2).norm,1,rightpos,boxypos);
% preparestring('Note that when you choose a purple or turquoise box, your chance of winning money',1,textxpos,textypos(1));  %added 10/8 sub 5
% preparestring('depends only on its color and symbol, not which orange box you chose to get it.',1,textxpos,textypos(2));    %added 10/8 sub 5
% preparestring('The choice you make between the orange boxes is still important because',1,textxpos,textypos(3));
% preparestring('it can help you get whichever pair of money boxes contains more money.',1,textxpos,textypos(4));
% preparestring('Of course, which boxes those are may change.',1,textxpos,textypos(5));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 16
% preparepict(s(2,1).norm,1,leftpos,boxypos);
% preparepict(s(2,2).norm,1,rightpos,boxypos);
% preparepict(s(3,1).norm,1,leftpos,boxypos2);
% preparepict(s(3,2).norm,1,rightpos,boxypos2);
% preparestring('This may all sound complicated, so lets review:',1,textxpos,textypos(1));
% preparestring('These boxes are two games of figuring out which one has a better chance of money.',1,textxpos,textypos(2));
% preparestring('This is just like what you played before except that the chance of money is changing.',1,textxpos,textypos(3));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% preparepict(s(1,1).norm,1,leftpos,boxypos);
% preparepict(s(1,2).norm,1,rightpos,boxypos);
% preparestring('On top of that game is another one of figuring out which box is better.',1,textxpos,textypos(1));
% preparestring('This is also like what you played before, except with these boxes',1,textxpos,textypos(2));
% preparestring('you dont win money directly: you win the chance to win money in the other game.',1,textxpos,textypos(3));
% preparestring('A better box will take you to a game with a better chance of winning money.',1,textxpos,textypos(4));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % screen 22
% preparestring('Lets put it all together into an example game. In this practice,',1,textxpos,textypos(1));
% preparestring('you wont be winning real money.',1,textxpos,textypos(2));
% preparestring('You will do the task for 50 trials, which is about 10 minutes.',1,textxpos,textypos(3));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% % another screen
% preparepict(s(1,1).norm,1,leftpos,boxypos);
% preparepict(s(1,2).norm,1,rightpos,boxypos);
% preparestring('If you take too long making a choice, the trial will abort.',1,textxpos,textypos(1));
% Screen('Flip',w);
% KbWait([],2)
% preparepict(s(1,1).spoiled,1,leftpos,boxypos);
% preparepict(s(1,2).spoiled,1,rightpos,boxypos);
% preparestring('In this case, you will see red Xs on the screen and a new trial will start.',1,textxpos,textypos(2));
% preparestring('Dont feel rushed, but please try to enter a choice on every trial.',1,textxpos,textypos(3));
% Screen('Flip',w);
% KbWait([],2)
% preparestring('Good luck! Remember that U selects left and I selects right.',1,textxpos,textypos(5));
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w);
% 
% choicetime = round(2000/90);
% animypos = 20:20:150;
% boxypos = 0;
% 
% % main experimental loop
% 
% for trial = 1:totaltrials
% 
%   % first level
% 
%   [choice1(trial), rts1(trial)] = halftrial(s(1,:), pos1(trial));
%   
%   if ~choice1(trial) % spoiled
%     Screen('Flip',w);
%     Screen('Flip',w);
%     wait(ititime * 90)  
%     continue;
%   end
%   
%   % determine where we transition
%   
%   state(trial) = 2 + xor((rand > transprob),(choice1(trial)-1));
% 
%   % second level
% 
%   [choice2(trial), rts2(trial)] = halftrial(s(state(trial),:), pos2(trial));
% 
%   if ~choice2(trial) % spoiled
%       Screen('Flip',w);
%       Screen('Flip',w);
%       wait(ititime * 90)
%       continue;
%   end
%   
%   % outcome
%   money(trial) = rand < payoff(state(trial)-1,choice2(trial),trial);
% 
%   drawoutcome(money(trial));
%   
%   Screen('Flip',w);
%   Screen('Flip',w);
%   wait(ititime * 90);
% end
% 
% preparestring('That is the end of the practice game',1,0,20);
% preparestring('Press a key to see how you did....',1,0,-20);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w)
% 
% preparestring(['You got '  num2str(sum(money)) ' wins.'] ,1,-20,-10);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w)
% 
% preparestring('Okay, that is nearly the end of the tutorial',1,0,20);
% preparestring('Here are a few helpful hints on how to play the game.',1,0,0);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w)
% 
% preparestring('Hints:',1,0,160);
% preparestring('The game is hard, so you will need to concentrate.',1,0,140);
% preparestring('But dont be afraid to trust your instincts.',1,0,120);
% preparestring('Remember from which boxes you got money.',1,0,90);
% preparestring('Because the boxes only change gradually they will',1,0,70);
% preparestring('probably stay similar in the short term,',1,0,50);
% preparestring('but probably change in the long term.',1,0,30);
% preparestring('This is how the game involves skill as well as luck:',1,0,0);
% preparestring('finding which boxes are currently best',1,0,-20);
% preparestring('and following when they change.',1,0,-40);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w)
% 
% preparestring('Hints:',1,0,160);
% preparestring('The first choice in the trial is also important',1,0,140);
% preparestring('This is because it influences which color of money boxes you get',1,0,120);
% preparestring('and often one color will be better than the other.',1,0,100);
% preparestring('So you can earn more money by figuring out which initial choices work better.',1,0,70);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w)
% 
% preparestring('Hints:',1,0,160);
% preparestring('Remember, none of the boxes know what the others are doing.',1,0,140);
% preparestring('Just because one box is poor does not mean any others have to be rich.',1,0,120);
% preparestring('Also, the way they change is not synchronized or patterned.',1,0,100);
% preparestring('You dont have to bother looking for patterns such as:',1,0,70);
% preparestring('* win-lose-win-lose',1,0,50);
% preparestring('* wins on turquoise following wins on purple',1,0,30);
% preparestring('* the best box moving predictably from one color to the next',1,0,10);
% preparestring('The computer is not trying to catch you out or trick you.',1,0,-30);
% preparestring('Remember, it is a game of both skill and chance, so good luck!',1,0,-60);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w)
% 
% preparestring('Finally:',1,0,160);
% preparestring('The way we will determine the amount of money you win',1,0,140);
% preparestring('is by keeping track of whether you win a pound on each trial.',1,0,120);
% preparestring('At the end the computer will randomly pick one-third of the trials',1,0,100);
% preparestring('and we will pay you the total money you won on all of those trials.',1,0,80);
% preparestring('For instance, you might get paid what you earn on trials 1,2,5,7, etc.',1,0,50);
% preparestring('So you should play every trial as though there is one pound at stake',1,0,30);
% preparestring('because you dont know whether that trial will be one of the ones',1,0,10);
% preparestring('you will be paid for! ',1,0,-20);
% Screen('Flip',w);
% KbWait([],2)
% Screen('Flip',w)
% 
% stop_cogent
% 
% eval(['save ' [name '_' num2str(now*1000,9)] '_tutorial choice1 choice2 state pos1 pos2 money rts1 rts2'])
