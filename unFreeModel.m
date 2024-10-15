function [ simBehaviorMat, avgS ] = unFreeModel( correctChoices, alphaConst, NHPsChoices )
%Reinforcement Learning Algorithm
%   the behavioral matrices return the value of success in the 1st column.
%   switch or same in the second.
%   In the third row is the value of alpha at the current trial.


prevState = 4;
Qt = rand(1,3);
Qt = Qt/sum(Qt);
reward = 1;
oldAlpha = nan;


for i = 1:size(NHPsChoices,1)
    correctChoice = correctChoices(i);
    sumCorrect = 0;
    for j = 1:15
        %the forced choice:
        currentChoice = NHPsChoices(i,j);
        % "touching the screen" - entering the choice and reciving reward:
        [ correct,sumCorrect ] = touchScreen(currentChoice,correctChoice,sumCorrect);
        % adjusting agent's state values for the next iteration:
        [ Qt, alpha ] = updateChoiceValue( currentChoice,Qt,reward,correct, alphaConst);
        
        % record the behavior:
        if correct
            simBehaviorMat(i,j,1) = 1;
        else
            simBehaviorMat(i,j,1) = -1;
        end
        % switches
        if prevState ~= currentChoice
            simBehaviorMat(i,j,2) = 1;
        elseif  find(prevState) == find(currentChoice)
            simBehaviorMat(i,j,2) = -1;
        end
        %alpha value
        simBehaviorMat(i,j,3) = oldAlpha;
        
        oldAlpha = alpha;
        
        prevState = currentChoice;
    end
end

simBehaviorMat(simBehaviorMat == 0) = nan;
simBehaviorMat(simBehaviorMat == -1) = 0;


% count = 1;
% for blockNum=1:size(simBehaviorMat,1)
%     try
%         endBehaviorMat(count,1:5,1) = simBehaviorMat(blockNum,find(isnan(simBehaviorMat(blockNum,:)),1)-5:find(isnan(simBehaviorMat(blockNum,:)),1)-1,1);
%         endBehaviorMat(count,1:5,2) = simBehaviorMat(blockNum,find(isnan(simBehaviorMat(blockNum,:)),1)-5:find(isnan(simBehaviorMat(blockNum,:)),1)-1,2);
%         endBehaviorMat(count,1:5,3) = simBehaviorMat(blockNum,find(isnan(simBehaviorMat(blockNum,:)),1)-5:find(isnan(simBehaviorMat(blockNum,:)),1)-1,3);
%         
%         count = count + 1;
%     end
% end
% 
avgS = mean(simBehaviorMat(:,1:15,1));
% SDS = std(simBehaviorMat(:,1:15,1));
% amountS = size(simBehaviorMat,1);
% stimEnds = mean(endBehaviorMat(:,1:5,1));

% allTrialsAvg = [stimEnds,avgS];


end



function [ correct,sumCorrect ] = touchScreen(currentChoice,correctChoice,sumCorrect)
if currentChoice == correctChoice
    correct = 1;
    sumCorrect = sumCorrect + 1;
else
    correct = 0;
end
end


function [ Qt_new, alpha ] = updateChoiceValue( currentChoice,Qt_old,reward,precivedReward, const )
Qt_new = Qt_old;
if precivedReward
    switch currentChoice
        case 1
            %alpha is calculated as a measure of surprise
            alpha = const*((1-Qt_old(1))/(1+Qt_old(1)))^std(Qt_old);
            Qt_new(1) = Qt_old(1) + alpha*(precivedReward - Qt_old(1));
            
            Qt_new(2) = Qt_old(2) + alpha*(1 - precivedReward - Qt_old(2));
            Qt_new(3) = Qt_old(3) + alpha*(1 - precivedReward - Qt_old(3));
        case 2
            alpha = const*((1-Qt_old(2))/(1+Qt_old(2)))^std(Qt_old);
            Qt_new(2) = Qt_old(2) + alpha*(precivedReward - Qt_old(2));
            
            Qt_new(1) = Qt_old(1) + alpha*(1 - precivedReward - Qt_old(1));
            Qt_new(3) = Qt_old(3) + alpha*(1 - precivedReward - Qt_old(3));
        case 3
            alpha = const*((1-Qt_old(3))/(1+Qt_old(3)))^std(Qt_old);
            Qt_new(3) = Qt_old(3) + alpha*(precivedReward - Qt_old(3));
            
            Qt_new(1) = Qt_old(1) + alpha*(1 - precivedReward - Qt_old(1));
            Qt_new(2) = Qt_old(2) + alpha*(1 - precivedReward - Qt_old(2));
    end
else
    switch currentChoice
        case 1
            alpha = const*(Qt_old(1)/(2-Qt_old(1)))^(std(Qt_old));
            Qt_new(1) = Qt_old(1) + alpha*(precivedReward - Qt_old(1));
            
            Qt_new(2) = Qt_old(2) + alpha*(1 - precivedReward - Qt_old(2));
            Qt_new(3) = Qt_old(3) + alpha*(1 - precivedReward - Qt_old(3));
        case 2
            alpha = const*(Qt_old(2)/(2-Qt_old(2)))^(std(Qt_old));
            Qt_new(2) = Qt_old(2) + alpha*(precivedReward - Qt_old(2));
            
            Qt_new(1) = Qt_old(1) + alpha*(1 - precivedReward - Qt_old(1));
            Qt_new(3) = Qt_old(3) + alpha*(1 - precivedReward - Qt_old(3));
        case 3
            alpha = const*(Qt_old(3)/(2-Qt_old(3)))^(std(Qt_old));
            Qt_new(3) = Qt_old(3) + alpha*(precivedReward - Qt_old(3));
            
            Qt_new(1) = Qt_old(1) + alpha*(1 - precivedReward - Qt_old(1));
            Qt_new(2) = Qt_old(2) + alpha*(1 - precivedReward - Qt_old(2));
    end
end
end

