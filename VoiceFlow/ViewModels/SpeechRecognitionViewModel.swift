import Foundation
import Speech
import AVFoundation
import Combine

@MainActor
class SpeechRecognitionViewModel: ObservableObject {
    @Published var isListening: Bool = false
    @Published var transcribedText: String = ""
    @Published var currentTranscription: String = ""
    @Published var errorMessage: String?
    @Published var isPermissionGranted: Bool = false
    @Published var availableMicrophones: [String] = []
    @Published var selectedMicrophone: String = ""

    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        checkPermissions()
        updateAvailableMicrophones()
    }

    func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                switch status {
                case .authorized:
                    self?.isPermissionGranted = true
                case .denied, .restricted, .notDetermined:
                    self?.isPermissionGranted = false
                @unknown default:
                    self?.isPermissionGranted = false
                }
            }
        }
    }

    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    private func updateAvailableMicrophones() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInMicrophone, .externalUnknown],
            mediaType: .audio,
            position: .unspecified
        )
        availableMicrophones = discoverySession.devices.map { $0.localizedName }
        selectedMicrophone = availableMicrophones.first ?? "Built-in Microphone"
    }

    func startListening() {
        guard isPermissionGranted else {
            errorMessage = "Speech recognition permission not granted"
            return
        }

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognizer not available"
            return
        }

        do {
            try startRecognition()
            isListening = true
            errorMessage = nil
        } catch {
            errorMessage = "Failed to start recognition: \(error.localizedDescription)"
        }
    }

    private func startRecognition() throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "SpeechRecognition", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.addsPunctuation = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                if let result = result {
                    self?.currentTranscription = result.bestTranscription.formattedString

                    if result.isFinal {
                        self?.transcribedText += self?.currentTranscription ?? ""
                        self?.currentTranscription = ""
                    }
                }

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.stopListening()
                }
            }
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
    }

    func clearTranscription() {
        transcribedText = ""
        currentTranscription = ""
    }
}
