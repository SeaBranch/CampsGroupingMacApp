import Foundation

extension APIEventReducer {
    enum DidRespondToGetReportFormatReducer {
        static func handleEvent(
            result: GetReportFormatResult,
            requestData: GetReportFormatData,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.activeFetches.remove(networkCall)
            return switch result {
            case .success(let formatSettings):
                handleSuccess(
                    result: formatSettings,
                    requestData: requestData,
                    state: &state
                )
            case .failure(let error):
                handleFailure(
                    result: error,
                    requestData: requestData,
                    networkCall: networkCall,
                    state: &state
                )
            }
        }

        private static func handleSuccess(
            result: [ReportFieldSetting],
            requestData: GetReportFormatData,
            state: inout GrouperState
        ) -> [GrouperAction] {
            let matchingCamp = state.camps.first(where: { camp in
                camp.info.eventNumber == requestData.campSettings.report.campEventNumber
            })

            guard var updatedCamp = matchingCamp,
                  var settingsToUpdate = updatedCamp.campSettings else {
                return []
            }

            settingsToUpdate.report.reportFieldSettings = result
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
            result: CampsGroupingAPIError,
            requestData: GetReportFormatData,
            networkCall: NetworkCall,
            state: inout GrouperState
        ) -> [GrouperAction] {
            state.errors = state.errors.filter { error in
                if case .campReportFormat = error {
                    false
                } else {
                    true
                }
            }
            state.errors.insert(.campReportFormat(error: result, networkCall: networkCall))

            return []
        }
    }
}
