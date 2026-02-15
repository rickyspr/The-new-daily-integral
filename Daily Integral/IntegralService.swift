import Foundation

struct IntegralService {
    static func loadIntegrals(for level: Int) -> [Integral] {
        let fileName: String
        switch level {
        case 1: fileName = "integrals"
        case 2: fileName = "integralsLevel2"
        case 3: fileName = "integralsLevel3"
        default: fileName = "integrals"
        }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Kunde inte hitta filen: \(fileName).json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([Integral].self, from: data)
        } catch {
            print("Kunde inte läsa JSON: \(error)")
            return []
        }
    }
}
