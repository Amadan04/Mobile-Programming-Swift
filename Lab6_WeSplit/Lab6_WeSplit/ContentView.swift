import SwiftUI

// WeSplit - A check-splitting app following the Hacking with Swift tutorial (steps 1–11)
// The app lets a group of diners split a restaurant bill and tip evenly.

struct ContentView: View {
    // MARK: – State

    /// The total bill amount entered by the user
    @State private var checkAmount = 0.0

    /// Index into the people picker (0 = 2 people, 1 = 3 people, …)
    @State private var numberOfPeople = 2

    /// Tip percentage chosen from the segmented picker
    @State private var tipPercentage = 20

    /// Controls keyboard dismissal via the toolbar Done button
    @FocusState private var amountIsFocused: Bool

    // MARK: – Constants

    /// Tip percentage options shown in the segmented control
    let tipPercentages = [10, 15, 20, 25, 0]

    // MARK: – Computed values

    /// Grand total including the selected tip
    var grandTotal: Double {
        let tipValue = checkAmount / 100 * Double(tipPercentage)
        return checkAmount + tipValue
    }

    /// Amount each person owes (grand total divided by head count)
    var totalPerPerson: Double {
        // numberOfPeople picker starts at 0 = "2 people", so add 2
        let headCount = Double(numberOfPeople + 2)
        return grandTotal / headCount
    }

    // MARK: – Body

    var body: some View {
        NavigationStack {
            Form {
                // ── Section 1: Bill amount + number of people ──────────────
                Section {
                    // Currency text field bound to checkAmount
                    TextField(
                        "Amount",
                        value: $checkAmount,
                        format: .currency(code: Locale.current.currency?.identifier ?? "USD")
                    )
                    .keyboardType(.decimalPad)
                    .focused($amountIsFocused)

                    // Wheel-style picker for number of people (2 – 99)
                    Picker("Number of people", selection: $numberOfPeople) {
                        ForEach(2 ..< 100) { count in
                            Text("\(count) people")
                        }
                    }
                    .pickerStyle(.wheel)
                }

                // ── Section 2: Tip percentage ──────────────────────────────
                Section("How much tip do you want to leave?") {
                    Picker("Tip percentage", selection: $tipPercentage) {
                        ForEach(tipPercentages, id: \.self) { percent in
                            Text(percent, format: .percent)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // ── Section 3: Grand total ─────────────────────────────────
                Section("Total amount for the check") {
                    Text(grandTotal, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        // Highlight in red when the user chose 0 % tip
                        .foregroundStyle(tipPercentage == 0 ? .red : .primary)
                }

                // ── Section 4: Amount per person ───────────────────────────
                Section("Amount per person") {
                    Text(totalPerPerson, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
            }
            .navigationTitle("WeSplit")
            // Toolbar Done button dismisses the decimal keyboard
            .toolbar {
                if amountIsFocused {
                    Button("Done") {
                        amountIsFocused = false
                    }
                }
            }
        }
    }
}

// MARK: – Preview

#Preview {
    ContentView()
}
