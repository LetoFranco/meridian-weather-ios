import Foundation
@testable import Meridian

final class MockPersistenceService: PersistenceService {
    var savedCityID: String?
    var getLastSelectedCityIDCalled = false
    var saveLastSelectedCalledWithID: String?

    func saveLastSelected(cityID: String) {
        saveLastSelectedCalledWithID = cityID
        savedCityID = cityID
    }
    
    func getLastSelectedCityID() -> String? {
        getLastSelectedCityIDCalled = true
        return savedCityID
    }

    func reset() {
        savedCityID = nil
        getLastSelectedCityIDCalled = false
        saveLastSelectedCalledWithID = nil
    }
}
