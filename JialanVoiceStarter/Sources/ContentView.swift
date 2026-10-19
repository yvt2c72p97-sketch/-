import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var audio = AudioController()
    @State private var sharing = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("嘉岚3.0 · 声音实验台")
                    .font(.title2.bold())
                Text("本工程仅演示实时音频升调，尚未接入固定音色 AI 模型")
                    .font(.footnote).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                VStack(alignment: .leading) {
                    Text("音高调整：\(Int(audio.pitchSemitones)) 半音")
                    Slider(value: $audio.pitchSemitones, in: -5...9, step: 1)
                }
                .disabled(audio.recording)
                Button(audio.running ? "停止实时试听" : "开启实时试听") {
                    audio.running ? audio.stop() : audio.start()
                }
                .buttonStyle(.borderedProminent)
                Button(audio.recording ? "结束录制" : "开始录制") {
                    audio.recording ? audio.stopRecording() : audio.startRecording()
                }
                .disabled(!audio.running)
                .buttonStyle(.bordered)
                Button("分享最近录音") { sharing = true }
                    .disabled(audio.lastRecording == nil || audio.recording)
                Text(audio.message)
                    .font(.footnote).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            .navigationTitle("声音实验台")
            .sheet(isPresented: $sharing) {
                if let url = audio.lastRecording { ShareSheet(items: [url]) }
            }
            .onDisappear { audio.stop() }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
