//
//  MessageFilterExtension.swift
//  MessageFilterExtension
//
//  Created by Jonathan Gregson on 2/7/22.
//

import IdentityLookup

final class MessageFilterExtension: ILMessageFilterExtension {}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        let offlineAction = self.offlineAction(for: queryRequest)
        
        switch offlineAction {
            // Filter messages based on the results of offlineAction
        case .allow, .junk, .promotion, .transaction:
            let response = ILMessageFilterQueryResponse()
            response.action = offlineAction
            completion(response)
            
            // We don't need to send anything over the network
        case .none:
            let response = ILMessageFilterQueryResponse()
            response.action = .none
            completion(response)
            
        @unknown default:
            break
        }
    }
    
    private func offlineAction(for queryRequest: ILMessageFilterQueryRequest) -> ILMessageFilterAction {
        guard let messageSender = queryRequest.sender else {
            return .none
        }
        
        guard let messageBody = queryRequest.messageBody else {
            return .none
        }
        
        let result = analyzeMessage(messageBody: messageBody, messageSender: messageSender, returnFirstMatch: true)
        if (result.count > 0) {
            return .junk
        } else {
            return .none
        }
    }
}

func analyzeMessage(messageBody: String, messageSender: String, returnFirstMatch: Bool = false) -> [String] {
    let sortedSender = String(messageSender.lowercased().sorted())
    let senderNumbers = sortedSender.filter("0123456789".contains)
    let ipRegex = #"\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\b"#
    var allMatches: [String] = []
    
    // Filter messages sent from email addresses
    if (messageSender.lowercased().contains("@")) {
        let reason = "Sender appears to be an email address."
        if returnFirstMatch {
            return [reason]
        }
        if !allMatches.contains(reason) {
            allMatches.append(reason)
        }
    }
    
    // Filter messages containing risky/abusive TLDs
    if (hasAbuseiveTld(messageBody: messageBody)) {
        let reason = "Message contains an abusive TLD."
        if returnFirstMatch {
            return [reason]
        }
        if !allMatches.contains(reason) {
            allMatches.append(reason)
        }
    }
    
    // Filter messages containing IPv4 addresses
    if (messageBody.range(of: ipRegex, options: .regularExpression) != nil) {
        let reason = "Message contains an IPv4 address."
        if returnFirstMatch {
            return [reason]
        }
        if !allMatches.contains(reason) {
            allMatches.append(reason)
        }
    }
    
    // Filter messages which mention banks and are not sent from SMS shortcodes
    if (senderNumbers.range(of: #"^\d{4,6}$"#, options: .regularExpression) == nil) {
        if (hasBankName(messageBody: messageBody)) {
            let reason = "Message appears to contain a bank name and is not from an SMS shortcode."
            if returnFirstMatch {
                return [reason]
            }
            if !allMatches.contains(reason) {
                allMatches.append(reason)
            }
        }
    }
    
    // Filter messages which contain common phishing phrases
    if (hasPhishingPhrase(messageBody: messageBody)) {
        let reason = "Message contains a common phishing phrase."
        if returnFirstMatch {
            return [reason]
        }
        if !allMatches.contains(reason) {
            allMatches.append(reason)
        }
    }
    
    return allMatches
}

func hasAbuseiveTld(messageBody: String) -> Bool {
    let abusiveTlds = [
        ".amazonaws.com",
        ".amplifyap.com",
        ".au",
        ".bar",
        ".bd",
        ".best",
        ".br",
        ".business",
        ".buzz",
        ".cam",
        ".casa",
        ".cc",
        ".center",
        ".cloud",
        ".cn",
        ".cyou",
        ".digital",
        ".digital",
        ".email",
        ".fun",
        ".funance",
        ".godaddysites.com",
        ".host",
        ".icu",
        ".ik",
        ".in",
        ".info",
        ".ir",
        ".ke",
        ".ke",
        ".link",
        ".live",
        ".monster",
        ".net",
        ".netfly.app",
        ".ng",
        ".np",
        ".one",
        ".online",
        ".online",
        ".pe",
        ".ph",
        ".pk",
        ".pl",
        ".quest",
        ".rest",
        ".ru",
        ".sa",
        ".sbs",
        ".services",
        ".shop",
        ".site",
        ".store",
        ".su",
        ".support",
        ".surf",
        ".td",
        ".th",
        ".tk",
        ".top",
        ".tr",
        ".trycloudflare.com",
        ".workers.dev",
        ".uz",
        ".ve",
        ".vn",
        ".wang",
        ".web.app",
        ".website",
        ".weebly.com",
        ".work",
        ".xyz",
    ]
    
    let filteredMessageBody = messageBody.lowercased()
    for abusiveTld in abusiveTlds {
        if (filteredMessageBody.contains(abusiveTld)) {
            return true
        }
    }
    return false
}

func hasBankName(messageBody: String) -> Bool {
    let bankNames = [
        "afcu",
        "alaskausa",
        "alliant",
        "allyfinancial",
        "americafirst",
        "americanexpress",
        "americu",
        "ameriprise",
        "ameris",
        "amex",
        "arvest",
        "atlanticunionbank",
        "aufcu",
        "banccorp",
        "bancorp",
        "bancshares",
        "bankof",
        "bankozk",
        "bankunited",
        "barclays",
        "bcifinancial",
        "becu",
        "bmoharris",
        "bnp",
        "bofa",
        "boa",
        "bokfinancial",
        "cadencebank",
        "capitalone",
        "cathaybank",
        "centralbancompany",
        "chase",
        "cibcbank",
        "citgroup",
        "citi",
        "citizensfinancial",
        "citynationalbank",
        "comerica",
        "commercebancshares",
        "creditsuisse",
        "creditunion",
        "deutschebank",
        "discover",
        "eastwestbank",
        "fargo",
        "fifththird",
        "firstcitizens",
        "firsthawaiian bank",
        "firsthorizon",
        "firstinterstate",
        "firstmidwest bank",
        "firstnational",
        "firstrepublic bank",
        "firstbank",
        "flagstar",
        "fnb",
        "golden1",
        "hsbc",
        "investors bank",
        "jpmorgan",
        "keybank",
        "keycorp",
        "m&tbank",
        "mastercard",
        "midfirstbank",
        "mufgunion",
        "navyfederal",
        "ncfu",
        "newyorkcommunitybank",
        "northerntrust",
        "nycb",
        "oldnationalbank",
        "pacificpremier",
        "pacwest",
        "paypal",
        "peoplesunited",
        "pinnaclefinancial",
        "pnc",
        "rbcbank",
        "regionsbank",
        "regionsfinancial",
        "santanderbank",
        "schwab",
        "signaturebank",
        "simmonsbank",
        "smbc",
        "sterling",
        "stifel",
        "suncoast",
        "svb",
        "synchrony",
        "synovus",
        "tdbank",
        "texascapitalbank",
        "tiaa",
        "truist",
        "ubs",
        "umbfinancial",
        "umpqua",
        "unitedbank",
        "unitedcommunitybank",
        "usbank",
        "usaa",
        "visa",
        "washingtonfederal",
        "websterbank",
        "wells",
        "westernalliancebank",
        "wintrust",
        "zionsbancorporation",
    ]
    
    let filteredMessageBody = messageBody.lowercased().filter("abcdefghijklmnopqrstuvwxyz0123456789".contains)
    for bankName in bankNames {
        let variations = getLeetVariations(initialString: bankName)
        for variation in variations {
            if (filteredMessageBody.contains(variation)) {
                return true
            }
        }
    }
    return false
}

func hasPhishingPhrase(messageBody: String) -> Bool {
    let phishingPhrases = [
        "freepiano",
        "yourorderhasbeen",
        "contactcustomercare",
        "contactcustomersupport",
        "ifyouwishtocancel",
        "pleasecall",
        "dearcustomer",
        "youraccount",
        "aprize",
        "youwon",
        "youvewon",
        "giftcard",
        "giftcertificate",
        "yourcard",
        "caccountlocked",
        "beenlocked",
        "cardislocked",
        "temporarilylocked",
        "accfrozen",
        "accountfrozen",
        "cardalert",
        "taxrefund",
        "taxreturn",
        "refunding",
        "yourrefund",
        "bankaccount",
        "ppackage",
        "fedex",
        "ups",
        "dhl",
        "usps",
        "delivery",
        "icloudid",
        "bitcoin",
        "confirmtransaction",
        "bailmoney",
        "westernunion",
        "arrestwarrant",
        "lawsuitagainst",
        "warrantagainst",
        "googlesecurity",
        "applesecurity",
        "amazonsecurity",
        "unusualactivity",
        "unusualsignin",
        "unusuallogin",
        "randomlypicked",
        "randomlyselected",
        "winner",
        "sweepstake",
        "payrollproviders",
        "chargeissued",
        "tocancel",
        "hasbeendisabled",
        "failedlogin",
        "loginattempts",
    ]
    
    let filteredMessageBody = messageBody.lowercased().filter("abcdefghijklmnopqrstuvwxyz0123456789".contains)
    for phishingPhrase in phishingPhrases {
        let variations = getLeetVariations(initialString: phishingPhrase)
        for variation in variations {
            if (filteredMessageBody.contains(variation)) {
                return true
            }
        }
    }
    return false
}

func getLeetVariations(initialString: String) -> [String] {
    var variations = [initialString]
    let leetSubstitutions = [
        ["a", "4"],
        ["b", "8"],
        ["e", "3"],
        ["g", "9"],
        ["i", "1"],
        ["i", "l"],
        ["l", "1"],
        ["l", "i"],
        ["o", "0"],
        ["t", "7"],
    ]
    for substitution in leetSubstitutions {
        var variation = initialString.replacingOccurrences(of: substitution[0], with: substitution[1])
        if !variations.contains(variation) {
            variations.append(variation)
        }
        variation = initialString.replacingOccurrences(of: substitution[1], with: substitution[0])
        if !variations.contains(variation) {
            variations.append(variation)
        }
    }
    return variations
}
