//
//  BreakSuggestionService.swift
//  StudySpell
//
//  Created by Kripa Paudel on 04/08/2025.
//

import Foundation

// MARK: - Data Models
struct QuoteResponse: Codable {
    let quote: String
    let author: String
}

struct AdviceResponse: Codable {
    let slip: AdviceSlip
}

struct AdviceSlip: Codable {
    let id: Int
    let advice: String
}

struct CatFactResponse: Codable {
    let fact: String
}

// MARK: - Break Content
struct BreakContent {
    let suggestion: String
    let quote: String
    let funFact: String
}

class BreakSuggestionService {
    static let shared = BreakSuggestionService()
    
    private init() {}
    
    // MARK: - Break Suggestions
    private let breakSuggestions = [
        "🚶‍♂️ Take a 5-minute walk to refresh your mind",
        "💧 Drink a glass of water to stay hydrated",
        "🧘‍♀️ Do some deep breathing exercises",
        "👀 Look away from screens and focus on something distant",
        "🤸‍♀️ Do some light stretching exercises",
        "🎵 Listen to your favorite song",
        "🌱 Water your plants or step outside for fresh air",
        "☕ Make yourself a warm drink",
        "📱 Send a quick message to a friend or family member",
        "🧠 Do a quick brain teaser or puzzle"
    ]
    
    func getRandomBreakSuggestion() -> String {
        return breakSuggestions.randomElement() ?? "Take a short break and relax!"
    }
    
    // MARK: - API Calls
    
    func fetchBreakContent(completion: @escaping (Result<BreakContent, Error>) -> Void) {
        let group = DispatchGroup()
        
        var motivationalQuote = "\"Believe in yourself!\" - StudySpell"
        var funFact = "Did you know? Taking breaks improves focus and productivity!"
        let breakSuggestion = getRandomBreakSuggestion()
        
        // Fetch motivational quote
        group.enter()
        fetchMotivationalQuote { result in
            switch result {
            case .success(let quote):
                motivationalQuote = quote
            case .failure:
                // Keep default quote
                break
            }
            group.leave()
        }
        
        // Fetch fun fact
        group.enter()
        fetchRandomFunFact { result in
            switch result {
            case .success(let fact):
                funFact = fact
            case .failure:
                // Keep default fact
                break
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            let content = BreakContent(
                suggestion: breakSuggestion,
                quote: motivationalQuote,
                funFact: funFact
            )
            completion(.success(content))
        }
    }
    
    private func fetchMotivationalQuote(completion: @escaping (Result<String, Error>) -> Void) {
        // Using quotable.io API for motivational quotes
        guard let url = URL(string: "https://api.quotable.io/random?tags=motivational") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                let quoteData = try JSONDecoder().decode(QuoteResponse.self, from: data)
                let formattedQuote = "\"\(quoteData.quote)\" - \(quoteData.author)"
                completion(.success(formattedQuote))
            } catch {
                // Fallback to advice API
                self.fetchAdvice(completion: completion)
            }
        }
        
        task.resume()
    }
    
    private func fetchAdvice(completion: @escaping (Result<String, Error>) -> Void) {
        // Using adviceslip.com API as fallback
        guard let url = URL(string: "https://api.adviceslip.com/advice") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                let adviceData = try JSONDecoder().decode(AdviceResponse.self, from: data)
                completion(.success(adviceData.slip.advice))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func fetchRandomFunFact(completion: @escaping (Result<String, Error>) -> Void) {
        // Using cat-fact.herokuapp.com API for fun facts
        guard let url = URL(string: "https://cat-fact.herokuapp.com/facts/random") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                let factData = try JSONDecoder().decode(CatFactResponse.self, from: data)
                completion(.success("🐱 Fun Fact: \(factData.fact)"))
            } catch {
                // Fallback to number facts
                self.fetchNumberFact(completion: completion)
            }
        }
        
        task.resume()
    }
    
    private func fetchNumberFact(completion: @escaping (Result<String, Error>) -> Void) {
        // Using numbersapi.com for number facts
        let randomNumber = Int.random(in: 1...365)
        guard let url = URL(string: "http://numbersapi.com/\(randomNumber)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                let fact = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            completion(.success("🔢 Did you know? \(fact)"))
        }
        
        task.resume()
    }
    
    // MARK: - Local Harry Potter Quotes (as fallback)
    
    private let harryPotterQuotes = [
        "\"It is our choices that show what we truly are, far more than our abilities.\" - Albus Dumbledore",
        "\"Happiness can be found even in the darkest of times, if one only remembers to turn on the light.\" - Albus Dumbledore",
        "\"We've all got both light and dark inside us. What matters is the part we choose to act on.\" - Sirius Black",
        "\"It does not do to dwell on dreams and forget to live.\" - Albus Dumbledore",
        "\"Working hard is important. But there is something that matters even more, believing in yourself.\" - Harry Potter",
        "\"You're a wizard, Harry!\" - Hagrid",
        "\"After all this time? Always.\" - Severus Snape",
        "\"Help will always be given at Hogwarts to those who ask for it.\" - Albus Dumbledore"
    ]
    
    func getRandomHarryPotterQuote() -> String {
        return harryPotterQuotes.randomElement() ?? "\"Believe in magic!\" - StudySpell"
    }
}
