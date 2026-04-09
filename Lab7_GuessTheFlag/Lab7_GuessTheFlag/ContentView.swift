import SwiftUI

// Guess the Flag – a flag-guessing game following the Hacking with Swift tutorial (steps 1–9)
// The app shows three random flags and asks the user to tap the correct one.

// MARK: – FlagImage helper view

/// Renders a flag image with the capsule clip shape and shadow used throughout the game.
struct FlagImage: View {
    let country: String

    var body: some View {
        Image(country)
            .clipShape(.capsule)
            .shadow(radius: 5)
    }
}

// MARK: – ContentView

struct ContentView: View {
    // MARK: – State

    /// Pool of country names; shuffled at the start and after every question
    @State private var countries = [
        "Estonia", "France", "Germany", "Ireland", "Italy",
        "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"
    ].shuffled()

    /// Index (0, 1, or 2) of the correct flag among the three shown
    @State private var correctAnswer = Int.random(in: 0 ... 2)

    /// Controls whether the score alert is visible
    @State private var showingScore = false

    /// Headline shown inside the alert ("Correct" or "Wrong! That's…")
    @State private var alertTitle = ""

    /// Message body shown inside the alert
    @State private var alertMessage = ""

    /// Player's running score
    @State private var score = 0

    /// Round counter (game ends after 8 rounds)
    @State private var roundsPlayed = 0

    /// Controls the "Game Over" alert shown after 8 rounds
    @State private var gameOver = false

    // MARK: – Body

    var body: some View {
        ZStack {
            // ── Background gradient ────────────────────────────────────────
            RadialGradient(
                stops: [
                    .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                    .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3),
                ],
                center: .top,
                startRadius: 200,
                endRadius: 700
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                // App title
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                // ── Game card ─────────────────────────────────────────────
                VStack(spacing: 15) {
                    // Instruction text
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))

                        // Name of the country to find
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }

                    // Three flag buttons
                    ForEach(0 ..< 3) { index in
                        Button {
                            flagTapped(index)
                        } label: {
                            FlagImage(country: countries[index])
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))

                Spacer()
                Spacer()

                // Score display
                Text("Score: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())

                Spacer()
            }
            .padding()
        }
        // ── Result alert ─────────────────────────────────────────────────
        .alert(alertTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text(alertMessage)
        }
        // ── Game-over alert ───────────────────────────────────────────────
        .alert("Game Over", isPresented: $gameOver) {
            Button("Play Again", action: resetGame)
        } message: {
            Text("You finished with a score of \(score) out of 8.")
        }
    }

    // MARK: – Game logic

    /// Called when the user taps one of the three flag buttons.
    func flagTapped(_ number: Int) {
        roundsPlayed += 1

        if number == correctAnswer {
            alertTitle = "Correct!"
            score += 1
            alertMessage = "Your score is \(score)."
        } else {
            alertTitle = "Wrong!"
            alertMessage = "That's the flag of \(countries[number]).\nYour score is \(score)."
        }

        // After 8 rounds show the game-over alert instead of the round alert
        if roundsPlayed == 8 {
            gameOver = true
        } else {
            showingScore = true
        }
    }

    /// Shuffles the country list and picks a new correct answer.
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0 ... 2)
    }

    /// Resets all state to start a fresh game.
    func resetGame() {
        score = 0
        roundsPlayed = 0
        askQuestion()
    }
}

// MARK: – Preview

#Preview {
    ContentView()
}
