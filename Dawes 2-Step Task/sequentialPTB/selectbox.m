function [pos,buttontime] = selectbox(unt)

global keyleft keyright

if nargin == 0
  unt = Inf;
end

buttontime=0;

%clearkeys;
choices = [keyleft keyright];

pos=0; %the variable 'pos' specifies which slot has been selected
    
%loop until one of the choice buttons is pressed, then break out of
%the loop
%while slicewrapper < unt;
  %readkeys;
  %logkeys;
  %[keyout,buttontime,npress] = getkeydown;
  %if isempty(keyout)   % ie. if no button is pressed, then do nothing and continue looping
    %do nothing   
  %elseif keyout==keyleft %left box selected
  %  pos=1;
  %  break
  %elseif keyout==keyright %right box selected
  %  pos=2;
  %  break
  %end

while KbCheck && (slicewrapper < unt);
end
  
while pos == 0 && (slicewrapper < unt)
	%WaitSecs(0.005);
	[key buttontime keycode] = KbCheck;
if (key & find(choices == find(keycode)))
		pos = find(choices==find(keycode));
end
end

end
