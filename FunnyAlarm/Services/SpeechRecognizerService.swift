import Foundation
import Speech
import AVFoundation
import Combine

/// 端侧实时语音识别与关键字匹配服务
public final class SpeechRecognizerService: ObservableObject {
    @Published public var transcribedText: String = ""
    @Published public var isMatched: Bool = false
    @Published public var isListening: Bool = false
    @Published public var errorMessage: String? = nil

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    private var targetKeywords: [String] = []

    public init() {}

    /// 启动端侧 ASR 监听与关键字搜索
    public func startListening(targetKeywords: [String]) {
        self.targetKeywords = targetKeywords.map { $0.lowercased() }
        self.transcribedText = ""
        self.isMatched = false
        self.errorMessage = nil

        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.beginAudioEngineRecording()
                } else {
                    self.errorMessage = "未获得语音识别权限"
                }
            }
        }
    }

    /// 停止语音识别
    public func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isListening = false
    }

    private func beginAudioEngineRecording() {
        stopListening()

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.requiresOnDeviceRecognition = true // 100% 端侧离线隐私处理

            let inputNode = audioEngine.inputNode
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                if let result = result {
                    let text = result.bestTranscription.formattedString.lowercased()
                    DispatchQueue.main.async {
                        self.transcribedText = text
                        self.checkKeywordMatch(text: text)
                    }
                }
                if error != nil || (result?.isFinal ?? false) {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                }
            }

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            isListening = true
        } catch {
            errorMessage = "录音引擎启动失败: \(error.localizedDescription)"
        }
    }

    private func checkKeywordMatch(text: String) {
        for keyword in targetKeywords {
            if text.contains(keyword) {
                self.isMatched = true
                stopListening()
                break
            }
        }
    }
}
