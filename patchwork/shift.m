function [C] = shift(A,length_audio)
    B = reshape(A,[],1);
    record_length = length(B);
    move = 6000; %move < record_length-length_audio
    C = B(1+move:record_length); %529200
    % C = [C;zeros(move,1)];
%     A = A(1:length_audio);
end

