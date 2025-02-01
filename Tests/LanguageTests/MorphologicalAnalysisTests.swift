import XCTest
@testable import App

final class MorphologicalAnalysisTests: XCTestCase {
    
    // MARK: - French Verb Tests
    
    func testFrenchRegularVerbConjugation() {
        // 测试第一组规则动词 (-er)
        let parler = "parle"  // 第一人称单数现在时
        if let analysis = MorphologicalAnalyzer.analyze(parler).verbForms.first {
            XCTAssertEqual(analysis.tense, .present)
            XCTAssertEqual(analysis.person, .first)
            XCTAssertEqual(analysis.number, .singular)
            XCTAssertEqual(analysis.mood, .indicative)
            XCTAssertTrue(analysis.isRegular)
        }
        
        // 测试第二组规则动词 (-ir)
        let finissons = "finissons"  // 第一人称复数现在时
        if let analysis = MorphologicalAnalyzer.analyze(finissons).verbForms.first {
            XCTAssertEqual(analysis.tense, .present)
            XCTAssertEqual(analysis.person, .first)
            XCTAssertEqual(analysis.number, .plural)
            XCTAssertEqual(analysis.mood, .indicative)
            XCTAssertTrue(analysis.isRegular)
        }
    }
    
    func testFrenchIrregularVerbConjugation() {
        // 测试不规则动词
        let suis = "suis"  // être的第一人称单数现在时
        if let analysis = MorphologicalAnalyzer.analyze(suis).verbForms.first {
            XCTAssertEqual(analysis.tense, .present)
            XCTAssertEqual(analysis.person, .first)
            XCTAssertEqual(analysis.number, .singular)
            XCTAssertEqual(analysis.mood, .indicative)
            XCTAssertFalse(analysis.isRegular)
        }
    }
    
    func testFrenchVerbTenses() {
        // 测试不同时态
        let parlerai = "parlerai"  // 简单将来时
        if let analysis = MorphologicalAnalyzer.analyze(parlerai).verbForms.first {
            XCTAssertEqual(analysis.tense, .future)
            XCTAssertEqual(analysis.person, .first)
            XCTAssertEqual(analysis.number, .singular)
        }
        
        let parlais = "parlais"  // 未完成时
        if let analysis = MorphologicalAnalyzer.analyze(parlais).verbForms.first {
            XCTAssertEqual(analysis.tense, .imperfect)
            XCTAssertEqual(analysis.person, .first)
            XCTAssertEqual(analysis.number, .singular)
        }
    }
    
    func testFrenchVerbMoods() {
        // 测试不同语气
        let parle = "parle"  // 虚拟语气
        if let analysis = MorphologicalAnalyzer.analyze(parle).verbForms.first {
            XCTAssertEqual(analysis.mood, .subjunctive)
        }
        
        let parlons = "parlons"  // 命令语气
        if let analysis = MorphologicalAnalyzer.analyze(parlons).verbForms.first {
            XCTAssertEqual(analysis.mood, .imperative)
        }
    }
    
    // MARK: - French Nominal Tests
    
    func testFrenchNounGender() {
        // 测试名词性别
        let table = "table"  // 阴性
        if let analysis = MorphologicalAnalyzer.analyze(table).nominalForms.first {
            XCTAssertEqual(analysis.gender, .feminine)
            XCTAssertEqual(analysis.number, .singular)
        }
        
        let livre = "livre"  // 阳性
        if let analysis = MorphologicalAnalyzer.analyze(livre).nominalForms.first {
            XCTAssertEqual(analysis.gender, .masculine)
            XCTAssertEqual(analysis.number, .singular)
        }
    }
    
    func testFrenchNounNumber() {
        // 测试名词数的变化
        let tables = "tables"  // 复数
        if let analysis = MorphologicalAnalyzer.analyze(tables).nominalForms.first {
            XCTAssertEqual(analysis.number, .plural)
        }
        
        let travaux = "travaux"  // 特殊复数
        if let analysis = MorphologicalAnalyzer.analyze(travaux).nominalForms.first {
            XCTAssertEqual(analysis.number, .plural)
            XCTAssertEqual(analysis.gender, .masculine)
        }
    }
    
    // MARK: - French Adjective Tests
    
    func testFrenchAdjectiveAgreement() {
        // 测试形容词性数一致
        let belle = "belle"  // 阴性单数
        if let analysis = MorphologicalAnalyzer.analyze(belle).adjectiveForms.first {
            XCTAssertEqual(analysis.gender, .feminine)
            XCTAssertEqual(analysis.number, .singular)
        }
        
        let beaux = "beaux"  // 阳性复数
        if let analysis = MorphologicalAnalyzer.analyze(beaux).adjectiveForms.first {
            XCTAssertEqual(analysis.gender, .masculine)
            XCTAssertEqual(analysis.number, .plural)
        }
    }
    
    func testFrenchAdjectiveDegrees() {
        // 测试形容词比较级和最高级
        let plusBelle = "plus belle"  // 比较级
        if let analysis = MorphologicalAnalyzer.analyze(plusBelle).adjectiveForms.first {
            XCTAssertEqual(analysis.degree, .comparative)
        }
        
        let laPlusBelle = "la plus belle"  // 最高级
        if let analysis = MorphologicalAnalyzer.analyze(laPlusBelle).adjectiveForms.first {
            XCTAssertEqual(analysis.degree, .superlative)
        }
    }
    
    // MARK: - English Tests
    
    func testEnglishVerbConjugation() {
        let speaks = "speaks"  // 第三人称单数现在时
        if let analysis = MorphologicalAnalyzer.analyze(speaks).verbForms.first {
            XCTAssertEqual(analysis.tense, .present)
            XCTAssertEqual(analysis.person, .third)
            XCTAssertEqual(analysis.number, .singular)
        }
        
        let speaking = "speaking"  // 现在分词
        if let analysis = MorphologicalAnalyzer.analyze(speaking).verbForms.first {
            XCTAssertEqual(analysis.tense, .presentParticiple)
        }
    }
    
    func testEnglishNounForms() {
        let dogs = "dogs"  // 复数
        if let analysis = MorphologicalAnalyzer.analyze(dogs).nominalForms.first {
            XCTAssertEqual(analysis.number, .plural)
        }
        
        let dogsOwner = "dog's"  // 所有格
        if let analysis = MorphologicalAnalyzer.analyze(dogsOwner).nominalForms.first {
            XCTAssertEqual(analysis.case_, .genitive)
        }
    }
    
    func testEnglishAdjectiveDegrees() {
        let taller = "taller"  // 比较级
        if let analysis = MorphologicalAnalyzer.analyze(taller).adjectiveForms.first {
            XCTAssertEqual(analysis.degree, .comparative)
        }
        
        let tallest = "tallest"  // 最高级
        if let analysis = MorphologicalAnalyzer.analyze(tallest).adjectiveForms.first {
            XCTAssertEqual(analysis.degree, .superlative)
        }
    }
    
    // MARK: - Mixed Language Tests
    
    func testMixedLanguageAnalysis() {
        let text = "Je speak français"
        let result = MorphologicalAnalyzer.analyze(text)
        
        XCTAssertFalse(result.verbForms.isEmpty)
        XCTAssertTrue(result.verbForms.contains { $0.language == .english })
        XCTAssertTrue(result.nominalForms.contains { $0.language == .french })
    }
} 