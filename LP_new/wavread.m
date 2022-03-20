function [y,Fs,bits]=wavread(file,ext)
%WAVREAD Read Microsoft WAVE (".wav") sound file.
%   Y=WAVREAD(FILE) reads a WAVE file specified by the string FILE,
%   returning the sampled data in Y. The ".wav" extension is appended
%   if no extension is given. 
%
%   [Y,FS,BITS]=WAVREAD(FILE) returns the sample rate (FS) in Hertz
%   and the number of bits per sample (BITS) used to encode the
%   data in the file.
%
%   [...]=WAVREAD(FILE,N) returns only the first N samples from each
%       channel in the file.
%   [...]=WAVREAD(FILE,[N1 N2]) returns only samples N1 through N2 from
%       each channel in the file.
%   SIZ=WAVREAD(FILE,'size') returns the size of the audio data contained
%       in the file in place of the actual audio data, returning the
%       vector SIZ=[samples channels].
%
%   Supports multi-channel data, with up to 16 bits per sample.
%
%   See also WAVWRITE, AUREAD.
 
%   Copyright (c) 1984-97 by The MathWorks, Inc.
%   $Revision: 5.7 $  $Date: 1997/04/08 05:25:06 $
 
%   D. Orofino, 11/95
 
if nargin>2,
  error('Too many input arguments.');
end
file = deblank(file);
% Append .wav extension if it's missing:
if isempty(findstr(file,'.')),
  file=[file '.wav'];
end
fid=fopen(file,'rb','l');   % Little-endian
if fid == -1,
  error('Can''t open WAVE file for input.');
end
 
% Find the first RIFF chunk:
riffck=find_cktype(fid,'RIFF');
if ~isstruct(riffck), error(riffck); end
 
% The subchunk better be WAVE:
waveck=find_cktype(fid,'WAVE',1);
if ~isstruct(waveck), error(waveck); end
 
% Find <fmt-ck> chunk:
fmtck=find_cktype(fid,'fmt');
if ~isstruct(fmtck), error(fmtck); end
 
% Read <wave-format>:
wavefmt = read_wavefmt(fid,fmtck);
if ~isstruct(wavefmt), error(wavefmt); end
 
% Find <data-ck> chunk:
datack=find_cktype(fid,'data');
if ~isstruct(datack), error(datack); end
 
% Parse structure info for return to user:
Fs = wavefmt.nSamplesPerSec;
bits = wavefmt.nBitsPerSample;
 
% Determine if caller wants data:
if nargin<2, ext=[]; end    % Default - read all samples
exts=prod(size(ext));
if strncmp(lower(ext),'size',exts),
  % Caller doesn't want data - just data size:
  samples = read_wavedat(datack,wavefmt,-1);
  fclose(fid);
  if isstr(samples), error(samples); end
  y = [samples wavefmt.nChannels];
  return;
elseif exts>2,
  error('Index range must be specified as a scalar or 2-element vector.');
elseif (exts==1),
  ext=[1 ext];  % Prepend start sample index
end
 
% Read <wave-data>:
datack = read_wavedat(datack,wavefmt,ext);
fclose(fid);
if ~isstruct(datack), error(datack); end
 
% Return audio data to user:
y = datack.Data;
 
% end of wavread()
 
 
% ------------------------------------------------------------------------
% Private functions:
% ------------------------------------------------------------------------
 
% READ_CKINFO: Reads next RIFF chunk, but not the chunk data.
%   If optional sflg is set to nonzero, reads SUBchunk info instead.
%   Expects an open FID pointing to first byte of chunk header.
%   Returns a new chunk structure.
function ck=read_ckinfo(fid,sflg)
if nargin<2, sflg=0; end
ck.fid = fid;
ck.Data = [];
[s,cnt] = fread(fid,4,'char');
if cnt~=4, ck='Error reading file header.'; return; end
ck.ID = deblank(setstr(s'));
if ~sflg,
  % Read chunk size (skip if subchunk):
  [sz,cnt] = fread(fid,1,'ulong');
  if cnt~=1, ck='Error reading file header.'; return; end
  ck.Size = sz;
end
return;
 
% FIND_CKTYPE: Finds a chunk with appropriate type.
%   Searches from current file position specified by fid.
%   Leaves file positions to data of desired chunk.
%   If optional sflg is set to nonzero, finds a SUBchunk instead.
function ck = find_cktype(fid,type,sflg)
if nargin<3, sflg=0; end
while 1,
  ck=read_ckinfo(fid,sflg);
  if ~isstruct(ck), return; end
  if strcmp(ck.ID,type), return; end
  % Return error flag if this is not the desired subchunk type:
  if sflg, ck='Error reading file header.'; return; end
  % Skip over data in chunk:
  if(fseek(fid,ck.Size,0)==-1),
    ck='Error reading file header.'; return;
  end
end
return;
 
% READ_WAVEFMT: Read WAVE format chunk.
%   Assumes fid points to the wave-format subchunk.
%   Requires chunk structure to be passed, indicating
%   the length of the chunk in case we don't recognize
%   the format tag.
function fmt=read_wavefmt(fid,ck)
total_bytes=ck.Size; % # bytes in subchunk
 
% Read standard <wave-format> data:
fmt.wFormatTag      = fread(fid,1,'ushort'); % Data encoding format
fmt.nChannels       = fread(fid,1,'ushort'); % Number of channels
fmt.nSamplesPerSec  = fread(fid,1,'ulong');  % Samples per second
fmt.nAvgBytesPerSec = fread(fid,1,'ulong');  % Avg transfer rate
fmt.nBlockAlign     = fread(fid,1,'ushort'); % Block alignment
nbytes=14;  % # of bytes read so far
 
% Read format-specific info:
if fmt.wFormatTag==1,
   % Read standard <PCM-format-specific> info:
    
   % There had better be a bits/sample field:
   if (total_bytes < nbytes+2),
      fmt='Error reading file format.'; return;
   end   
  [bits,cnt]=fread(fid,1,'ushort');
  nbytes=nbytes+2;
  if (cnt~=1),
    fmt='Error reading file format.'; return;
  end 
  fmt.nBitsPerSample=bits;
   
  % Are there any additional fields present?
  if (total_bytes > nbytes),
     % See if the "cbSize" field is present.  If so, grab the data:
     if (total_bytes >= nbytes+2),
       % we have the cbSize ushort in the file:
       [cbSize,cnt]=fread(fid,1,'ushort');
       nbytes=nbytes+2;
       if (cnt~=1),
          fmt='Error reading file format.'; return;
       end
       fmt.cbSize = cbSize;
    end
     
    % Check for anything else:
    if (total_bytes > nbytes),
       % Simply skip remaining stuff - we don't know what it is:
       if (fseek(fid,total_bytes-nbytes,0) == -1);
          fmt='Error reading file format.'; return;
       end
    end    
 end
  
else
  % Skip over any remaining bytes for unknown formats:
  if nbytes>total_bytes,
    fmt='Error reading file format.'; return;
  elseif nbytes<total_bytes,
    if(fseek(fid,total_bytes-nbytes,0)==-1),
      fmt='Error reading file format.'; return;
    end
  end
end
return;
 
% READ_WAVEDAT: Read WAVE data chunk
%   Assumes fid points to the wave-data chunk
%   Requires <data-ck> and <wave-format> structures to be passed.
%   Requires extraction range to be specified.
%   Setting ext=[] forces ALL samples to be read.  Otherwise,
%       ext should be a 2-element vector specifying the first
%       and last samples (per channel) to be extracted.
%   Setting ext=-1 returns the number of samples per channel,
%       skipping over the sample data.
function dat=read_wavedat(datack,wavefmt,ext)
total_bytes=datack.Size; % # bytes in this chunk
 
if wavefmt.wFormatTag==1,
  % PCM Format:
  % Determine # bytes/sample - format requires rounding
  %  to next integer number of bytes:
  BytesPerSample = ceil(wavefmt.nBitsPerSample/8);
  if     BytesPerSample==1, dtype='uchar'; % unsigned 8-bit
  elseif BytesPerSample==2, dtype='short'; % signed 16-bit
  else
    dat='Cannot read WAVE files with more than 16 bits/sample.'; return;
  end
  total_samples = datack.Size/BytesPerSample;
  SamplesPerChannel = total_samples/wavefmt.nChannels;
  if ~isempty(ext) & ext==-1,
    % Just return the samples per channel, and fseek past data:
    dat = SamplesPerChannel;
    if(fseek(datack.fid,total_samples,0)==-1),
      dat='Error reading file.';
    end
    return;
  end
  % Determine sample range to read:
  if isempty(ext),
    ext = [1 SamplesPerChannel];    % Return all samples
  else
    if prod(size(ext))~=2,
      dat='Sample limit vector must have 2 elements.'; return;
    end
    if ext(1)<1 | ext(2)>SamplesPerChannel,
      dat='Sample limits out of range.'; return;
    end
    if ext(1)>ext(2),
      dat='Sample limits must be given in ascending order.'; return;
    end
  end
  % Skip over leading samples:
  if ext(1)>1,
    % Skip over leading samples, if specified:
    if(fseek(datack.fid, ...
          BytesPerSample*(ext(1)-1)*wavefmt.nChannels,0)==-1),
      dat='Error reading file.'; return;
    end
  end
  % Read desired data:
  nSPCext = ext(2)-ext(1)+1; % # samples per channel in extraction range
  dat = datack;  % Copy input structure to output
  extSamples = wavefmt.nChannels*nSPCext;
  dat.Data = fread(datack.fid, [wavefmt.nChannels nSPCext], dtype);
  % if cnt~=extSamples, dat='Error reading file.'; return; end
  % Skip over trailing samples:
  if(fseek(datack.fid, BytesPerSample * ...
           (SamplesPerChannel-ext(2))*wavefmt.nChannels, 0)==-1),
    dat='Error reading file.'; return;
  end
  % Determine if a pad-byte is appended to data chunk,
  %   skipping over it if present:
  if rem(datack.Size,2), fseek(datack.fid,1,0); end
  % Rearrange data into a matrix with one channel per column:
  dat.Data = dat.Data';
  % Normalize data range: min will hit -1, max will not quite hit +1.
  if BytesPerSample==1,
    dat.Data = (dat.Data-128)/128;  % [-1,1)
  else
    dat.Data = dat.Data;  % [-1,1)
  end
else
  % Unknown wave-format for data.
  dat='Unrecognized file format.';
end
 
return;
 
% end of wavread.m