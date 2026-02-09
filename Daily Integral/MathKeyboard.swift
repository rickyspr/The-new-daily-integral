import SwiftUI

struct MathKeyboard: View {
    @Binding var text: String
    
    // Uppdaterad layout för att rymma x, C och ln
    let rows = [
        ["7", "8", "9", "ln"],
        ["4", "5", "6", "/"],
        ["1", "2", "3", "+"],
        ["0", ".", "x", "-"],
        ["^", "C", "(", ")"] // 'C' här är nu bokstaven C för konstanten
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            // Navigationsrad
            HStack(spacing: 8) {
                navButton(label: "chevron.left") { moveCursor(left: true) }
                navButton(label: "chevron.right") { moveCursor(left: false) }
                // Vi lägger till en dedikerad "Rensa allt"-knapp här uppe istället
                navButton(label: "trash", isDelete: true) { text = "|" }
                navButton(label: "delete.left", isDelete: true) { deleteAtCursor() }
            }
            .frame(height: 50)
            
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

    func handleInput(_ char: String) {
        if char == "ln" {
            insertAtCursor("\\ln(|)")
        } else if char == "^" {
            insertAtCursor("^{|}")
        } else if char == "/" {
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
            if newContent.contains("|") {
                text.replaceSubrange(range, with: newContent)
            } else {
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
        newPos = max(0, min(tempText.count, newPos))
        
        // Uppdaterad lista för att inkludera 'l' och 'n' som strukturtecken
        let structuralChars: Set<Character> = ["{", "}", "\\", "f", "r", "a", "c", "^", "l", "n"]
        
        if left {
            while newPos > 0 && structuralChars.contains(tempText[tempText.index(tempText.startIndex, offsetBy: newPos)]) {
                newPos -= 1
            }
        } else {
            while newPos < tempText.count && structuralChars.contains(tempText[tempText.index(tempText.startIndex, offsetBy: newPos - 1)]) {
                newPos += 1
            }
        }
        
        newPos = max(0, min(tempText.count, newPos))
        let insertIdx = tempText.index(tempText.startIndex, offsetBy: newPos)
        tempText.insert("|", at: insertIdx)
        text = tempText
    }

    func deleteAtCursor() {
        guard let cursorIndex = text.firstIndex(of: "|"), cursorIndex != text.startIndex else { return }
        let indexBefore = text.index(before: cursorIndex)
        
        // Om vi raderar precis efter 'n' i '\ln', radera hela '\ln'
        if text.prefix(upTo: cursorIndex).hasSuffix("\\ln") {
            let startOfLn = text.index(indexBefore, offsetBy: -2)
            text.removeSubrange(startOfLn..<cursorIndex)
        } else {
            text.remove(at: indexBefore)
        }
        
        if !text.contains("|") { text = "|" }
    }
}
