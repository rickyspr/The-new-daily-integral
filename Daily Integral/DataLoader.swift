import Foundation

func loadIntegrals() -> [Integral] {
    // 1. Hitta filen i app-paketet
    guard let url = Bundle.main.url(forResource: "integrals", withExtension: "json") else {
        return []
    }
    
    do {
        // 2. Läs rådatan
        let data = try Data(contentsOf: url)
        // 3. Avkoda JSON till en array av Integral-structs
        let decoder = JSONDecoder()
        return try decoder.decode([Integral].self, from: data)
    } catch {
        print("Kunde inte läsa JSON: \(error)")
        return []
    }
}
