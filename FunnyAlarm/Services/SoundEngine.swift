import Foundation
import AVFoundation

/// 音频与铃声引擎服务 (支持听觉安全 10 秒降音量控制)
public final class SoundEngine: ObservableObject {
    public static let shared = SoundEngine()

    private var audioPlayer: AVAudioPlayer?
    private var dipTimer: Timer?
    @Published public var isVolumeDipped: Bool = false
    @Published public var dipRemainingSeconds: Int = 0

    private var originalVolume: Float = 0.8

    private init() {}

    /// 播放场景默认铃声或自定义本地铃声
    public func playRingtone(named name: String, volume: Float = 0.8) {
        stopRingtone()
        self.originalVolume = volume

        // 试图从 Bundle 读取音频
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") ??
                        Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("🔊 警告: 未找到音频资源 \(name)，将播放系统预置震动/音效")
            AudioServicesPlaySystemSound(1005) // System Alarm Sound Fallback
            return
        }

        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .alarm, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            #endif

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 循环播放直至挑战完成
            audioPlayer?.volume = volume
            audioPlayer?.play()
        } catch {
            print("Audio Player Error: \(error)")
        }
    }

    /// 停止响铃
    public func stopRingtone() {
        audioPlayer?.stop()
        audioPlayer = nil
        dipTimer?.invalidate()
        dipTimer = nil
        isVolumeDipped = false
    }

    /// 听觉安全控制：触发 10 秒临时降音量 (降至 20%)
    public func trigger10sVolumeDip() {
        guard let player = audioPlayer, !isVolumeDipped else { return }

        isVolumeDipped = true
        dipRemainingSeconds = 10
        player.volume = originalVolume * 0.2

        dipTimer?.invalidate()
        dipTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.dipRemainingSeconds > 1 {
                self.dipRemainingSeconds -= 1
            } else {
                timer.invalidate()
                self.restoreVolume()
            }
        }
    }

    /// 恢复原设置音量
    private func restoreVolume() {
        audioPlayer?.volume = originalVolume
        isVolumeDipped = false
        dipRemainingSeconds = 0
    }
}
