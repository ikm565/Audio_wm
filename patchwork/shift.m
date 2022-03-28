function [C] = shift(A,length_audio)
    B = reshape(A,[],1);
    record_length = length(B);
    move = 0; %move < record_length-length_audio
    if move<0
        C = [B;zeros(-move,1)];
    else
        C = B(1+move:record_length); %529200
        C = [C;zeros(move,1)];
    end
%     A = A(1:length_audio);
end

