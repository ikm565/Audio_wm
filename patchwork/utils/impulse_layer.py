'''
Author: Chang Liu
Date: 2022-03-30 23:00:13
LastEditors: Chang Liu
LastEditTime: 2022-03-31 09:24:09
FilePath: /patchwork/utils/impulse_layer.py
Description: do diffeerential impulse to audio wav

Copyright (c) 2022 by Chang Liu/USTC, All Rights Reserved. 
'''
import os
import torch
import random
import torchaudio
import numpy as np
from hparameters import *
from torch_audiomentations import ApplyImpulseResponse,Compose

class impulse_attack2():
    def __init__(self, sr1, sr2):
        self.name = "impulse_attack_layer"
        self.irr_path = IRR_PATH
        
    def impulse(self, sig):
        augment = Compose([
        ApplyImpulseResponse(self.irr_path,p=1,compensate_for_propagation_delay=True),
        ])
        ae_convolved = augment(sig, sample_rate=SAMPLE_RATE)
        return ae_convolved

if __name__ == "__main__":
    my = impulse_attack2(1, 1)
    sig = torch.rand(4, 1, 512*512*2)
    ae = my.impulse(sig)
    print(ae.shape)
