import numpy as np
import pyworld as pw
from scipy.signal import medfilt
import soundfile as sf
import librosa
from scipy.signal import lfilter
# from IPython.display import Audio
import os
import uuid

#エコー
def delay(data, delay_samples, weight=0.4, repeat=2):
    output = np.zeros(len(data) + delay_samples * repeat)
    for i in range(len(data)):
        for j in range(repeat + 1):
            if i - delay_samples * j >= 0:
                output[i + delay_samples * j] += data[i] * (weight ** j)
    return output

def hard_clipping(data, frame_length, threshold_ratio=0.9):
    output = np.zeros_like(data)
    hop_length = frame_length  # オーバーラップなしの場合

    # フレーム分割
    frames = librosa.util.frame(data, frame_length=frame_length, hop_length=hop_length).T
    max_values = np.max(frames, axis=1)
    min_values = np.min(frames, axis=1)

    for j, frame in enumerate(frames):
        max_thresh = threshold_ratio * max_values[j]
        min_thresh = threshold_ratio * min_values[j]
        # フレーム内のクリッピング
        clipped_frame = np.clip(frame, min_thresh, max_thresh)
        # 出力配列にコピー
        start = j * hop_length
        end = start + frame_length
        output[start:end] = clipped_frame

    return output

def soft_clipping(data, frame_length, threshold_ratio=0.9):
    output = np.zeros_like(data)
    hop_length = frame_length  # オーバーラップなしの場合

    # フレーム分割
    frames = librosa.util.frame(data, frame_length=frame_length, hop_length=hop_length).T
    max_values = np.max(np.abs(frames), axis=1)  # 絶対値のピーク

    for j, frame in enumerate(frames):
        threshold = threshold_ratio * max_values[j]

        # ソフトクリッピング（tanh関数を利用）
        clipped_frame = threshold * np.tanh(frame / threshold)

        # 出力配列にコピー
        start = j * hop_length
        end = start + frame_length
        output[start:end] = clipped_frame

    return output

def compressor(data, frame_length, threshold_ratio=0.6, ratio=4.0):
    output = np.zeros_like(data)
    hop_length = frame_length//2  # オーバーラップなしの場合

    # フレーム分割
    frames = librosa.util.frame(data, frame_length=frame_length, hop_length=hop_length).T
    max_values = np.max(np.abs(frames), axis=1)

    for j, frame in enumerate(frames):
        threshold = threshold_ratio * max_values[j]

        clipped_frame = np.copy(frame)
        # 正の部分
        above_pos = frame > threshold
        clipped_frame[above_pos] = threshold + (frame[above_pos] - threshold) / ratio
        # 負の部分
        above_neg = frame < -threshold
        clipped_frame[above_neg] = -threshold + (frame[above_neg] + threshold) / ratio

        # 出力にコピー
        start = j * hop_length
        end = start + frame_length
        output[start:end] = clipped_frame

    return output

def lowshelf(x, fs, f0=100, Q=0.707, gain_db=6):
    A = 10**(gain_db/40)
    w0 = 2*np.pi*f0/fs
    alpha = np.sin(w0)/(2*Q)
    cosw0 = np.cos(w0)

    # 係数
    b0 =    A*( (A+1) - (A-1)*cosw0 + 2*np.sqrt(A)*alpha )
    b1 =  2*A*( (A-1) - (A+1)*cosw0 )
    b2 =    A*( (A+1) - (A-1)*cosw0 - 2*np.sqrt(A)*alpha )
    a0 =        (A+1) + (A-1)*cosw0 + 2*np.sqrt(A)*alpha
    a1 =   -2*( (A-1) + (A+1)*cosw0 )
    a2 =        (A+1) + (A-1)*cosw0 - 2*np.sqrt(A)*alpha

    # 正規化
    b = np.array([b0, b1, b2])/a0
    a = np.array([1, a1/a0, a2/a0])

    # 高速フィルタ処理
    y = lfilter(b, a, x)
    return y

def highshelf(x, fs, f0=500, Q=0.707, gain_db=-6):
    A = 10**(gain_db/40)
    w0 = 2*np.pi*f0/fs
    alpha = np.sin(w0)/(2*Q)
    cosw0 = np.cos(w0)

    b0 =    A*( (A+1) + (A-1)*cosw0 + 2*np.sqrt(A)*alpha )
    b1 = -2*A*( (A-1) + (A+1)*cosw0 )
    b2 =    A*( (A+1) + (A-1)*cosw0 - 2*np.sqrt(A)*alpha )
    a0 =        (A+1) - (A-1)*cosw0 + 2*np.sqrt(A)*alpha
    a1 =    2*( (A-1) - (A+1)*cosw0 )
    a2 =        (A+1) - (A-1)*cosw0 - 2*np.sqrt(A)*alpha

    b = np.array([b0,b1,b2])/a0
    a = np.array([1,a1/a0,a2/a0])

    # lfilterで高速処理
    y = lfilter(b, a, x)
    return y

def peaking(x, fs, f0=1000, Q=1.0, gain_db=6):
    A = 10**(gain_db/40)
    w0 = 2*np.pi*f0/fs
    alpha = np.sin(w0)/(2*Q)
    cosw0 = np.cos(w0)

    # バイクワッド係数
    b0 = 1 + alpha*A
    b1 = -2*cosw0
    b2 = 1 - alpha*A
    a0 = 1 + alpha/A
    a1 = -2*cosw0
    a2 = 1 - alpha/A

    b = np.array([b0, b1, b2]) / a0
    a = np.array([1, a1/a0, a2/a0])

    # lfilterで高速処理
    y = lfilter(b, a, x)
    return y

#音揺らす
def tremolo(data,sr,depth,rate):
  output = np.zeros(len(data))
  output = data *(1 + depth * np.sin(2 * np.pi * rate * np.arange(len(data)) / sr))
  return output

def hold_small_pitch_change_time_limited(
    f0,
    semitone_th=0.3,
    max_hold=3
):
    f0_out = f0.copy()
    hold_count = 0

    for i in range(1, len(f0)):
        if f0[i] <= 0 or f0_out[i-1] <= 0:
            hold_count = 0
            continue

        diff = abs(12 * np.log2(f0[i] / f0_out[i-1]))

        if diff < semitone_th and hold_count < max_hold:
            f0_out[i] = f0_out[i-1]
            hold_count += 1
        else:
            hold_count = 0

    return f0_out


# =========================================================
# WORLD ピッチ補正
# =========================================================
def world_pitch_correct(
    y,
    sr,
    frame_period=5.0,
    f0_floor=140,
    f0_ceil=700,
    alpha=2.0,
    semitone_th=0.5,
    max_hold=30,
    out_file=None
):
    # -----------------------------
    # WORLD 分解
    # -----------------------------
    f0_raw, t = pw.harvest(
        y, sr,
        f0_floor=f0_floor,
        f0_ceil=f0_ceil,
        frame_period=frame_period
    )
    f0 = pw.stonemask(y, f0_raw, t, sr)

    sp = pw.cheaptrick(y, f0, t, sr)
    ap = pw.d4c(y, f0, t, sr)

    voiced = f0 > 0

    # -----------------------------
    # 小変動ホールド
    # -----------------------------
    f0_stable = hold_small_pitch_change_time_limited(
        f0,
        semitone_th=semitone_th,
        max_hold=max_hold
    )

    # -----------------------------
    # セミトーン量子化
    # -----------------------------
    f0_target = f0.copy()

    quantized_f0 = 440.0 * 2**(
        np.round(12 * np.log2(f0_stable[voiced] / 440.0)) / 12
    )
    quantized_f0 = np.clip(quantized_f0, f0_floor, 500)

    f0_target[voiced] = (
        (1 - alpha) * f0_stable[voiced]
        + alpha * quantized_f0
    )

    f0_target[voiced] = medfilt(f0_target[voiced], kernel_size=5)

    # -----------------------------
    # 合成
    # -----------------------------
    y_out = pw.synthesize(f0_target, sp, ap, sr)
    y_out = y_out[:len(y)]
    y_out /= np.max(np.abs(y_out) + 1e-9)

    if out_file is not None:
        sf.write(out_file, y_out.astype(np.float32), sr)

    return y_out, f0, f0_target



#y, sr = librosa.load("/content/20251219_192656.wav", sr=None)
#フィルタ１
def effect_simple(y, sr):
# --------------------------
# 低域ノイズ除去（HPF代わり）
# --------------------------
    y = lowshelf(y, fs=sr, f0=80, Q=0.707, gain_db=-6)  # 低域を少しカット
# --------------------------
# 高域ノイズ除去（息・バリバリ対策）
# --------------------------
    y = highshelf(y, fs=sr, f0=5000, Q=0.707, gain_db=-6)  # 高域を少しカット
# --------------------------
# 必要に応じてピーキングで強調・抑制
# --------------------------
# 例えば 2~4 kHz を少し抑えることでバリバリ感軽減
    y = peaking(y, fs=sr, f0=3000, Q=1.0, gain_db=-3)
# --------------------------
# コンプレッサでピーク抑制
# --------------------------
    y = compressor(y, frame_length=2048, threshold_ratio=0.6, ratio=4.0)
#Audio(y, rate=sr)

# 使用例
    y, _, _ = world_pitch_correct(
        y, sr,
        alpha=1.0,
        frame_period=5.0
    )
    y = delay(y, delay_samples=100, weight=0.6, repeat=4)
    return y


#y, sr = librosa.load("/content/20251219_192656.wav", sr=None)
#フィルタ2
def effect_kirakira(y, sr):
# --------------------------
# 低域ノイズ除去（HPF代わり）
# --------------------------
    y = lowshelf(y, fs=sr, f0=80, Q=0.707, gain_db=-6)  # 低域を少しカット
# --------------------------
# 高域ノイズ除去（息・バリバリ対策）
# --------------------------
    y = highshelf(y, fs=sr, f0=5000, Q=0.707, gain_db=-6)  # 高域を少しカット
# --------------------------
# 必要に応じてピーキングで強調・抑制
# --------------------------
# 例えば 2~4 kHz を少し抑えることでバリバリ感軽減
    y = peaking(y, fs=sr, f0=3000, Q=1.0, gain_db=-3)
# --------------------------
# コンプレッサでピーク抑制
# --------------------------
    y = compressor(y, frame_length=2048, threshold_ratio=0.6, ratio=4.0)
#Audio(y, rate=sr)

# 使用例
    y, _, _ = world_pitch_correct(
        y, sr,
        alpha=5.0,
        frame_period=5.0
    )
    y = delay(y, delay_samples=100, weight=0.6, repeat=4)
    y = tremolo(y, sr, depth=0.6, rate=3)
    return y



#y, sr = librosa.load("/content/20251219_192656.wav", sr=None)
#フィルタ3
def effect_night(y, sr):
# --------------------------
# 低域ノイズ除去（HPF代わり）
# --------------------------
    y = lowshelf(y, fs=sr, f0=80, Q=0.707, gain_db=-6)  # 低域を少しカット
# --------------------------
# 高域ノイズ除去（息・バリバリ対策）
# --------------------------
    y = highshelf(y, fs=sr, f0=5000, Q=0.707, gain_db=-6)  # 高域を少しカット
# --------------------------
# 必要に応じてピーキングで強調・抑制
# --------------------------
# 例えば 2~4 kHz を少し抑えることでバリバリ感軽減
    y = peaking(y, fs=sr, f0=3000, Q=1.0, gain_db=-6)
# --------------------------
# コンプレッサでピーク抑制
# --------------------------
    y = compressor(y, frame_length=2048, threshold_ratio=0.6, ratio=4.0)
#Audio(y, rate=sr)

# 使用例
    y, _, _ = world_pitch_correct(
        y, sr,
        alpha=3.0,
        frame_period=5.0
    )
    y = delay(y, delay_samples=100, weight=0.6, repeat=4)
    return y



def apply_filter(input_path: str, style: str = "simple") -> str:
    y, sr = librosa.load(input_path, sr=None)
    
    if style == "simple":
        print("apply simple")
        y = effect_simple(y, sr)
    elif style == "kirakira":
        print("apply kirakira")
        y = effect_kirakira(y, sr)
    elif style == "night":
        print("apply night")
        y = effect_night(y, sr)
    else:
        raise ValueError(f"Unknown style: {style}")

    #  # --------------------------
    #  # 前処理
    #  # --------------------------
    # y = lowshelf(y, fs=sr, f0=80, gain_db=-12)
    # y = highshelf(y, fs=sr, f0=5000, gain_db=6)
    # y = peaking(y, fs=sr, f0=3000, Q=1.0, gain_db=-3)
    # y = compressor(y, frame_length=2048, threshold_ratio=0.6, ratio=4.0)

    # # --------------------------
    # # WORLD ピッチ補正（必要なら）
    # # --------------------------
    # # if style == "pitch":
    # y, _, _ = world_pitch_correct(y, sr)

    # 正規化
    y = y / (np.max(np.abs(y)) + 1e-9)

    # --------------------------
    # 出力
    # --------------------------
    os.makedirs("outputs", exist_ok=True)
    output_path = os.path.join(
        "outputs",
        f"{uuid.uuid4()}_processed.wav"
    )

    sf.write(output_path, y.astype(np.float32), sr)

    return output_path