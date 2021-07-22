import Foundation
import ArgumentParser

struct SpeechRecognizerApp: ParsableCommand {
    
    @Argument(help: "path of the file to be recognized by speech")
    var filePath: String
    
    @Option(name: [.customShort("l"), .long], help: "Locale for recognition")
    var locale: String = Locale.current.identifier
    
    static var configuration = CommandConfiguration(
        commandName: "speechrecognizer",
        abstract: "Recognize speech",
        discussion: """
        Recognize speech
        """,
        version: "1.0.0",
        shouldDisplay: true,
        //subcommands: <#T##[ParsableCommand.Type]#>,
        //defaultSubcommand: <#T##ParsableCommand.Type?#>,
        helpNames: [.long, .short]
    )

    func run() throws {
        guard let url = URL(string: filePath) else {
            throw SpeechRecognizerErrors.invalidUrl
        }
        
        var output: String?
        
        let recognizer = SpeechRecognizer(url: url, locale: Locale(identifier: locale))
        recognizer.startRecognize { result in
            output = (try? result.get()) ?? ""
        }

        while output == nil {
            RunLoop.main.run(mode: .default, before: Date() + 1)
        }
        print(output ?? "")
    }
}

SpeechRecognizerApp.main()
//SpeechRecognizerApp.main(["--help"])
