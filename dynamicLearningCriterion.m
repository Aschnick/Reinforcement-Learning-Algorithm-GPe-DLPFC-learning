function [ dynamic_successCriterion ] = dynamicLearningCriterion( behaviorMat )
%finding when learning reached

%calculating the dynamic success criterion
for i=1:size(behaviorMat(:,:,1),1)
    count = 0;
    j = 1;
    while count < 3 && j <= 15
        if behaviorMat(i,j,1) == 1
            count = count + 1;
        else
            count = 0;
        end
        j = j + 1;
    end
    dynamic_successCriterion(i) = j - 1;
end

end

