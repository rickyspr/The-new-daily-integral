import SwiftUI

struct MathKeyboard: View {
    @Binding var text: String
    
    // Optimerad layout för att spara vertikalt utrymme
    let rows = [
        ["sin", "cos", "tan", "arctan", "/"],
        ["7", "8", "9", "x", "ln"],
        ["4", "5", "6", "-", "("],
        ["1", "2", "3", "+", ")"],
        ["0", ".", "x", "c", "^"], // Här är c tillbaka bredvid x
        ["e", "->|"] // e och Tab på bottenraden
    ]
    
    var body: some View {
        VStack(spacing: 4) {
            // Navigationsrad - Här ligger nu även "Clear All" (trash)
            HStack(spacing: 6) {
                navButton(label: "chevron.left") { moveCursor(left: true) }
                navButton(label: "chevron.right") { moveCursor(left: false) }
                navButton(label: "trash", isDelete: true) { text = "|" }
                navButton(label: "delete.left", isDelete: true) { deleteAtCursor() }
            }
            .frame(height: 38)
            
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { char in
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            handleInput(char)
                        }) {
                            Text(char == "->|" ? "⇥" : char)
                                .font(.system(size: char.count > 3 ? 12 : 16, weight: .bold))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(isFunction(char) ? Color.blue.opacity(0.1) : Color.white)
                                .foregroundColor(isFunction(char) ? .blue : .black)
                                .cornerRadius(6)
                                .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
                        }
                    }
                }
                .frame(height: 34) // Mycket lägre rader för att se resten av skärmen
            }
        }
        .padding(6)
        .background(Color.black.opacity(0.05))
    }
    
    func isFunction(_ char: String) -> Bool {
        return ["sin", "cos", "tan", "arctan", "ln", "/", "^", "->|", "(", ")"].contains(char)
    }

    func navButton(label: String, isDelete: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: label)
                .font(.subheadline).bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isDelete ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                .foregroundColor(isDelete ? .orange : .black)
                .cornerRadius(6)
        }
    }

    func handleInput(_ char: String) {
        switch char {
        case "sin", "cos", "tan", "arctan":
            insertAtCursor("\\\(char)(|)")
        case "ln":
            insertAtCursor("\\ln(|)")
        case "×":
            insertAtCursor("*")
        case "^":
            insertAtCursor("^{|}")
        case "/":
            if let range = text.range(of: "|") {
                text.replaceSubrange(range, with: "\\frac{|}{ }")
            }
        case "->|":
            jumpOut()
        case "c": // Hantera c som bokstaven C
            insertAtCursor("C")
        default:
            insertAtCursor(char)
        }
    }

    // ... Behåll jumpOut, moveCursor och deleteAtCursor från tidigare ...
    func insertAtCursor(_ newContent: String) {
        if let range = text.range(of: "|") {
            text.replaceSubrange(range, with: newContent.contains("|") ? newContent : newContent + "|")
        }
    }

    func jumpOut() {
        guard let cursorIndex = text.firstIndex(of: "|") else { return }
        let afterCursor = text.suffix(from: text.index(after: cursorIndex))
        if let nextStop = afterCursor.firstIndex(where: { $0 == "}" || $0 == ")" }) {
            var tempText = text
            tempText.remove(at: cursorIndex)
            let newPos = tempText.index(after: tempText.index(before: nextStop))
            tempText.insert("|", at: newPos)
            text = tempText
        } else {
            text = text.replacingOccurrences(of: "|", with: "") + "|"
        }
    }
    
    func deleteAtCursor() {
        guard let cursorIndex = text.firstIndex(of: "|"), cursorIndex != text.startIndex else { return }
        let indexBefore = text.index(before: cursorIndex)
        text.remove(at: indexBefore)
        if !text.contains("|") { text = "|" }
    }
    
    func moveCursor(left: Bool) {
        guard let cursorIndex = text.firstIndex(of: "|") else { return }
        var tempText = text
        tempText.remove(at: cursorIndex)
        let currentPos = text.distance(from: text.startIndex, to: cursorIndex)
        var newPos = left ? currentPos - 1 : currentPos + 1
        newPos = max(0, min(tempText.count, newPos))
        let insertIdx = tempText.index(tempText.startIndex, offsetBy: newPos)
        tempText.insert("|", at: insertIdx)
        text = tempText
    }
}
