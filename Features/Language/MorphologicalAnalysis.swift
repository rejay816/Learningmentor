import Foundation
import NaturalLanguage

public struct MorphologicalAnalyzer {
    // MARK: - Public Interface
    
    public static func analyze(_ text: String) -> MorphologicalAnalysisResult {
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .lemma, .language])
        tagger.string = text
        
        var verbForms: [VerbForm] = []
        var nominalForms: [NominalForm] = []
        var adjectiveForms: [AdjectiveForm] = []
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, range in
            let word = String(text[range])
            let lemma = tagger.tag(at: range.lowerBound, unit: .word, scheme: .lemma).0?.rawValue
            
            if let tag = tag {
                switch tag {
                case .verb:
                    if let analysis = analyzeVerbForm(word, lemma: lemma, language: tagger.dominantLanguage) {
                        verbForms.append(analysis)
                    }
                case .noun, .pronoun:
                    if let analysis = analyzeNominalForm(word, lemma: lemma, language: tagger.dominantLanguage) {
                        nominalForms.append(analysis)
                    }
                case .adjective:
                    if let analysis = analyzeAdjectiveForm(word, lemma: lemma, language: tagger.dominantLanguage) {
                        adjectiveForms.append(analysis)
                    }
                default:
                    break
                }
            }
            return true
        }
        
        return MorphologicalAnalysisResult(
            verbForms: verbForms,
            nominalForms: nominalForms,
            adjectiveForms: adjectiveForms
        )
    }
    
    // MARK: - Analysis Result Types
    
    public struct MorphologicalAnalysisResult {
        public let verbForms: [VerbForm]
        public let nominalForms: [NominalForm]
        public let adjectiveForms: [AdjectiveForm]
    }
    
    public struct VerbForm {
        public let text: String
        public let lemma: String?
        public let tense: Tense
        public let person: Person
        public let number: Number
        public let mood: Mood
        public let language: Language
        public let isRegular: Bool
    }
    
    public struct NominalForm {
        public let text: String
        public let lemma: String?
        public let gender: Gender
        public let number: Number
        public let case_: Case
        public let language: Language
    }
    
    public struct AdjectiveForm {
        public let text: String
        public let lemma: String?
        public let gender: Gender
        public let number: Number
        public let degree: Degree
        public let language: Language
    }
    
    // MARK: - Morphological Categories
    
    public enum Tense {
        case present
        case imperfect
        case future
        case pastSimple      // English only
        case pastParticiple
        case presentParticiple
        case conditional
        case pluperfect
        case futurePerfect
    }
    
    public enum Person {
        case first
        case second
        case third
    }
    
    public enum Number {
        case singular
        case plural
    }
    
    public enum Gender {
        case masculine
        case feminine
        case neuter        // English only
    }
    
    public enum Case {
        case nominative    // English subject
        case accusative    // English object
        case genitive      // English possessive
        case dative       // French indirect object
    }
    
    public enum Mood {
        case indicative
        case subjunctive
        case conditional
        case imperative
    }
    
    public enum Degree {
        case positive
        case comparative
        case superlative
    }
    
    public enum Language {
        case english
        case french
    }
    
    // MARK: - Private Analysis Methods
    
    private static func analyzeVerbForm(_ word: String, lemma: String?, language: NLLanguage?) -> VerbForm? {
        switch language {
        case .french:
            return analyzeFrenchVerb(word, lemma: lemma)
        case .english:
            return analyzeEnglishVerb(word, lemma: lemma)
        default:
            return nil
        }
    }
    
    private static func analyzeFrenchVerb(_ word: String, lemma: String?) -> VerbForm? {
        // 法语动词变位分析
        let patterns: [(pattern: String, analysis: (Tense, Person, Number, Mood))] = [
            // 现在时变位（第一组动词 -er）
            (#"(\w+)e$"#, (.present, .first, .singular, .indicative)),
            (#"(\w+)es$"#, (.present, .second, .singular, .indicative)),
            (#"(\w+)e$"#, (.present, .third, .singular, .indicative)),
            (#"(\w+)ons$"#, (.present, .first, .plural, .indicative)),
            (#"(\w+)ez$"#, (.present, .second, .plural, .indicative)),
            (#"(\w+)ent$"#, (.present, .third, .plural, .indicative)),
            
            // 现在时变位（第二组动词 -ir）
            (#"(\w+)is$"#, (.present, .first, .singular, .indicative)),
            (#"(\w+)is$"#, (.present, .second, .singular, .indicative)),
            (#"(\w+)it$"#, (.present, .third, .singular, .indicative)),
            (#"(\w+)issons$"#, (.present, .first, .plural, .indicative)),
            (#"(\w+)issez$"#, (.present, .second, .plural, .indicative)),
            (#"(\w+)issent$"#, (.present, .third, .plural, .indicative)),
            
            // 现在时变位（第三组动词）
            (#"(\w+)s$"#, (.present, .first, .singular, .indicative)),
            (#"(\w+)s$"#, (.present, .second, .singular, .indicative)),
            (#"(\w+)t$"#, (.present, .third, .singular, .indicative)),
            (#"(\w+)ons$"#, (.present, .first, .plural, .indicative)),
            (#"(\w+)ez$"#, (.present, .second, .plural, .indicative)),
            (#"(\w+)ent$"#, (.present, .third, .plural, .indicative)),
            
            // 未完成时变位
            (#"(\w+)ais$"#, (.imperfect, .first, .singular, .indicative)),
            (#"(\w+)ais$"#, (.imperfect, .second, .singular, .indicative)),
            (#"(\w+)ait$"#, (.imperfect, .third, .singular, .indicative)),
            (#"(\w+)ions$"#, (.imperfect, .first, .plural, .indicative)),
            (#"(\w+)iez$"#, (.imperfect, .second, .plural, .indicative)),
            (#"(\w+)aient$"#, (.imperfect, .third, .plural, .indicative)),
            
            // 简单将来时变位
            (#"(\w+)erai$"#, (.future, .first, .singular, .indicative)),
            (#"(\w+)eras$"#, (.future, .second, .singular, .indicative)),
            (#"(\w+)era$"#, (.future, .third, .singular, .indicative)),
            (#"(\w+)erons$"#, (.future, .first, .plural, .indicative)),
            (#"(\w+)erez$"#, (.future, .second, .plural, .indicative)),
            (#"(\w+)eront$"#, (.future, .third, .plural, .indicative)),
            
            // 条件式现在时
            (#"(\w+)erais$"#, (.conditional, .first, .singular, .conditional)),
            (#"(\w+)erais$"#, (.conditional, .second, .singular, .conditional)),
            (#"(\w+)erait$"#, (.conditional, .third, .singular, .conditional)),
            (#"(\w+)erions$"#, (.conditional, .first, .plural, .conditional)),
            (#"(\w+)eriez$"#, (.conditional, .second, .plural, .conditional)),
            (#"(\w+)eraient$"#, (.conditional, .third, .plural, .conditional)),
            
            // 虚拟语气现在时
            (#"(\w+)e$"#, (.present, .first, .singular, .subjunctive)),
            (#"(\w+)es$"#, (.present, .second, .singular, .subjunctive)),
            (#"(\w+)e$"#, (.present, .third, .singular, .subjunctive)),
            (#"(\w+)ions$"#, (.present, .first, .plural, .subjunctive)),
            (#"(\w+)iez$"#, (.present, .second, .plural, .subjunctive)),
            (#"(\w+)ent$"#, (.present, .third, .plural, .subjunctive)),
            
            // 虚拟语气未完成时
            (#"(\w+)asse$"#, (.imperfect, .first, .singular, .subjunctive)),
            (#"(\w+)asses$"#, (.imperfect, .second, .singular, .subjunctive)),
            (#"(\w+)ât$"#, (.imperfect, .third, .singular, .subjunctive)),
            (#"(\w+)assions$"#, (.imperfect, .first, .plural, .subjunctive)),
            (#"(\w+)assiez$"#, (.imperfect, .second, .plural, .subjunctive)),
            (#"(\w+)assent$"#, (.imperfect, .third, .plural, .subjunctive)),
            
            // 命令语气
            (#"(\w+)e$"#, (.present, .second, .singular, .imperative)),
            (#"(\w+)ons$"#, (.present, .first, .plural, .imperative)),
            (#"(\w+)ez$"#, (.present, .second, .plural, .imperative)),
            
            // 现在分词
            (#"(\w+)ant$"#, (.presentParticiple, .first, .singular, .indicative)),
            
            // 过去分词
            (#"(\w+)é$"#, (.pastParticiple, .first, .singular, .indicative)),
            (#"(\w+)ée$"#, (.pastParticiple, .first, .singular, .indicative)),
            (#"(\w+)és$"#, (.pastParticiple, .first, .plural, .indicative)),
            (#"(\w+)ées$"#, (.pastParticiple, .first, .plural, .indicative)),
            (#"(\w+)i$"#, (.pastParticiple, .first, .singular, .indicative)),
            (#"(\w+)ie$"#, (.pastParticiple, .first, .singular, .indicative)),
            (#"(\w+)is$"#, (.pastParticiple, .first, .plural, .indicative)),
            (#"(\w+)ies$"#, (.pastParticiple, .first, .plural, .indicative)),
            (#"(\w+)u$"#, (.pastParticiple, .first, .singular, .indicative)),
            (#"(\w+)ue$"#, (.pastParticiple, .first, .singular, .indicative)),
            (#"(\w+)us$"#, (.pastParticiple, .first, .plural, .indicative)),
            (#"(\w+)ues$"#, (.pastParticiple, .first, .plural, .indicative))
        ]
        
        for (pattern, (tense, person, number, mood)) in patterns {
            if word.range(of: pattern, options: .regularExpression) != nil {
                return VerbForm(
                    text: word,
                    lemma: lemma,
                    tense: tense,
                    person: person,
                    number: number,
                    mood: mood,
                    language: .french,
                    isRegular: isRegularFrenchVerb(word, lemma: lemma)
                )
            }
        }
        
        return nil
    }
    
    private static func analyzeEnglishVerb(_ word: String, lemma: String?) -> VerbForm? {
        // 英语动词变位分析
        let patterns: [(pattern: String, analysis: (Tense, Person, Number, Mood))] = [
            // 现在时变位
            (#"(\w+)s$"#, (.present, .third, .singular, .indicative)),
            (#"(\w+)$"#, (.present, .first, .singular, .indicative)),
            (#"(\w+)$"#, (.present, .second, .singular, .indicative)),
            (#"(\w+)$"#, (.present, .first, .plural, .indicative)),
            (#"(\w+)$"#, (.present, .second, .plural, .indicative)),
            (#"(\w+)$"#, (.present, .third, .plural, .indicative)),
            
            // 过去时变位
            (#"(\w+)ed$"#, (.pastSimple, .first, .singular, .indicative)),
            (#"(\w+)ed$"#, (.pastSimple, .second, .singular, .indicative)),
            (#"(\w+)ed$"#, (.pastSimple, .third, .singular, .indicative)),
            
            // 现在分词
            (#"(\w+)ing$"#, (.presentParticiple, .first, .singular, .indicative)),
            
            // 过去分词
            (#"(\w+)ed$"#, (.pastParticiple, .first, .singular, .indicative))
        ]
        
        for (pattern, (tense, person, number, mood)) in patterns {
            if word.range(of: pattern, options: .regularExpression) != nil {
                return VerbForm(
                    text: word,
                    lemma: lemma,
                    tense: tense,
                    person: person,
                    number: number,
                    mood: mood,
                    language: .english,
                    isRegular: isRegularEnglishVerb(word, lemma: lemma)
                )
            }
        }
        
        return nil
    }
    
    private static func analyzeNominalForm(_ word: String, lemma: String?, language: NLLanguage?) -> NominalForm? {
        switch language {
        case .french:
            return analyzeFrenchNominal(word, lemma: lemma)
        case .english:
            return analyzeEnglishNominal(word, lemma: lemma)
        default:
            return nil
        }
    }
    
    private static func analyzeFrenchNominal(_ word: String, lemma: String?) -> NominalForm? {
        // 法语名词性别数分析
        let patterns: [(pattern: String, analysis: (Gender, Number, Case))] = [
            // 阳性单数
            (#"(\w+)$"#, (.masculine, .singular, .nominative)),
            (#"(\w+)al$"#, (.masculine, .singular, .nominative)),
            (#"(\w+)eur$"#, (.masculine, .singular, .nominative)),
            (#"(\w+)ier$"#, (.masculine, .singular, .nominative)),
            
            // 阳性复数
            (#"(\w+)s$"#, (.masculine, .plural, .nominative)),
            (#"(\w+)aux$"#, (.masculine, .plural, .nominative)),
            (#"(\w+)eurs$"#, (.masculine, .plural, .nominative)),
            (#"(\w+)iers$"#, (.masculine, .plural, .nominative)),
            
            // 阴性单数
            (#"(\w+)e$"#, (.feminine, .singular, .nominative)),
            (#"(\w+)tion$"#, (.feminine, .singular, .nominative)),
            (#"(\w+)té$"#, (.feminine, .singular, .nominative)),
            (#"(\w+)euse$"#, (.feminine, .singular, .nominative)),
            (#"(\w+)rice$"#, (.feminine, .singular, .nominative)),
            (#"(\w+)ière$"#, (.feminine, .singular, .nominative)),
            
            // 阴性复数
            (#"(\w+)es$"#, (.feminine, .plural, .nominative)),
            (#"(\w+)tions$"#, (.feminine, .plural, .nominative)),
            (#"(\w+)tés$"#, (.feminine, .plural, .nominative)),
            (#"(\w+)euses$"#, (.feminine, .plural, .nominative)),
            (#"(\w+)rices$"#, (.feminine, .plural, .nominative)),
            (#"(\w+)ières$"#, (.feminine, .plural, .nominative))
        ]
        
        for (pattern, (gender, number, case_)) in patterns {
            if word.range(of: pattern, options: .regularExpression) != nil {
                return NominalForm(
                    text: word,
                    lemma: lemma,
                    gender: gender,
                    number: number,
                    case_: case_,
                    language: .french
                )
            }
        }
        
        return nil
    }
    
    private static func analyzeEnglishNominal(_ word: String, lemma: String?) -> NominalForm? {
        // 英语名词数和格分析
        let patterns: [(pattern: String, analysis: (Gender, Number, Case))] = [
            // 单数
            (#"(\w+)$"#, (.neuter, .singular, .nominative)),
            // 复数
            (#"(\w+)s$"#, (.neuter, .plural, .nominative)),
            // 所有格单数
            (#"(\w+)'s$"#, (.neuter, .singular, .genitive)),
            // 所有格复数
            (#"(\w+)s'$"#, (.neuter, .plural, .genitive))
        ]
        
        for (pattern, (gender, number, case_)) in patterns {
            if word.range(of: pattern, options: .regularExpression) != nil {
                return NominalForm(
                    text: word,
                    lemma: lemma,
                    gender: gender,
                    number: number,
                    case_: case_,
                    language: .english
                )
            }
        }
        
        return nil
    }
    
    private static func analyzeAdjectiveForm(_ word: String, lemma: String?, language: NLLanguage?) -> AdjectiveForm? {
        switch language {
        case .french:
            return analyzeFrenchAdjective(word, lemma: lemma)
        case .english:
            return analyzeEnglishAdjective(word, lemma: lemma)
        default:
            return nil
        }
    }
    
    private static func analyzeFrenchAdjective(_ word: String, lemma: String?) -> AdjectiveForm? {
        // 法语形容词变化分析
        let patterns: [(pattern: String, analysis: (Gender, Number, Degree))] = [
            // 阳性单数
            (#"(\w+)$"#, (.masculine, .singular, .positive)),
            (#"(\w+)al$"#, (.masculine, .singular, .positive)),
            (#"(\w+)eux$"#, (.masculine, .singular, .positive)),
            (#"(\w+)if$"#, (.masculine, .singular, .positive)),
            
            // 阳性复数
            (#"(\w+)s$"#, (.masculine, .plural, .positive)),
            (#"(\w+)aux$"#, (.masculine, .plural, .positive)),
            (#"(\w+)eux$"#, (.masculine, .plural, .positive)),
            (#"(\w+)ifs$"#, (.masculine, .plural, .positive)),
            
            // 阴性单数
            (#"(\w+)e$"#, (.feminine, .singular, .positive)),
            (#"(\w+)ale$"#, (.feminine, .singular, .positive)),
            (#"(\w+)euse$"#, (.feminine, .singular, .positive)),
            (#"(\w+)ive$"#, (.feminine, .singular, .positive)),
            
            // 阴性复数
            (#"(\w+)es$"#, (.feminine, .plural, .positive)),
            (#"(\w+)ales$"#, (.feminine, .plural, .positive)),
            (#"(\w+)euses$"#, (.feminine, .plural, .positive)),
            (#"(\w+)ives$"#, (.feminine, .plural, .positive)),
            
            // 比较级和最高级
            (#"plus (\w+)"#, (.masculine, .singular, .comparative)),
            (#"moins (\w+)"#, (.masculine, .singular, .comparative)),
            (#"le plus (\w+)"#, (.masculine, .singular, .superlative)),
            (#"la plus (\w+)"#, (.feminine, .singular, .superlative)),
            (#"les plus (\w+)"#, (.masculine, .plural, .superlative))
        ]
        
        for (pattern, (gender, number, degree)) in patterns {
            if word.range(of: pattern, options: .regularExpression) != nil {
                return AdjectiveForm(
                    text: word,
                    lemma: lemma,
                    gender: gender,
                    number: number,
                    degree: degree,
                    language: .french
                )
            }
        }
        
        return nil
    }
    
    private static func analyzeEnglishAdjective(_ word: String, lemma: String?) -> AdjectiveForm? {
        // 英语形容词变化分析
        let patterns: [(pattern: String, analysis: (Gender, Number, Degree))] = [
            // 原级
            (#"(\w+)$"#, (.neuter, .singular, .positive)),
            // 比较级
            (#"(\w+)er$"#, (.neuter, .singular, .comparative)),
            // 最高级
            (#"(\w+)est$"#, (.neuter, .singular, .superlative))
        ]
        
        for (pattern, (gender, number, degree)) in patterns {
            if word.range(of: pattern, options: .regularExpression) != nil {
                return AdjectiveForm(
                    text: word,
                    lemma: lemma,
                    gender: gender,
                    number: number,
                    degree: degree,
                    language: .english
                )
            }
        }
        
        return nil
    }
    
    // MARK: - Helper Methods
    
    private static func isRegularFrenchVerb(_ word: String, lemma: String?) -> Bool {
        // 简单判断是否为规则动词（以-er结尾且不在不规则动词列表中）
        guard let lemma = lemma else { return false }
        return lemma.hasSuffix("er") && !irregularFrenchVerbs.contains(lemma)
    }
    
    private static func isRegularEnglishVerb(_ word: String, lemma: String?) -> Bool {
        // 简单判断是否为规则动词（过去式和过去分词都是加-ed且不在不规则动词列表中）
        guard let lemma = lemma else { return false }
        return !irregularEnglishVerbs.contains(lemma)
    }
    
    // 不规则动词列表
    private static let irregularFrenchVerbs: Set<String> = [
        "être", "avoir", "aller", "faire", "dire", "pouvoir", "savoir", "vouloir",
        "venir", "voir", "devoir", "prendre", "mettre", "falloir", "parler"
    ]
    
    private static let irregularEnglishVerbs: Set<String> = [
        "be", "have", "do", "say", "go", "get", "make", "know", "think", "take",
        "see", "come", "want", "look", "use", "find", "give", "tell", "work", "call"
    ]
} 