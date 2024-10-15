function [ simBehaviorMat, endBehaviorMat, allTrialsAvg ] = ReinforcementLearningAlphaSurprise( correctChoices,temprature, alphaConst )
%Reinforcement Learning Algorithm
%   the behavioral matrices return the value of success in the 1st column.
%   switch or same in the second.
%   In the third row is the value of alpha at the current trial.


prevState = 4;
Qt = rand(1,3);
Qt = Qt/sum(Qt);
reward = 1;
oldAlpha = nan;

for blockNum=1:length(correctChoices)
    correctChoice = correctChoices(blockNum);
    dontStop = 0;
    sumCorrect = 0;
    trialNum = 1;
    while ~dontStop
        if sumCorrect >= 15
            dontStop = round(rand(1));
        else
            dontStop = 0;
        end
        %the agent's choice:
        [ currentChoice, P, highestP_choice ] = agentChoice( Qt,temprature);
        % "touching the screen" - entering the choice and reciving reward:
        [ correct,sumCorrect ] = touchScreen(currentChoice,correctChoice,sumCorrect);
        % adjusting agent's state values for the next iteration:
        [ Qt, alpha ] = updateChoiceValue( currentChoice,P,reward,correct, alphaConst, Qt);
        
        % record the behavior:
        if correct
            simBehaviorMat(blockNum,trialNum,1) = 1;
        else
            simBehaviorMat(blockNum,trialNum,1) = -1;
        end
        % switches
        if prevState ~= currentChoice
            simBehaviorMat(blockNum,trialNum,2) = 1;
        elseif  find(prevState) == find(currentChoice)
            simBehaviorMat(blockNum,trialNum,2) = -1;
        end
        %alpha value
        simBehaviorMat(blockNum,trialNum,3) = oldAlpha;%think
        
        oldAlpha = alpha;
        
        prevState = currentChoice;
        trialNum = trialNum + 1;
        
    end
end

simBehaviorMat(simBehaviorMat == 0) = nan;
simBehaviorMat(simBehaviorMat == -1) = 0;


count = 1;
for blockNum=1:size(simBehaviorMat,1)
    try
        endBehaviorMat(count,1:5,1) = simBehaviorMat(blockNum,find(isnan(simBehaviorMat(blockNum,:)),1)-5:find(isnan(simBehaviorMat(blockNum,:)),1)-1,1);
        endBehaviorMat(count,1:5,2) = simBehaviorMat(blockNum,find(isnan(simBehaviorMat(blockNum,:)),1)-5:find(isnan(simBehaviorMat(blockNum,:)),1)-1,2);
        endBehaviorMat(count,1:5,3) = simBehaviorMat(blockNum,find(isnan(simBehaviorMat(blockNum,:)),1)-5:find(isnan(simBehaviorMat(blockNum,:)),1)-1,3);
        
        count = count + 1;
    end
end

avgS = mean(simBehaviorMat(:,1:15,1));
SDS = std(simBehaviorMat(:,1:15,1));
amountS = size(simBehaviorMat,1);
stimEnds = mean(endBehaviorMat(:,1:5,1));

allTrialsAvg = [stimEnds,avgS];


end

function [ currentChoice, P, highestP_choice ] = agentChoice( Qt,temprature)

%softmax:
P(1) = (exp(1)^(Qt(1)/temprature))/sum( exp(ones(1,3)).^(Qt./temprature) );
P(2) = (exp(1)^(Qt(2)/temprature))/sum( exp(ones(1,3)).^(Qt./temprature) );
P(3) = (exp(1)^(Qt(3)/temprature))/sum( exp(ones(1,3)).^(Qt./temprature) );
currentChoice = randsrc(1,1,[1:3; P]);

highestP_choice = max(P);

end


function [ correct,sumCorrect ] = touchScreen(currentChoice,correctChoice,sumCorrect)
if currentChoice == correctChoice
    correct = 1;
    sumCorrect = sumCorrect + 1;
else
    correct = 0;
end
end

function [precivedReward] = rewardP(correct, temprature)
    isReward = [correct,0];
    pReward(1) = (exp(1)^(isReward(1)/temprature))/sum( exp(ones(1,2)).^(isReward./temprature) );
    pReward(2) = (exp(1)^(isReward(2)/temprature))/sum( exp(ones(1,2)).^(isReward./temprature) );
    precivedReward = isReward(randsrc(1,1,[1:2; pReward]));
end

function [ Qt_new, alpha ] = updateChoiceValue( currentChoice,Preward,reward,precivedReward, const, Qt_old )
% Qt_new = Qt_old;
if precivedReward
    switch currentChoice
        case 1
            %alpha is calculated as a measure of surprise and uncertinty
            alpha = const*((1-Preward(1))/(1+Preward(1)))^std(Preward);
            Qt_new(1) = Qt_old(1) + alpha*(precivedReward - Qt_old(1));
            
            Qt_new(2) = Qt_old(2) + alpha*(1 - precivedReward - Qt_old(2));
            Qt_new(3) = Qt_old(3) + alpha*(1 - precivedReward - Qt_old(3));
        case 2
            alpha = const*((1-Preward(2))/(1+Preward(2)))^std(Preward);
            Qt_new(2) = Qt_old(2) + alpha*(precivedReward - Qt_old(2));
            
            Qt_new(1) = Qt_old(1) + alpha*(1 - precivedReward - Qt_old(1));
            Qt_new(3) = Qt_old(3) + alpha*(1 - precivedReward - Qt_old(3));
        case 3
            alpha = const*((1-Preward(3))/(1+Preward(3)))^std(Preward);
             Qt_new(3) = Qt_old(3) + alpha*(precivedReward - Qt_old(3));
             
             Qt_new(1) = Qt_old(1) + alpha*(1 - precivedReward - Qt_old(1));
             Qt_new(2) = Qt_old(2) + alpha*(1 - precivedReward - Qt_old(2));
    end
else
    switch currentChoice
        case 1
            alpha = const*(Preward(1)/(2-Preward(1)))^(std(Preward));
            Qt_new(1) = Qt_old(1) + alpha*(precivedReward - Qt_old(1));
            
            Qt_new(2) = Qt_old(2) + alpha*(1 - precivedReward - Qt_old(2));
            Qt_new(3) = Qt_old(3) + alpha*(1 - precivedReward - Qt_old(3));
        case 2
            alpha = const*(Preward(2)/(2-Preward(2)))^(std(Preward));
            Qt_new(2) = Qt_old(2) + alpha*(precivedReward - Qt_old(2));
            
            Qt_new(1) = Qt_old(1) + alpha*(1 - precivedReward - Qt_old(1));
            Qt_new(3) = Qt_old(3) + alpha*(1 - precivedReward - Qt_old(3));
        case 3
            alpha = const*(Preward(3)/(2-Preward(3)))^(std(Preward));
            Qt_new(3) = Qt_old(3) + alpha*(precivedReward - Qt_old(3));
            
            Qt_new(1) = Qt_old(1) + alpha*(1 - precivedReward - Qt_old(1));
            Qt_new(2) = Qt_old(2) + alpha*(1 - precivedReward - Qt_old(2));
    end
end
end

