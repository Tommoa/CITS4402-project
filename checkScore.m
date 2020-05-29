% %example call:
% results = {{'Easy01','Highlighter'},{'Easy02','Bag','Toy','Rotor'}};
% answerfile = 'Scene_Objects-Easy.txt';
% [correct_num,correct_total,incorrect_num] = checkScore(results,answerfile)
% %returns: correct_num=3 correct_total=5 incorrect_num=1

% A function that returns the number of correctly identified objects, the
% total number of objects, and number of incorrectly identified objects
% in a scene.
function [correct_num,correct_total,incorrect_num] = checkScore(results,answerfile)
    file = fopen(answerfile,'r');
    answers = {split(fgetl(file),',')'};
    while ~feof(file)
        answers{end+1} = split(fgetl(file),',')';
    end
    fclose(file);

    correct_total = 0;
    correct_num = 0;
    incorrect_num = 0;
    for jj = 1:size(results,2)
        % disp(find([answers{:}{1}]==results{jj}{1}))
        scene = str2double(extractAfter(results{jj}{1},size(results{jj}{1},2)-2));
        correct_total = correct_total + size(answers{scene},2) - 1;
        matches = intersect(answers{scene},results{jj});
        correct_num = correct_num + size(matches,2) - 1;
        incorrect_num = incorrect_num + size(results{jj},2) - size(matches,2);
    end
end
