import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var integrals = loadIntegrals()
    @State private var inputAnswer = "|" // Starta med markör
    @State private var hasSolvedToday = false
    
    // För fel svar animation:
    @State private var isError = false
    @State private var shakeOffset: CGFloat = 0
    
    // För poängsystemet
    @State private var totalScore = UserDefaults.standard.integer(forKey: "total_score")
    @State private var hasFailedCurrentTask = false // Håller koll på om man gjort fel på just denna fråga
    
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
    var levelNumber: Int {
        if totalScore < 50 { return 1 }
        else if totalScore < 150 { return 2 }
        else if totalScore < 300 { return 3 }
        else { return 4 }
    }

    var body: some View {
        VStack(spacing: 0) {
            if hasSolvedToday {
                successView
            } else if let task = dailyTask {
                // Lägg in detta högst upp i din huvud-VStack (i ContentView)
                HStack {
                    // Poäng-sektionen
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Poäng: \(totalScore)")
                            .font(.system(.title3, design: .rounded))
                            .bold()
                    }
                    
                    Spacer() // Trycker isär poäng och level
                    
                    // Level-sektionen
                    HStack(spacing: 5) {
                        Image(systemName: "bolt.fill") // Bytte till blixt för att skilja dem åt visuellt
                            .foregroundColor(.orange)
                        Text("Level: \(levelNumber)")
                            .font(.system(.title3, design: .rounded))
                            .bold()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
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
                            // Vi renderar markören som ett streck för användaren
                            let displayLatex = inputAnswer
                                .replacingOccurrences(of: "|", with: "\\color{black}{|}")
                            
                            MathView(latex: displayLatex)
                                .frame(height: 80)
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isError ? Color.red : Color.blue, lineWidth: 2)
                        )
                        .offset(x: shakeOffset)
                    }
                    .padding(.horizontal)
                    
                    // Kontrollera
                    Button(action: {
                        // 1. Ta bort markören
                            let noCursor = inputAnswer.replacingOccurrences(of: "|", with: "")
                            
                            // 2. Ta bort ALLA mellanslag från användarens svar
                            let userFinal = noCursor.replacingOccurrences(of: " ", with: "")
                            
                            // 3. Ta bort ALLA mellanslag från det rätta svaret i JSON
                            let correctFinal = task.answer.replacingOccurrences(of: " ", with: "")
                        
                        if userFinal == correctFinal {
                            updateScore()
                            completeTask()
                        } else{
                            hasFailedCurrentTask = true
                            triggerErrorFeedback()
                        }
                    }) {
                        Text("Kontrollera svar")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(inputAnswer == "|" ? Color.gray : Color.gray)
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
    func triggerErrorFeedback() {
        // 1. Ändra färg till röd
        withAnimation(.default) {
            isError = true
        }
        
        // 2. Skapa en "haptisk" vibration (fysisk skakning i mobilen)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        // 3. Skak-animation (vänster-höger)
        withAnimation(.spring(response: 0.2, dampingFraction: 0.2, blendDuration: 0.2)) {
            shakeOffset = -10
        }
        
        // Återställ position och färg efter en kort stund
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.default) {
                shakeOffset = 0
                isError = false
            }
        }
    }
    func updateScore() {
        if !hasFailedCurrentTask {
            // Rätt på första försöket!
            totalScore += 10
        }
        else {
            // Fel svar
            totalScore -= 5
            hasFailedCurrentTask = true
            UserDefaults.standard.set(totalScore, forKey: "total_score")
        }
    }
}

#Preview {
    ContentView()
}
