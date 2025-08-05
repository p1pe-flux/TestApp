//
//  WeightInputFormatter.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 4/8/25.
//

import Foundation

struct WeightInputFormatter {
    /// Convierte el texto de entrada a Double, soportando tanto punto como coma
    static func parseWeight(_ text: String) -> Double? {
        let normalizedText = text.replacingOccurrences(of: ",", with: ".")
        return Double(normalizedText)
    }
    
    /// Formatea un Double para mostrar, usando el separador decimal del locale
    static func formatWeight(_ weight: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        
        // Si el peso es entero, no mostrar decimales
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0
        }
        
        return formatter.string(from: NSNumber(value: weight)) ?? String(format: "%.2f", weight)
    }
    
    /// Formatea el peso para entrada en TextField
    static func formatForInput(_ weight: Double) -> String {
        if weight == 0 { return "" }
        
        // Usar punto como separador para la entrada
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            // Eliminar ceros finales
            let formatted = String(format: "%.2f", weight)
            return formatted.replacingOccurrences(of: "\\.?0+$", with: "", options: .regularExpression)
        }
    }
    
    /// Valida que el texto sea una entrada válida para peso
    static func isValidWeightInput(_ text: String) -> Bool {
        // Permitir vacío
        if text.isEmpty { return true }
        
        // Reemplazar coma por punto para validación
        let normalizedText = text.replacingOccurrences(of: ",", with: ".")
        
        // Verificar que solo contenga números y máximo un punto
        let components = normalizedText.components(separatedBy: ".")
        if components.count > 2 { return false }
        
        // Verificar que cada componente sea numérico
        for component in components {
            if !component.isEmpty && !component.allSatisfy({ $0.isNumber }) {
                return false
            }
        }
        
        return true
    }
    
    /// Limpia la entrada de texto para peso
    static func sanitizeWeightInput(_ text: String) -> String {
        // Mantener solo números, punto y coma
        let allowedCharacters = "0123456789.,"
        var filtered = text.filter { allowedCharacters.contains($0) }
        
        // Asegurar solo un separador decimal
        var foundSeparator = false
        filtered = String(filtered.compactMap { char in
            if char == "." || char == "," {
                if foundSeparator {
                    return nil
                } else {
                    foundSeparator = true
                    return char
                }
            }
            return char
        })
        
        return filtered
    }
}
