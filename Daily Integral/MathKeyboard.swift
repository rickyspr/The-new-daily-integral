import SwiftUI

struct MathKeyboard: View {
    @Binding var text: String
    
    // Layout baserad på din bild
    let rows = [
        ["7", "8", "9", "×"],
        ["4", "5", "6", "/"],
        ["1", "2", "3", "+"],
        ["0", ".", "x", "-"],
        ["^", "(", ")", "C"]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            // Navigationsrad
            HStack(spacing: 8) {
                navButton(label: "chevron.left") { moveCursor(left: true) }
                navButton(label: "chevron.right") { moveCursor(left: false) }
                navButton(label: "delete.left", isDelete: true) { deleteAtCursor() }
            }
            .frame(height: 50)
            
            // Knappsats
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { char in
                        Button(action: { handleInput(char) }) {
                            Text(char)
                                .font(.title2).bold()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                                .shadow(radius: 1, y: 1)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.05))
        .onAppear {
            if text.isEmpty { text = "|" }
        }
    }
    
    // Hjälpvy för nav-knappar
    func navButton(label: String, isDelete: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: label)
                .font(.title2).bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isDelete ? Color.orange.opacity(0.2) : Color.gray.opacity(0.2))
                .foregroundColor(isDelete ? .orange : .black)
                .cornerRadius(8)
        }
    }

    // --- LOGIK ---

    func handleInput(_ char: String) {
        if char == "C" {
            text = "|"
        } else if char == "×" {
            insertAtCursor("*")
        } else if char == "÷" {
            insertAtCursor("/")
        } else if char == "^" {
            insertAtCursor("^{|}")
        } else if char == "/" {
            // Bråk-logik: Om vi redan har text, sätt den i täljaren
            if text == "|" {
                text = "\\frac{|}{ }"
            } else {
                let current = text.replacingOccurrences(of: "|", with: "")
                text = "\\frac{\(current)|}{ }"
            }
        } else {
            insertAtCursor(char)
        }
    }

    func insertAtCursor(_ newContent: String) {
        if let range = text.range(of: "|") {
            // Om vi infogar en struktur med en egen markör (som ^{|}),
            // ersätter vi den gamla markören helt.
            if newContent.contains("|") {
                text.replaceSubrange(range, with: newContent)
            } else {
                // Annars lägger vi till tecknet och behåller markören till höger
                text.replaceSubrange(range, with: newContent + "|")
            }
        }
    }

    func moveCursor(left: Bool) {
        guard let cursorIndex = text.firstIndex(of: "|") else { return }
        var tempText = text
        tempText.remove(at: cursorIndex)
        
        let currentPos = text.distance(from: text.startIndex, to: cursorIndex)
        var newPos = left ? currentPos - 1 : currentPos + 1
        
        // Gränskontroll
        newPos = max(0, min(tempText.count, newPos))
        
        // SMART HOPP: Om vi landar på tecken som tillhör LaTeX-strukturen, hoppa över dem
        let structuralChars: Set<Character> = ["{", "}", "\\", "f", "r", "a", "c", "^"]
        
        if left {
            // Om vi går till vänster, fortsätta backa tills vi hittar ett "skrivbart" tecken eller början
            while newPos > 0 && structuralChars.contains(tempText[tempText.index(tempText.startIndex, offsetBy: newPos)]) {
                newPos -= 1
            }
        } else {
            // Om vi går till höger, fortsätt framåt tills vi landar efter en struktur
            while newPos < tempText.count && structuralChars.contains(tempText[tempText.index(tempText.startIndex, offsetBy: newPos - 1)]) {
                newPos += 1
            }
        }
        
        // Säkerställ att newPos fortfarande är inom ramarna efter hoppen
        newPos = max(0, min(tempText.count, newPos))
        
        let insertIdx = tempText.index(tempText.startIndex, offsetBy: newPos)
        tempText.insert("|", at: insertIdx)
        text = tempText
    }

    func deleteAtCursor() {
        guard let cursorIndex = text.firstIndex(of: "|"), cursorIndex != text.startIndex else { return }
        let indexBefore = text.index(before: cursorIndex)
        text.remove(at: indexBefore)
    }
}
