import Foundation
import Vision
import AVFoundation
import Combine

/// Vision 姿态识别与面部倾斜检测服务 (端侧 100% 本地运算)
public final class VisionPoseAnalyzer: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published public var detectedPoseName: String? = nil
    @Published public var isTargetPoseMatched: Bool = false
    @Published public var matchProgress: Double = 0.0 // 0.0 ~ 1.0 (需持续 1.5 秒)

    private var targetPose: String = "heart"
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private let visionQueue = DispatchQueue(label: "com.funnyalarm.visionQueue", qos: .userInitiated)

    private var matchStartTime: Date?
    private let requiredHoldDuration: TimeInterval = 1.5 // 姿势持续满足 1.5 秒完成

    public override init() {
        super.init()
    }

    /// 启动前摄 15 FPS 帧率分析控制
    public func startCapture(targetPose: String) {
        self.targetPose = targetPose
        self.matchProgress = 0.0
        self.isTargetPoseMatched = false
        self.matchStartTime = nil

        visionQueue.async { [weak self] in
            guard let self = self else { return }
            let session = AVCaptureSession()
            session.sessionPreset = .vga640x480

            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: frontCamera) else {
                print("Camera unavailable")
                return
            }

            if session.canAddInput(input) { session.addInput(input) }

            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: self.visionQueue)
            output.alwaysDiscardsLateVideoFrames = true

            if session.canAddOutput(output) { session.addOutput(output) }

            self.captureSession = session
            session.startRunning()
        }
    }

    /// 停止摄像头采集
    public func stopCapture() {
        visionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            self?.captureSession = nil
        }
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
        let poseRequest = VNDetectHumanBodyPoseRequest()

        do {
            try requestHandler.perform([poseRequest])
            if let observation = poseRequest.results?.first {
                analyzeBodyPose(observation)
            }
        } catch {
            print("Vision request error: \(error)")
        }
    }

    private func analyzeBodyPose(_ observation: VNHumanBodyPoseObservation) {
        do {
            let points = try observation.recognizedPoints(.all)
            guard let leftWrist = points[.leftWrist], leftWrist.confidence > 0.4,
                  let rightWrist = points[.rightWrist], rightWrist.confidence > 0.4,
                  let leftShoulder = points[.leftShoulder], leftShoulder.confidence > 0.4,
                  let rightShoulder = points[.rightShoulder], rightShoulder.confidence > 0.4 else {
                resetHoldProgress()
                return
            }

            var isMatched = false

            switch targetPose {
            case "raise_hands":
                // 伸懒腰：双手指关节高于肩膀
                isMatched = (leftWrist.location.y > leftShoulder.location.y) && (rightWrist.location.y > rightShoulder.location.y)
            case "heart", "hold_face":
                // 比心/托脸：双手在头面部区域相靠近
                let handDistance = hypot(leftWrist.location.x - rightWrist.location.x, leftWrist.location.y - rightWrist.location.y)
                isMatched = handDistance < 0.35 && (leftWrist.location.y > leftShoulder.location.y * 0.8)
            default:
                // 默认抬手动作判定
                isMatched = leftWrist.location.y > leftShoulder.location.y
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if isMatched {
                    if self.matchStartTime == nil { self.matchStartTime = Date() }
                    let elapsed = Date().timeIntervalSince(self.matchStartTime!)
                    self.matchProgress = min(1.0, elapsed / self.requiredHoldDuration)

                    if elapsed >= self.requiredHoldDuration {
                        self.isTargetPoseMatched = true
                    }
                } else {
                    self.resetHoldProgress()
                }
            }
        } catch {
            print("Analyze body pose failed: \(error)")
        }
    }

    private func resetHoldProgress() {
        DispatchQueue.main.async { [weak self] in
            self?.matchStartTime = nil
            self?.matchProgress = 0.0
        }
    }
}
