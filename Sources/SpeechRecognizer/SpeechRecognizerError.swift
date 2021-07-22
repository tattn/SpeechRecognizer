import Foundation

enum SpeechRecognizerErrors: LocalizedError {
    case invalidUrl
    case authenticationFailed
    case invalidAudioFormat
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "Invalid URL"
        case .authenticationFailed:
            return "Authentication failed"
        case .invalidAudioFormat:
            return "The format of the audio is not in PCM"
        case .unknown:
            return "Unknown"
        }
    }
}
