//
//  Copyright (C) 2020 Thomas LEGRIS.
//

import SwiftyUserDefaults

/// Defines key to store in UserDefaults.
extension DefaultsKeys {
    var lastSearchedCity: DefaultsKey<String> { .init("key_lastSearchedCity", defaultValue: "") }
    var lastUpdatedDate: DefaultsKey<String> { .init("key_lastUpdatedDate", defaultValue: "") }
}
