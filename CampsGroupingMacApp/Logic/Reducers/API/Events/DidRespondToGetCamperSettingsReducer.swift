import Foundation

extension APIEventReducer {
    enum DidRespondToGetCamperSettingsReducer {
        static func handleEvent(
            result: GetCamperSettingsResult,
            requestData: GetCamperSettingsData,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.activeFetches.remove(networkCall)

            switch result {
            case .success(let camperSettings):
                return handleSuccess(
                    camperSettings: camperSettings,
                    requestData: requestData,
                    networkCall: networkCall,
                    state: &state
                )
            case .failure(let error):
                return handleFailure(
                    error: error,
                    requestData: requestData,
                    networkCall: networkCall,
                    state: &state
                )
            }
        }

        private static func handleSuccess(
            camperSettings: [CamperSetting],
            requestData: GetCamperSettingsData,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            let matchingCamp = state.camps.first(where: { camp in
                camp.info.eventNumber == requestData.camp.info.eventNumber
            })

            guard var updatedCamp = matchingCamp,
                  var settingsToUpdate = updatedCamp.campSettings else {
                return []
            }

            settingsToUpdate.campers = camperSettings
            updatedCamp.campSettings = settingsToUpdate

            state.camps = state.camps.map({ camp in
                if camp.info.eventNumber == updatedCamp.info.eventNumber {
                    updatedCamp
                } else {
                    camp
                }
            })

            return []
        }

        private static func handleFailure(
            error: CampsGroupingAPIError,
            requestData: GetCamperSettingsData,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.errors = state.errors.filter { error in
                if case .camperSettings = error {
                    false
                } else {
                    true
                }
            }

            state.errors.insert(.camperSettings(error: error, networkCall: networkCall))

            return []
        }
    }
}
