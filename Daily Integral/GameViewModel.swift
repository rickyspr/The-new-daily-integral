import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    // --- Published properties (UI lyssnar på dessa) ---
    @Published var integrals: [Integral] = []
    @Published var currentTask: Integral?
    @Published var inputAnswer: String = "|"
    @Published var hasSolvedToday: Bool = false
    @Published var totalScore: Int = UserDefaults.standard.integer(forKey: "total_score")
    @Published var levelNumber: Int = 1
    
    // UI-feedback state
    @Published var isError: Bool = false
    @Published var shakeOffset: CGFloat = 0
    
    // --- Init ---
    init() {
        self.updateLevel()
        self.loadDailyTask()
    }
    
    // --- Computed Properties ---
    private var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "solved_\(formatter.string(from: Date()))"
    }
    
    // --- Logic ---
    
    func loadDailyTask() {
        // Uppdatera hasSolvedToday från minnet
        hasSolvedToday = UserDefaults.standard.bool(forKey: dayKey)
        
        // Ladda rätt nivå
        updateLevel()
        integrals = IntegralService.loadIntegrals(for: levelNumber)
        
        // Välj dagens uppgift
        if !integrals.isEmpty {
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
            currentTask = integrals[dayOfYear % integrals.count]
        }
    }
    
    func checkAnswer() {
        guard let task = currentTask else { return }
        
        // Normalisera strängar för jämförelse
        let userFinal = simplifyLatex(inputAnswer)
        let correctFinal = simplifyLatex(task.answer)
        
        print("DEBUG: User: '\(userFinal)' vs Correct: '\(correctFinal)'")
        
        if userFinal == correctFinal {
            handleSuccess()
        } else {
            handleFailure()
        }
    }
    
    private func handleSuccess() {
        totalScore += 50
        
        UserDefaults.standard.set(totalScore, forKey: "total_score")
        UserDefaults.standard.set(true, forKey: dayKey)
        
        // Uppdatera nivå baserat på nya poängen
        updateLevel()
        
        withAnimation(.spring()) {
            hasSolvedToday = true
        }
    }
    
    private func handleFailure() {
        totalScore -= 5
        UserDefaults.standard.set(totalScore, forKey: "total_score")
        triggerErrorFeedback()
        updateLevel() // Om poängen sjunker kanske man tappar en level
    }
    
    private func updateLevel() {
        if totalScore < 50 { levelNumber = 1 }
        else if totalScore < 150 { levelNumber = 2 }
        else if totalScore < 300 { levelNumber = 3 }
        else { levelNumber = 4 }
    }
    
    private func simplifyLatex(_ input: String) -> String {
        return input
            .replacingOccurrences(of: "|", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\\,", with: "")
            .replacingOccurrences(of: "\\frac", with: "")
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: "*", with: "")
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // --- UI Feedback ---
    
    func triggerErrorFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        withAnimation(.default) { isError = true }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.2, blendDuration: 0.2)) {
            shakeOffset = -10
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                self.shakeOffset = 0
                self.isError = false
            }
        }
    }
    
    // Dev tool
    func resetProgress() {
        UserDefaults.standard.removeObject(forKey: dayKey)
        UserDefaults.standard.set(0, forKey: "total_score")
        hasSolvedToday = false
        inputAnswer = "|"
        loadDailyTask()
    }
}
