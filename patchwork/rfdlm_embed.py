import numpy
import torch 
import torchaudio
from pre_process import process_audio

def rfdlm_embed(input_audio, watermark):
    rfdlm_list = process_audio(input_audio)
    A, sr = torchaudio.load(input_audio)
    A = A.numpy()
    
    return 0