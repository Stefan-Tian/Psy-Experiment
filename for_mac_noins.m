Screen('Preference', 'SkipSyncTests', 1);
FontInfo('Arial');
% improve portability acorss operating systems 
KbName('UnifyKeyNames');
% specify key names of interest in the study
activeKeys = [KbName('1!') KbName('2@') KbName('3#') KbName('4$') KbName('5%') KbName('6^') KbName('7&')];
% set value for maximum time to wait for response (in seconds)
t2wait = 3;
% restrict the keys for keyboard input to the keys we want
RestrictKeysForKbCheck(activeKeys);
% suppress echo to the command line for keypresses
ListenChar(2);

% a random array deciding which gender to start
order = randperm(2);


% two array of random sequences 
male_seq = randperm(40);
female_seq = randperm(40);

% loop through random sequence of photos
[w, rect] = Screen('OpenWindow', 0, [256, 256, 256], [0 0 1200 800]);

rt_1 = []; keynames_1 = [];
rt_2 = []; keynames_2 = [];

image = zeros(rect(4),rect(3));
t1= Screen('MakeTexture',w, image);
Screen('TextSize',t1,30);
Screen('TextFont',t1,'Fonts'); 
DrawFormattedText(t1,double('接下來將出現一系列男生/女生的照片，\n請您依據照片人像的外貌好感度及其可能的社經地位去做1-7的評分。\n7表示好感度最高及社經地位最高；\n1表示好感度最低及社經地位最低。\n每張照片將會呈現3秒，之後每題有兩秒的作答時間。\n作答時請按鍵盤上方的1-7數字。\n請用滑鼠點擊螢幕繼續'),'center','center',256); 
Screen('DrawTexture',w, t1);
Screen('Flip',w);
GetClicks;

t1= Screen('MakeTexture',w, image);
Screen('TextFont',t1,'Arial'); 
DrawFormattedText(t1,double('接下來將進行十次練習次\n用滑鼠點擊螢幕以繼續'),'center','center',256); 
Screen('DrawTexture',w, t1);
Screen('Flip',w);
GetClicks;

for g = 1:2
    if (g == 1) 
        gender = "m";
    else
        gender = "f";
    end
    for n = 1:5
        fname = sprintf('faces/%s%.2d.jpg', gender, n + 40);
        img = imread(fname);
        Screen('PutImage', w, img);
        Screen('Flip', w);
        WaitSecs(2);
        for q = 1:2
           if (q == 1)
               question = double('現在請針對剛才圖片中人物的外貌進行1-7評分（請按鍵盤上方數字鍵）');
           else
               question = double('現在請針對剛才圖片中人物的社經地位進行1-7評分（請按鍵盤上方數字鍵）');
           end
           Screen('TextSize',w,30); 
           Screen('DrawText',w, question, 200,400, [0, 0, 0]);
           Screen('Flip',w);
           tStart = GetSecs;
           timedout = false;
           while ~timedout
             % check if a key is pressed
             % only keys specified in activeKeys are considered valid
             [ keyIsDown, keyTime, keyCode ] = KbCheck; 

               if(keyIsDown), break; end
               if( (keyTime - tStart) > t2wait), timedout = true; end
           end
           WaitSecs(.2);
        end
        WaitSecs(.2);
    end
end

Screen('Flip',w);
Screen('DrawText',w, double('請用滑鼠點擊螢幕開始正式測驗'), 200,400,[0, 0, 0]);
Screen('Flip',w);
GetClicks;

for n = order
    if (n == 1)
        seq = male_seq;
        gender = 'm';
    else
        seq = female_seq;
        gender = 'f';
    end
    
    for i = seq
        fname = sprintf('faces/%s%.2d.jpg', gender, i);
        img = imread(fname);
        Screen('PutImage', w, img);
        Screen('Flip', w);
        WaitSecs(2);
        
        for q = 1:2
            if (q == 1)
                question = double('現在請針對剛才圖片中人物的外貌進行1-7評分（請按鍵盤上方數字鍵）');
            else
                question = double('現在請針對剛才圖片中人物的社經地位進行1-7評分（請按鍵盤上方數字鍵）');
            end
            Screen('TextSize',w,30); 
            Screen('DrawText',w, question, 200,400,[0, 0, 0]);
            Screen('Flip',w);
            tStart = GetSecs;
            timedout = false;
            while ~timedout
             % check if a key is pressed
             % only keys specified in activeKeys are considered valid
             [ keyIsDown, keyTime, keyCode ] = KbCheck; 

               if(keyIsDown), break; end
               if( (keyTime - tStart) > t2wait), timedout = true; end
            end
            if (~timedout)
                if (q == 1) 
                    keyPressed = KbName(keyCode);
                    keyPressed = str2num(keyPressed(1)); % only select the first element
                    rt_1 = [rt_1 keyTime - tStart];
                    keynames_1 = [keynames_1 keyPressed]; 
                else
                    keyPressed = KbName(keyCode);
                    keyPressed = str2num(keyPressed(1));
                    rt_2 = [rt_2 keyTime - tStart];
                    keynames_2 = [keynames_2 keyPressed];
                end
            end
            % some time between questions
            WaitSecs(.2);
        end
        % time between image presentations
        WaitSecs(.3);
    end
end

if (order == 1) 
    seq = [male_seq female_seq];
    gender = repelem([1 2], size(seq, 2) / 2);
else
    seq = [female_seq male_seq];
    gender = repelem([2 1], size(seq, 2) / 2);
end

final_data = array2table([gender; seq; keynames_1; keynames_2; rt_1; rt_2].');
final_data.Properties.VariableNames = {'gender', 'seq', 'ratings_1', 'ratings_2', 'rt_1', 'rt_2'};
writetable(final_data, 'edata.csv');

Screen('Flip',w);
Screen('DrawText',w, double('測驗結束，感謝作答，可以通知主試者了 ＝）'), 200,400,[0, 0, 0]);
Screen('Flip',w);

% reset the keyboard input checking for all keys
RestrictKeysForKbCheck;
% re-enable echo to the command line for key presses
% if code crashes before reaching this point 
% CTRL-C will reenable keyboard input
ListenChar(1)


GetClicks;
Screen('Close', w);



