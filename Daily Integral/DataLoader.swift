import Foundation

func loadIntegrals(for level: Int) -> [Integral] {
    // 1. Hitta filen i app-paketet
    
    let fileName: String
    switch level {
        case 1:
            fileName = "integrals"
        case 2:
            fileName = "integralsLevel2"
        case 3:
            fileName = "integralsLevel3"
        default:
            fileName = "integrals" // Standardfall
        }
        
        // 2. Hitta filen baserat på namnet vi valde
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Kunde inte hitta filen: \(fileName).json")
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
