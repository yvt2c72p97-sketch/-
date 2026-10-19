import Foundation
import AVFoundation

/// Demonstration DSP only, NOT the JiaLan target voice AI model.
/// Replace the pitch node in a production design with a validated streaming VC engine.
final class AudioController: ObservableObject {
    @Published var running = false
    @Published var recording = false
    @Published var pitchSemitones: Float = 3.0 {
        didSet { pitch.pitch = pitchSemitones * 100 }
    }
    @Published var lastRecording: URL?
    @Published var message = "就绪（当前为升调演示，并非嘉岚音色复刻）"

    private var engine = AVAudioEngine()
    private var pitch = AVAudioUnitTimePitch()
    private var file: AVAudioFile?

    func start() {
        guard !running else { return }
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if granted { self.beginAudio() }
                else { self.message = "请在系统设置中允许麦克风访问" }
            }
        }
    }

    private func beginAudio() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default,
                                    options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
            engine = AVAudioEngine()
            pitch = AVAudioUnitTimePitch()
            pitch.pitch = pitchSemitones * 100
            engine.attach(pitch)
            let input = engine.inputNode
            let inputFormat = input.outputFormat(forBus: 0)
            engine.connect(input, to: pitch, format: inputFormat)
            engine.connect(pitch, to: engine.mainMixerNode, format: nil)
            engine.prepare()
            try engine.start()
            running = true
            message = "实时试听已开启。请使用耳机防止啸叫。"
        } catch {
            message = "音频启动失败：\(error.localizedDescription)"
            stop()
        }
    }

    func startRecording() {
        guard running, !recording else { return }
        do {
            let mixer = engine.mainMixerNode
            let format = mixer.outputFormat(forBus: 0)
            guard format.sampleRate > 0 else { message = "无有效音频格式"; return }
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("Jialan-demo-\(UUID().uuidString).caf")
            let outputFile = try AVAudioFile(forWriting: url, settings: format.settings)
            file = outputFile
            mixer.installTap(onBus: 0, bufferSize: 2048, format: format) { [weak self] buffer, _ in
                do { try outputFile.write(from: buffer) }
                catch { DispatchQueue.main.async { self?.message = "录制写入失败：\(error.localizedDescription)" } }
            }
            lastRecording = url
            recording = true
            message = "正在录制（CAF 音频文件）"
        } catch {
            message = "录制失败：\(error.localizedDescription)"
        }
    }

    func stopRecording() {
        guard recording else { return }
        engine.mainMixerNode.removeTap(onBus: 0)
        file = nil
        recording = false
        message = "录制完成，可分享音频文件"
    }

    func stop() {
        stopRecording()
        if engine.isRunning { engine.stop() }
        engine.reset()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        running = false
        message = "已停止"
    }
}
