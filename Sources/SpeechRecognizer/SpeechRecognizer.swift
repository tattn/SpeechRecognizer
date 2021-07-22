import Foundation
import Speech
import NaturalLanguage

final class SpeechRecognizer {
    private var speechRecognizer: SFSpeechRecognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    let url: URL
    
    init(url: URL, locale: Locale = .current) {
        self.url = url
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)!
    }
    
    func startRecognize(completion: @escaping (Result<String, Error>) -> Void) {
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        guard authStatus == .authorized else {
            if authStatus == .notDetermined {
                SFSpeechRecognizer.requestAuthorization { [weak self] status in
                    if status == .authorized {
                        self?.recognize(completion: completion)
                    } else {
                        completion(.failure(SpeechRecognizerErrors.authenticationFailed))
                    }
                }
            } else {
                completion(.failure(SpeechRecognizerErrors.authenticationFailed))
            }
            return
        }
        
        guard recognitionTask == nil, self.recognitionRequest == nil else {
            stopRecognize()
            recognize(completion: completion)
            return
        }

        recognize(completion: completion)
    }
    
    private func recognize(completion: @escaping (Result<String, Error>) -> Void) {
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest = recognitionRequest
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = true

        speechRecognizer.queue = OperationQueue()
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.stopRecognize()
                completion(.failure(error))
                return
            }
            guard let result = result else {
                completion(.failure(SpeechRecognizerErrors.unknown))
                return
            }
            
            if result.isFinal {
                self.stopRecognize()
                completion(.success(result.bestTranscription.formattedString))
            }
        }
        
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let frameCount = AVAudioFrameCount(audioFile.length)
            if let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCount) {
                try audioFile.read(into: pcmBuffer)
                recognitionRequest.append(pcmBuffer)
                recognitionRequest.endAudio()
            } else {
                throw SpeechRecognizerErrors.invalidAudioFormat
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func stopRecognize() {
        recognitionTask?.cancel()
        recognitionTask?.finish()
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
    }
}
