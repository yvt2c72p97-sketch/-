# 嘉岚3.0 iOS 音频工程（可运行基础版，非 AI 复刻）

## 当前实现
- iOS 15+ SwiftUI 页面
- 本机麦克风实时音频处理与监听（AVAudioEngine + AVAudioUnitTimePitch）
- 实时音高调整、录制处理后的声音（CAF）、系统分享
- Resources/JialanReference.mp3：用户提供的参考音频，仅随工程保存；不参与当前 DSP 算法

**重要：升调 ≠ 音色转换。本工程当前不能将任何输入精确转换成嘉岚3.0，不能向微信等第三方 APP 提供虚拟麦克风，也不支持后台通话注入。**

## 如何构建
1. 需要 macOS 电脑以及 Xcode 来**编译与签名** iOS APP；完成安装后日常运行可以只用 iPhone。
2. 安装 XcodeGen（https://github.com/yonaskolb/XcodeGen），在此文件夹执行 `xcodegen generate`，得到 `.xcodeproj`。
3. 在 Xcode 打开工程，设置 Signing & Capabilities 的 Team 和唯一 Bundle Identifier。
4. 将 iPhone 连接 Mac 或使用 Xcode 支持的无线真机部署，Build & Run。
5. 首次运行时授予麦克风权限。建议戴耳机以防止回授啸叫。

## 下一步：接入真正固定声音模型
1. 获得目标音色使用权；准备更长、多种语句、无背景音乐的授权样本；对参考音频标注来源与许可。
2. 在电脑上完成训练/推理实验与导出（模型制作阶段需要电脑）；优先评估轻量级流式 voice conversion，检查高质量声音与延迟。
3. 使用 coremltools 或兼容推理后端转换模型，将内容特征、F0/韵律、说话人表示和声码器组合成可流式处理的离线管线。
4. 将 DSP 演示节点替换为独立的 `StreamingVoiceConverter` 模块；输入固定长度 PCM 块，输出连续 PCM 块。不得在实时音频回调执行阻塞推理；使用无锁环形缓冲及后台推理线程。
5. 测试每设备音频性能、耳机路由、来电中断、过载降级；导出成 AAC/m4a 增强分享兼容性。
6. 在自有 VoIP 应用内，在编码发送前插入转换音频。第三方 APP 不存在通用的虚拟麦克风接口；iOS 18.2 的 Add Audio in Calls 是叠加音频，而非替换麦克风。

## 验证条件
- Xcode 需要在 macOS 执行；本环境未执行 iOS 编译与真机测试。
- iPhone 13 或更旧机型的可行性必须依据具体型号、系统版本、模型延迟来判定。
- 只能在拥有目标音色合法使用授权且不冒充他人的情形下使用。
