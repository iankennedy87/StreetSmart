//
//  InsightlyConstants.swift
//  insightly
//
//  Created by Ian Kennedy on 13/10/2016.
//  Copyright © 2016 Ian Kennedy. All rights reserved.
//

import Foundation

extension InsightlyClient{
    
    struct Constants {
        static let infoLink = URL(string: "https://support.insight.ly/hc/en-us/articles/204864594-Finding-or-resetting-your-API-key")!
    }
    
    struct ResponseKeys {
        static let name = "ORGANISATION_NAME"
        static let imageUrl = "IMAGE_URL"
        static let addresses = "ADDRESSES"
        static let street = "STREET"
        static let city = "CITY"
        static let state = "STATE"
        static let postcode = "POSTCODE"
        static let country = "COUNTRY"
    }
    
    struct API {
        static let APIScheme = "https"
        static let APIHost = "api.insight.ly"
        static let OrganisationEndpoint = "/v2.2/Organisations"
        static let APIKey = "917b59bc-efc4-49bc-a626-dc57f65ee7d6:"
    }
    
}

