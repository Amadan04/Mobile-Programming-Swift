import SwiftUI

struct ContentView: View {
    @State private var submittedWords: [String] = []
    @State private var currentWord = ""
    @State private var playerInput = ""
    @State private var playerScore = 0

    @State private var alertHeading = ""
    @State private var alertBody = ""
    @State private var alertVisible = false

    var body: some View {
        NavigationStack {
            List {
                Section("Your word") {
                    TextField("Type a word…", text: $playerInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Score: \(playerScore)") {
                    ForEach(submittedWords, id: \.self) { word in
                        HStack(spacing: 12) {
                            Image(systemName: "\(word.count).circle.fill")
                                .foregroundStyle(.blue)
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(currentWord)
            .toolbar {
                Button("New Game", action: loadGame)
            }
            .onSubmit(submitWord)
            .onAppear(perform: loadGame)
            .alert(alertHeading, isPresented: $alertVisible) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertBody)
            }
        }
    }

    func loadGame() {
        guard let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt"),
              let fileContents = try? String(contentsOf: fileURL) else {
            fatalError("Could not load start.txt from the app bundle.")
        }

        let wordBank = fileContents.components(separatedBy: "\n").filter { !$0.isEmpty }
        currentWord = wordBank.randomElement() ?? "birthday"
        submittedWords.removeAll()
        playerScore = 0
    }

    func submitWord() {
        let candidate = playerInput.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        playerInput = ""

        guard candidate.count >= 3 else {
            showAlert(heading: "Too short", body: "Words must be at least 3 letters long.")
            return
        }

        guard candidate != currentWord else {
            showAlert(heading: "Nice try!", body: "You can't just use the root word itself.")
            return
        }

        guard checkIfUnique(candidate) else {
            showAlert(heading: "Already used", body: "You've already submitted '\(candidate)'.")
            return
        }

        guard checkIfFormable(candidate) else {
            showAlert(heading: "Not possible", body: "'\(candidate)' can't be spelled from '\(currentWord)'.")
            return
        }

        guard checkIfValid(candidate) else {
            showAlert(heading: "Unknown word", body: "'\(candidate)' doesn't appear in the dictionary.")
            return
        }

        withAnimation {
            submittedWords.insert(candidate, at: 0)
            playerScore += candidate.count
        }
    }

    func checkIfUnique(_ word: String) -> Bool {
        !submittedWords.contains(word)
    }

    func checkIfFormable(_ word: String) -> Bool {
        var available = currentWord
        for letter in word {
            if let idx = available.firstIndex(of: letter) {
                available.remove(at: idx)
            } else {
                return false
            }
        }
        return true
    }

    func checkIfValid(_ word: String) -> Bool {
        let spellChecker = UITextChecker()
        let fullRange = NSRange(location: 0, length: word.utf16.count)
        let badRange = spellChecker.rangeOfMisspelledWord(
            in: word,
            range: fullRange,
            startingAt: 0,
            wrap: false,
            language: "en"
        )
        return badRange.location == NSNotFound
    }

    func showAlert(heading: String, body: String) {
        alertHeading = heading
        alertBody = body
        alertVisible = true
    }
}

#Preview {
    ContentView()
}
