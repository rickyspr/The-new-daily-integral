import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var integrals = loadIntegrals()
    @State private var inputAnswer = "|" // Starta med markör
    @State private var hasSolvedToday = false
    
    var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "solved_\(formatter.string(from: Date()))"
    }

    var dailyTask: Integral? {
        guard !integrals.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return integrals[dayOfYear % integrals.count]
    }

    var body: some View {
        VStack(spacing: 0) {
            if hasSolvedToday {
                successView
            } else if let task = dailyTask {
                VStack(spacing: 20) {
                    Text("The Daily Integral")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .padding(.top, 20)
                    
                    // Fråga
                    VStack(spacing: 10) {
                        Text("Dagens utmaning:")
                            .font(.subheadline).foregroundColor(.secondary)
                        MathView(latex: task.question)
                            .frame(height: 100)
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Inmatningsfält
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Ditt svar:")
                            .font(.caption).foregroundColor(.secondary)
                        
                        HStack {
                            // Vi renderar markören som ett blått streck för användaren
                            let displayLatex = inputAnswer
                                .replacingOccurrences(of: "|", with: "\\color{blue}{|}")
                            
                            MathView(latex: displayLatex)
                                .frame(height: 80)
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.blue, lineWidth: 2))
                    }
                    .padding(.horizontal)
                    
                    // Kontrollera
                    Button(action: {
                        let cleanAnswer = inputAnswer.replacingOccurrences(of: "|", with: "").trimmingCharacters(in: .whitespaces)
                        if cleanAnswer == task.answer {
                            completeTask()
                        }
                    }) {
                        Text("Kontrollera svar")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(inputAnswer == "|" ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(inputAnswer == "|")
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    MathKeyboard(text: $inputAnswer)
                }
            }
        }
        .onAppear {
            hasSolvedToday = UserDefaults.standard.bool(forKey: dayKey)
        }
    }
    
    var successView: some View {
        VStack(spacing: 25) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 100)).foregroundColor(.green)
            Text("Utmärkt!").font(.largeTitle).bold()
            
            Button("Nollställ (Dev)") {
                UserDefaults.standard.removeObject(forKey: dayKey)
                hasSolvedToday = false
                inputAnswer = "|"
            }
            .padding().foregroundColor(.red)
            Spacer()
        }
    }

    func completeTask() {
        UserDefaults.standard.set(true, forKey: dayKey)
        withAnimation(.spring()) { hasSolvedToday = true }
    }
}

#Preview {
    ContentView()
}
